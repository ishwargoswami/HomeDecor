import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:decor_home/models/decor_item_model.dart';
import 'package:decor_home/models/project_model.dart';
import 'package:decor_home/screens/add_decor_item.dart';
import 'package:decor_home/screens/add_project.dart';
import 'package:decor_home/screens/categories.dart';
import 'package:decor_home/screens/trending.dart';
import 'package:decor_home/services/auth_provider.dart';
import 'package:decor_home/services/decor_provider.dart';
import 'package:decor_home/services/cart_service.dart';
import 'package:decor_home/util/categories.dart';
import 'package:decor_home/util/const.dart';
import 'package:decor_home/widgets/category_item.dart';
import 'package:decor_home/widgets/project_preview.dart';
import 'package:decor_home/widgets/search_card.dart';
import 'package:decor_home/widgets/slide_item.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../util/firebase_seeder.dart';
import 'package:decor_home/models/category_model.dart';
import 'package:decor_home/widgets/app_drawer.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Promotional banners for carousel slider
  List<Map<String, dynamic>> _promotions = [];
  bool _isPromotionsLoading = true;
  
  // Cart badge counter
  int _cartItemCount = 0;
  
  // Wishlist items
  List<String> _wishlistItems = [];
  
  // Recently viewed items
  List<String> _recentlyViewedIds = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isInitialized = false;
  Set<String> _loadingCartItems = {};

  @override
  void initState() {
    super.initState();
    _startAutoSlider();
    
    // Load promotions from Firestore
    _loadPromotions();
    
    // Load cart items count
    _loadCartItemsCount();
    
    // Load wishlist items
    _loadWishlistItems();
    
    // Load recently viewed items
    _loadRecentlyViewedItems();
    
    // Ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DecorProvider>(context, listen: false);
      if (provider.decorItems.isEmpty) {
        print("Triggering data reload in Home screen");
        provider.initializeData();
      }
    });

    _initializeData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  
  // Load promotions from Firestore
  Future<void> _loadPromotions() async {
    try {
      setState(() {
        _isPromotionsLoading = true;
      });
      
      final promotionsRef = _firestore.collection('promotions');
      final snapshot = await promotionsRef.orderBy('order').get();
      
      if (snapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> promotions = [];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          
          // Fix for color parsing - convert color strings to Color objects properly
          dynamic colorValue = data['color'];
          Color color;
          
          if (colorValue is String) {
            // If color is stored as a hex string with 0x prefix
            if (colorValue.startsWith('0x')) {
              color = Color(int.parse(colorValue));
            } 
            // If color is stored as a hex string without 0x prefix
            else if (colorValue.startsWith('#')) {
              colorValue = colorValue.replaceFirst('#', '0xFF');
              color = Color(int.parse(colorValue));
            } 
            // If color is stored as an integer string
            else {
              try {
                color = Color(int.parse(colorValue));
              } catch (e) {
                // Default color if parsing fails
                color = Color(0xFFFFF3D9);
              }
            }
          } else if (colorValue is int) {
            // If color is already stored as an integer
            color = Color(colorValue);
          } else {
            // Default color if value is null or of unsupported type
            color = Color(0xFFFFF3D9);
          }
          
          promotions.add({
            'id': doc.id,
            'title': data['title'] ?? '',
            'subtitle': data['subtitle'] ?? '',
            'color': color,
            'image': data['image'] ?? 'https://images.pexels.com/photos/1571458/pexels-photo-1571458.jpeg',
            'url': data['url'],
          });
        }
        
        setState(() {
          _promotions = promotions;
          _isPromotionsLoading = false;
        });
      } else {
        // Use default promotions if none exist in Firestore
        setState(() {
          _promotions = [
            {
              'id': '1',
              'title': '30% Off On All Masks',
              'subtitle': 'Shop Now',
              'color': Color(0xFFFFF3D9),
              'image': 'https://images.pexels.com/photos/6069552/pexels-photo-6069552.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
            {
              'id': '2',
              'title': 'New Arrivals',
              'subtitle': 'Check Out',
              'color': Color(0xFFE6F2FF),
              'image': 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
            {
              'id': '3',
              'title': 'Season Sale',
              'subtitle': 'Limited Time',
              'color': Color(0xFFFFE6E6),
              'image': 'https://images.pexels.com/photos/4099354/pexels-photo-4099354.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
          ];
          _isPromotionsLoading = false;
        });
      }
    } catch (e) {
      print('Error loading promotions: $e');
      setState(() {
        _isPromotionsLoading = false;
        // Use default promotions on error
        _promotions = [
          {
            'id': '1',
            'title': '30% Off On All Masks',
            'subtitle': 'Shop Now',
            'color': Color(0xFFFFF3D9),
            'image': 'https://images.pexels.com/photos/6069552/pexels-photo-6069552.jpeg?auto=compress&cs=tinysrgb&w=800',
          },
          {
            'id': '2',
            'title': 'New Arrivals',
            'subtitle': 'Check Out',
            'color': Color(0xFFE6F2FF),
            'image': 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg?auto=compress&cs=tinysrgb&w=800',
          },
          {
            'id': '3',
            'title': 'Season Sale',
            'subtitle': 'Limited Time',
            'color': Color(0xFFFFE6E6),
            'image': 'https://images.pexels.com/photos/4099354/pexels-photo-4099354.jpeg?auto=compress&cs=tinysrgb&w=800',
          },
        ];
      });
    }
  }
  
  // Load cart items count
  Future<void> _loadCartItemsCount() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final cartRef = _firestore.collection('users').doc(user.uid).collection('cart');
        final snapshot = await cartRef.get();
        
        setState(() {
          _cartItemCount = snapshot.docs.length;
        });
        
        // Set up listener for real-time updates
        cartRef.snapshots().listen((snapshot) {
          if (mounted) {
            setState(() {
              _cartItemCount = snapshot.docs.length;
            });
          }
        });
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }
  
  // Load wishlist items
  Future<void> _loadWishlistItems() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final wishlistRef = _firestore.collection('users').doc(user.uid).collection('wishlist');
        final snapshot = await wishlistRef.get();
        
        setState(() {
          _wishlistItems = snapshot.docs.map((doc) => doc.id).toList();
        });
        
        // Set up listener for real-time updates
        wishlistRef.snapshots().listen((snapshot) {
          if (mounted) {
            setState(() {
              _wishlistItems = snapshot.docs.map((doc) => doc.id).toList();
            });
          }
        });
      }
    } catch (e) {
      print('Error loading wishlist items: $e');
    }
  }
  
  // Load recently viewed items
  Future<void> _loadRecentlyViewedItems() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final recentlyViewedRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('recently_viewed')
            .orderBy('timestamp', descending: true)
            .limit(10);
            
        final snapshot = await recentlyViewedRef.get();
        
        setState(() {
          _recentlyViewedIds = snapshot.docs.map((doc) => doc.id).toList();
        });
      }
    } catch (e) {
      print('Error loading recently viewed items: $e');
    }
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_promotions.isEmpty) return;
      
      if (_currentPage < _promotions.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  // Toggle wishlist status
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
          _wishlistItems.remove(itemId);
        });
      } else {
        // Add to wishlist
        await wishlistRef.set({
          'itemId': itemId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _wishlistItems.add(itemId);
        });
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update wishlist'))
      );
    }
  }
  
  // Add item to cart
  Future<void> _addToCart(String itemId) async {
    // Set loading state for this specific item
    setState(() {
      _loadingCartItems.add(itemId);
    });

    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to add items to your cart'))
        );
        return;
      }
      
      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId);
          
      final doc = await cartRef.get();
      
      if (doc.exists) {
        // Increase quantity
        await cartRef.update({
          'quantity': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await cartRef.set({
          'itemId': itemId,
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added to cart'),
          duration: Duration(seconds: 2),
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
    } finally {
      // Always remove loading state
      if (mounted) {
        setState(() {
          _loadingCartItems.remove(itemId);
        });
      }
    }
  }
  
  // Add to recently viewed
  Future<void> _addToRecentlyViewed(String itemId) async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final recentRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('recently_viewed')
            .doc(itemId);
            
        await recentRef.set({
          'itemId': itemId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to recently viewed: $e');
    }
  }

  Future<void> _initializeData() async {
    // Only show loading state if data is actually empty
    final decorProvider = Provider.of<DecorProvider>(context, listen: false);
    final bool shouldShowLoading = decorProvider.decorItems.isEmpty;
    
    if (shouldShowLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    
    // Check if we need to seed data
    await FirebaseSeeder.seedAll();
    
    // Pre-load categories from Firestore if needed
    if (decorProvider.categories.length < 4) {
      await _fetchCategoriesFromFirebase(decorProvider);
    }
    
    // Only wait if we're actually loading
    if (shouldShowLoading) {
      // Shorter delay for smoother UI transition
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    setState(() {
      _isLoading = false;
      _isInitialized = true;
    });
  }

  Future<void> _fetchCategoriesFromFirebase(DecorProvider provider) async {
    try {
      final categoriesRef = FirebaseFirestore.instance.collection('categories');
      final snapshot = await categoriesRef.get();
      
      if (snapshot.docs.isNotEmpty) {
        final fetchedCategories = snapshot.docs.map((doc) {
          final data = doc.data();
          
          // Parse the color safely
          Color? categoryColor;
          if (data['color'] != null) {
            try {
              if (data['color'] is int) {
                categoryColor = Color(data['color']);
              } else if (data['color'] is String) {
                final colorValue = data['color'] as String;
                if (colorValue.startsWith('0x')) {
                  categoryColor = Color(int.parse(colorValue));
                } else if (colorValue.startsWith('#')) {
                  categoryColor = Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
                } else {
                  categoryColor = Color(int.parse(colorValue));
                }
              }
            } catch (e) {
              print('Error parsing color: $e');
              categoryColor = Colors.grey[200];
            }
          } else {
            categoryColor = Colors.grey[200];
          }
          
          return Category(
            name: data['name'] ?? '',
            icon: data['icon'] != null ? IconData(int.parse(data['icon']), fontFamily: 'MaterialIcons') : Icons.category,
            color: categoryColor,
            imageUrl: data['image'] ?? '',
            itemCount: data['items'] ?? 0,
          );
        }).toList();
        
        provider.updateCategories(fetchedCategories);
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final decorProvider = Provider.of<DecorProvider>(context, listen: false);
    
    // Only show loading state if we're loading AND the data is empty
    final bool showLoadingState = _isLoading && decorProvider.decorItems.isEmpty;
    
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(),
        body: showLoadingState 
          ? _buildLoadingState()
          : SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                SizedBox(height: 16.0),
                _buildHeader(),
                SizedBox(height: 24.0),
                _buildSearchBar(),
                SizedBox(height: 24.0),
                _buildPromoSlider(),
                SizedBox(height: 32.0),
                _buildCategorySection(),
                SizedBox(height: 32.0),
                _buildTrendingProductsSection(),
                SizedBox(height: 24.0),
                _buildRecentlyViewedSection(),
                SizedBox(height: 24.0),
              ],
            ),
          ),
        floatingActionButton: _buildCartFAB(),
      ),
    );
  }

  Widget _buildHeader() {
    final auth = Provider.of<AuthProvider>(context);
    final user = _auth.currentUser;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            user != null 
              ? "Hello, ${user.displayName?.split(' ')[0] ?? 'there'}" 
              : "Find your favourite products",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/wishlist');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _cartItemCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Consumer<DecorProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: Colors.grey[600]),
              hintText: "Search...",
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildPromoSlider() {
    return Column(
      children: [
        Container(
          height: 190,
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: _isPromotionsLoading
              ? _buildPromoShimmer()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _promotions.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> promo = {
                          'id': _promotions[index]['id'] ?? '',
                          'title': _promotions[index]['title'] ?? 'Promotion',
                          'subtitle': _promotions[index]['subtitle'] ?? 'Check now',
                          'color': _promotions[index]['color'] ?? Color(0xFFFFF3D9),
                          'image': _promotions[index]['image'] ?? 'https://images.pexels.com/photos/1571458/pexels-photo-1571458.jpeg',
                          'url': _promotions[index]['url'],
                        };
                        return GestureDetector(
                          onTap: () {
                            // Handle promo click - navigate to detail or external URL
                            if (promo['url'] != null) {
                              // Launch URL or navigate to specific screen
                              if (promo['url'].toString().startsWith('/')) {
                                // Internal navigation
                                Navigator.pushNamed(context, promo['url']);
                              } else {
                                // External URL or deep link handling can be added here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening promotion details...'))
                                );
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: promo['color'] is Color 
                                ? promo['color'] 
                                : Color(0xFFFFF3D9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          promo['title'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  promo['subtitle'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward, size: 14),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                                    child: Image.network(
                                      promo['image'],
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        print("Error loading promotion image: $error");
                                        return Container(
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_not_supported,
                                                  size: 30,
                                                  color: Colors.grey[600],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Image not available',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Navigation buttons
                    if (!_isPromotionsLoading && _promotions.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSliderNavButton(
                            icon: Icons.arrow_back_ios_rounded,
                            onTap: () {
                              if (_currentPage > 0) {
                                _pageController.animateToPage(
                                  _currentPage - 1,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                          _buildSliderNavButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: () {
                              if (_currentPage < _promotions.length - 1) {
                                _pageController.animateToPage(
                                  _currentPage + 1,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _isPromotionsLoading
              ? [] // Don't show indicators while loading
              : _buildPageIndicator(),
        ),
      ],
    );
  }
  
  Widget _buildPromoShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _promotions.length; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i 
                ? Theme.of(context).colorScheme.secondary 
                : Colors.grey[300],
          ),
        ),
      );
    }
    return indicators;
  }

  Widget _buildSliderNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black54,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = Provider.of<DecorProvider>(context).categories;
    
    if (categories.isEmpty && !_isInitialized) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop By Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Constants.darkestColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/categories');
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 155,
          child: categories.isEmpty
              ? _buildCategoriesShimmer()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildEnhancedCategoryItem(category);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildEnhancedCategoryItem(Category category) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to category detail
          Navigator.pushNamed(
            context,
            '/category',
            arguments: category,
          );
        },
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image with gradient overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: category.imageUrl.isNotEmpty
                    ? Image.network(
                        category.imageUrl,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImageShimmer();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 140,
                            height: 140,
                            color: category.color ?? Theme.of(context).primaryColor.withOpacity(0.2),
                            child: Icon(
                              category.icon ?? Icons.category,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 140,
                        height: 140,
                        color: category.color ?? Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Icon(
                          category.icon ?? Icons.category,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Text and item count
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.itemCount} items',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoriesShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: _buildImageShimmer(),
      ),
    );
  }
  
  Widget _buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTrendingProductsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Trending Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trending');
              },
              child: Text(
                "View all",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Consumer<DecorProvider>(
          builder: (context, provider, child) {
            // First check if data is initializing
            if (provider.decorItems.isEmpty) {
              print("No items found, showing shimmer");
              
              // Force loading data after a short delay if still empty
              if (!provider.isDataInitialized) {
                print("Data not initialized, triggering initialization");
                Future.delayed(Duration.zero, () {
                  if (mounted) {
                    provider.initializeData();
                  }
                });
              } else {
                // Add a delay to ensure we don't get stuck in loading state
                Future.delayed(Duration(seconds: 1), () {
                  if (provider.decorItems.isEmpty && mounted) {
                    print("Still no items after delay, forcing reload");
                    provider.loadLocalData();
                  }
                });
              }
              
              // Show shimmer loading effect
              return _buildProductShimmer();
            }
            
            final items = provider.decorItems;
            print("Building grid with ${items.length} products");
            
            return items.isEmpty 
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No products available",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => provider.loadLocalData(),
                          child: Text("Reload"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                    ),
                    itemCount: items.length > 4 ? 4 : items.length,
                    itemBuilder: (context, index) {
                      DecorItemModel item = items[index];
                      return _buildProductItem(item);
                    },
                  );
          },
        ),
      ],
    );
  }

  Widget _buildProductItem(DecorItemModel item, {bool horizontal = false}) {
    return GestureDetector(
      onTap: () {
        // Add to recently viewed
        _addToRecentlyViewed(item.id ?? '');
        
        // Navigate to product detail
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
                          _wishlistItems.contains(item.id) 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          color: _wishlistItems.contains(item.id)
                              ? Colors.redAccent
                              : Colors.black54,
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
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _loadingCartItems.contains(item.id ?? '') 
                                  ? null  // Disable when loading
                                  : () => _addToCart(item.id ?? ''),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: _loadingCartItems.contains(item.id ?? '')
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "${item.rating?.toStringAsFixed(1) ?? '0.0'}",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
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

  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 12,
                          width: 120,
                          color: Colors.white,
                        ),
                        Container(
                          height: 10,
                          width: 80,
                          color: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 12,
                              width: 40,
                              color: Colors.white,
                            ),
                            Container(
                              height: 12,
                              width: 30,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // New cart floating action button
  Widget _buildCartFAB() {
    return _cartItemCount > 0 
      ? FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          label: Text(
            'Cart ($_cartItemCount)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(Icons.shopping_cart),
        )
      : SizedBox.shrink();
  }
  
  // New section to show recently viewed items
  Widget _buildRecentlyViewedSection() {
    if (_recentlyViewedIds.isEmpty) return SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recently Viewed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recently_viewed');
              },
              child: Text(
                "View all",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Consumer<DecorProvider>(
          builder: (context, provider, child) {
            // Filter items to only include recently viewed
            final List<DecorItemModel> recentItems = provider.decorItems
                .where((item) => _recentlyViewedIds.contains(item.id))
                .toList();
                
            // Sort by the order in _recentlyViewedIds
            recentItems.sort((a, b) => 
              _recentlyViewedIds.indexOf(a.id ?? '') - 
              _recentlyViewedIds.indexOf(b.id ?? ''));
            
            if (recentItems.isEmpty) {
              return SizedBox.shrink();
            }
            
            return Container(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentItems.length,
                itemBuilder: (context, index) {
                  DecorItemModel item = recentItems[index];
                  return Container(
                    width: 140,
                    margin: EdgeInsets.only(right: 16),
                    child: _buildProductItem(item, horizontal: true),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Column(
        children: [
          // Still show header area to maintain consistency
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Loading content...",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.menu),
              ],
            ),
          ),
          
          // Loading indicator in center of screen
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading products...",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

