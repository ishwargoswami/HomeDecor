import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/decor_item_model.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/screens/add_decor_item.dart';
import 'package:flutter_foodybite/screens/add_project.dart';
import 'package:flutter_foodybite/screens/categories.dart';
import 'package:flutter_foodybite/screens/trending.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:flutter_foodybite/widgets/category_item.dart';
import 'package:flutter_foodybite/widgets/project_preview.dart';
import 'package:flutter_foodybite/widgets/search_card.dart';
import 'package:flutter_foodybite/widgets/slide_item.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Promotional banners for carousel slider
  final List<Map<String, dynamic>> _promotions = [
    {
      'title': '30% Off On All mask',
      'subtitle': 'Shop Now',
      'color': Color(0xFFFFF3D9),
      'image': 'https://images.pexels.com/photos/6069552/pexels-photo-6069552.jpeg?auto=compress&cs=tinysrgb&w=800',
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Check Out',
      'color': Color(0xFFE6F2FF),
      'image': 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg?auto=compress&cs=tinysrgb&w=800',
    },
    {
      'title': 'Season Sale',
      'subtitle': 'Limited Time',
      'color': Color(0xFFFFE6E6),
      'image': 'https://images.pexels.com/photos/4099354/pexels-photo-4099354.jpeg?auto=compress&cs=tinysrgb&w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlider();
    
    // Ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DecorProvider>(context, listen: false);
      if (provider.decorItems.isEmpty) {
        print("Triggering data reload in Home screen");
        provider.initializeData();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Find your favourite products",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _promotions.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: _promotions[index]['color'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _promotions[index]['title'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  _promotions[index]['subtitle'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Image.network(
                          _promotions[index]['image'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(),
        ),
      ],
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

  Widget _buildCategorySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Shop Categories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/categories');
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
            final categories = provider.categories;
            
            if (categories.isEmpty) {
              print("No categories found, showing shimmer");
              return _buildCategoryShimmer();
            }
            
            print("Building grid with ${categories.length} categories");
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              itemCount: categories.length > 8 ? 8 : categories.length,
              itemBuilder: (context, index) {
                Map category = categories[index];
                return _buildCategoryItem(category);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Map category) {
    // Function to get icon based on category name if no icon is provided
    IconData getIconForCategory(String categoryName) {
      switch(categoryName.toLowerCase()) {
        case 'living room':
          return Icons.weekend;
        case 'bedroom':
          return Icons.bed;
        case 'kitchen':
          return Icons.kitchen;
        case 'bathroom':
          return Icons.bathtub;
        case 'office':
          return Icons.computer;
        case 'dining room':
          return Icons.dinner_dining;
        case 'outdoor':
          return Icons.deck;
        default:
          return Icons.category;
      }
    }
    
    // Get the icon either from the provided icon code or fallback to name-based icon
    IconData iconData;
    try {
      if (category.containsKey('icon') && category['icon'] != null) {
        iconData = IconData(
          int.parse(category['icon']),
          fontFamily: 'MaterialIcons',
        );
      } else {
        iconData = getIconForCategory(category['name']);
      }
    } catch (e) {
      print("Error loading icon: $e");
      iconData = getIconForCategory(category['name']);
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: Theme.of(context).colorScheme.secondary,
            size: 28,
          ),
        ),
        SizedBox(height: 8),
        Text(
          category['name'],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 12,
                width: 60,
                color: Colors.white,
              ),
            ],
          );
        },
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

  Widget _buildProductItem(DecorItemModel item) {
    return GestureDetector(
      onTap: () {
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
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item.imageUrl ?? "",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
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
}

