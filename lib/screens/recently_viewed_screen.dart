import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_foodybite/models/decor_item_model.dart';
import 'package:flutter_foodybite/services/cart_service.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RecentlyViewedScreen extends StatefulWidget {
  @override
  _RecentlyViewedScreenState createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<String> _recentlyViewedIds = [];
  List<String> _wishlistIds = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecentlyViewedItems();
    _loadWishlistItems();
  }
  
  Future<void> _loadRecentlyViewedItems() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final recentlyViewedRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('recently_viewed')
            .orderBy('timestamp', descending: true)
            .limit(20);
            
        final snapshot = await recentlyViewedRef.get();
        
        setState(() {
          _recentlyViewedIds = snapshot.docs.map((doc) => doc.id).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _recentlyViewedIds = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recently viewed items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadWishlistItems() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final wishlistRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wishlist');
            
        final snapshot = await wishlistRef.get();
        
        setState(() {
          _wishlistIds = snapshot.docs.map((doc) => doc.id).toList();
        });
        
        // Set up listener for real-time updates
        wishlistRef.snapshots().listen((snapshot) {
          if (mounted) {
            setState(() {
              _wishlistIds = snapshot.docs.map((doc) => doc.id).toList();
            });
          }
        });
      }
    } catch (e) {
      print('Error loading wishlist items: $e');
    }
  }
  
  Future<void> _toggleWishlist(String itemId) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to add items to your wishlist'))
        );
        return;
      }
      
      final wishlistRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(itemId);
          
      final doc = await wishlistRef.get();
      
      if (doc.exists) {
        // Remove from wishlist
        await wishlistRef.delete();
        setState(() {
          _wishlistIds.remove(itemId);
        });
      } else {
        // Add to wishlist
        await wishlistRef.set({
          'itemId': itemId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _wishlistIds.add(itemId);
        });
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update wishlist'))
      );
    }
  }
  
  Future<void> _addToCart(BuildContext context, String itemId) async {
    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      await cartService.addToCart(itemId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        )
      );
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item to cart'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recently Viewed'),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _recentlyViewedIds.isEmpty
              ? _buildEmptyState()
              : _buildRecentlyViewedItems(),
    );
  }
  
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No recently viewed items',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Items you view will appear here',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/trending');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Browse Products'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentlyViewedItems() {
    return Consumer<DecorProvider>(
      builder: (context, provider, child) {
        // Get recently viewed items from the decor provider
        final List<DecorItemModel> recentItems = provider.decorItems
            .where((item) => _recentlyViewedIds.contains(item.id))
            .toList();
        
        // Sort items in the same order as _recentlyViewedIds
        recentItems.sort((a, b) => 
          _recentlyViewedIds.indexOf(a.id ?? '') - 
          _recentlyViewedIds.indexOf(b.id ?? ''));
        
        if (recentItems.isEmpty) {
          return _buildEmptyState();
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: recentItems.length,
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return _buildProductItem(item);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildProductItem(DecorItemModel item) {
    final bool isWishlisted = _wishlistIds.contains(item.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/detail', 
          arguments: {'item': item}
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: item.imageUrl == null || item.imageUrl!.isEmpty
                      ? Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        )
                      : Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleWishlist(item.id ?? ''),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.redAccent : Colors.black54,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title ?? "Product Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.category ?? "Category",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${item.price?.toStringAsFixed(2) ?? '0.00'}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _addToCart(context, item.id ?? ''),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 