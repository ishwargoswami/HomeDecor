import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_foodybite/models/decor_item_model.dart';

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
  
  // Initialize the cart
  Future<void> initializeCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      _items = [];
      notifyListeners();
      return;
    }
    
    loadCartItems();
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadCartItems();
      } else {
        _items = [];
        notifyListeners();
      }
    });
  }
  
  // Load cart items
  Future<void> loadCartItems() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
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
      
      // Get product details for each cart item
      for (int i = 0; i < cartItems.length; i++) {
        final itemId = cartItems[i].itemId;
        final productDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('decor_items')
            .doc(itemId)
            .get();
        
        if (productDoc.exists) {
          final product = DecorItemModel.fromMap(productDoc.data() as Map<String, dynamic>);
          cartItems[i] = cartItems[i].copyWith(product: product);
        }
      }
      
      _items = cartItems;
      _isLoading = false;
      notifyListeners();
      
      // Set up listener for real-time updates
      cartRef.snapshots().listen((snapshot) {
        loadCartItems();
      });
    } catch (e) {
      print('Error loading cart items: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add item to cart
  Future<void> addToCart(String itemId, {int quantity = 1}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
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