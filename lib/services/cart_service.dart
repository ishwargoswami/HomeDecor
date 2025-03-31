import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:decor_home/models/decor_item_model.dart';

class CartItem {
  final String id;
  final String itemId;
  final int quantity;
  final Timestamp? addedAt;
  final Timestamp? updatedAt;
  final DecorItemModel? product; // For displaying product details

  CartItem({
    required this.id,
    required this.itemId,
    required this.quantity,
    this.addedAt,
    this.updatedAt,
    this.product,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      quantity: data['quantity'] ?? 1,
      addedAt: data['addedAt'],
      updatedAt: data['updatedAt'],
    );
  }
  
  // Create a copy with product data
  CartItem copyWith({DecorItemModel? product}) {
    return CartItem(
      id: id,
      itemId: itemId,
      quantity: quantity,
      addedAt: addedAt,
      updatedAt: updatedAt,
      product: product ?? this.product,
    );
  }
  
  // Calculate the subtotal for this item
  double get subtotal {
    return (product?.price ?? 0) * quantity;
  }
}

class CartService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<CartItem> _items = [];
  bool _isLoading = false;
  // Track pending operations to prevent duplicates
  Set<String> _pendingOperations = {};
  
  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  
  // Calculate total price
  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.subtotal);
  }
  
  // Calculate total items
  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }
  
  // Load cart items
  Future<void> loadCartItems() async {
    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      _items = [];
      notifyListeners();
      return;
    }
    
    // If we're already loading, don't start another load
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get cart items
      final cartRef = _firestore.collection('users').doc(user.uid).collection('cart');
      final cartSnapshot = await cartRef.get();
      
      // Convert to CartItem objects
      final List<CartItem> cartItems = cartSnapshot.docs
          .map((doc) => CartItem.fromFirestore(doc))
          .toList();
      
      // Only fetch product details if needed
      final List<CartItem> updatedItems = [];
      
      for (final cartItem in cartItems) {
        // Check if we already have product data in the existing items
        final existingItemIndex = _items.indexWhere((item) => item.id == cartItem.id);
        if (existingItemIndex != -1 && _items[existingItemIndex].product != null) {
          // Reuse existing product data to avoid redundant fetches
          updatedItems.add(cartItem.copyWith(product: _items[existingItemIndex].product));
        } else {
          // Fetch product details
          try {
            final productDoc = await _firestore
                .collection('decor_items')
                .doc(cartItem.itemId)
                .get();
            
            if (productDoc.exists) {
              final product = DecorItemModel.fromMap(productDoc.data() as Map<String, dynamic>);
              updatedItems.add(cartItem.copyWith(product: product));
            } else {
              // Try the user's decor items collection
              final userProductDoc = await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('decor_items')
                  .doc(cartItem.itemId)
                  .get();
                  
              if (userProductDoc.exists) {
                final product = DecorItemModel.fromMap(userProductDoc.data() as Map<String, dynamic>);
                updatedItems.add(cartItem.copyWith(product: product));
              } else {
                // No product data found, add without product info
                updatedItems.add(cartItem);
              }
            }
          } catch (e) {
            print('Error fetching product data: $e');
            updatedItems.add(cartItem);
          }
        }
      }
      
      _items = updatedItems;
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      print('Error loading cart items: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Initialize the cart
  Future<void> initializeCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      _items = [];
      notifyListeners();
      return;
    }
    
    // Load cart items initially
    await loadCartItems();
    
    // Set up a single listener for cart changes
    final cartRef = _firestore.collection('users').doc(user.uid).collection('cart');
    cartRef.snapshots().listen((snapshot) {
      if (!_isLoading) {
        loadCartItems();
      }
    });
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        if (!_isLoading) {
          loadCartItems();
        }
      } else {
        _items = [];
        notifyListeners();
      }
    });
  }
  
  // Add item to cart
  Future<void> addToCart(String itemId, {int quantity = 1}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // If this item is already being processed, skip this operation
    if (_pendingOperations.contains(itemId)) {
      return;
    }
    
    try {
      // Mark this item as being processed
      _pendingOperations.add(itemId);
      
      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId);
      
      final doc = await cartRef.get();
      
      if (doc.exists) {
        // Update quantity
        await cartRef.update({
          'quantity': FieldValue.increment(quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await cartRef.set({
          'itemId': itemId,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow; // Allow the caller to handle the error
    } finally {
      // Always remove from pending operations
      _pendingOperations.remove(itemId);
    }
  }
  
  // Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }
    
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId)
          .update({
            'quantity': quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }
  
  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }
  
  // Clear cart
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');
          
      final batch = _firestore.batch();
      final docs = await cartRef.get();
      
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
} 

