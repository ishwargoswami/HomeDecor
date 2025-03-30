import 'package:flutter/material.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/widgets/search_card.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class Inspiration extends StatefulWidget {
  @override
  _InspirationState createState() => _InspirationState();
}

class _InspirationState extends State<Inspiration> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  // Sample inspiration images (these could be loaded from a provider in a real app)
  final List<Map<String, dynamic>> _inspirationItems = [
    {
      'image': 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg',
      'category': 'Modern',
    },
    {
      'image': 'https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg',
      'category': 'Minimalist',
    },
    {
      'image': 'https://images.pexels.com/photos/276724/pexels-photo-276724.jpeg',
      'category': 'Rustic',
    },
    {
      'image': 'https://images.pexels.com/photos/1457842/pexels-photo-1457842.jpeg',
      'category': 'Scandinavian',
    },
    {
      'image': 'https://images.pexels.com/photos/276583/pexels-photo-276583.jpeg',
      'category': 'Industrial',
    },
    {
      'image': 'https://images.pexels.com/photos/2079246/pexels-photo-2079246.jpeg',
      'category': 'Bohemian',
    },
    {
      'image': 'https://images.pexels.com/photos/1918291/pexels-photo-1918291.jpeg',
      'category': 'Modern',
    },
    {
      'image': 'https://images.pexels.com/photos/1643383/pexels-photo-1643383.jpeg',
      'category': 'Minimalist',
    },
    {
      'image': 'https://images.pexels.com/photos/1454806/pexels-photo-1454806.jpeg',
      'category': 'Rustic',
    },
    {
      'image': 'https://images.pexels.com/photos/2440471/pexels-photo-2440471.jpeg',
      'category': 'Scandinavian',
    },
  ];

  // Get filtered inspiration items
  List<Map<String, dynamic>> get filteredItems {
    return _inspirationItems.where((item) {
      // Apply category filter
      if (_selectedCategory != 'All' && item['category'] != _selectedCategory) {
        return false;
      }
      
      // Apply search filter (if implemented)
      if (_searchQuery.isNotEmpty) {
        return item['category'].toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Design Inspiration"),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            buildSearchBar(context),
            SizedBox(height: 20.0),
            buildCategoryFilters(),
            SizedBox(height: 20.0),
            filteredItems.isEmpty
                ? _buildEmptyState()
                : buildInspirationGrid(context),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "No inspiration found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? "Try a different search term"
                : "Try a different category",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: SearchCard(
        hintText: "Search inspiration...",
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  buildCategoryFilters() {
    // Get categories from provider
    final categories = ['All', 'Modern', 'Minimalist', 'Rustic', 'Scandinavian', 'Industrial', 'Bohemian'];
    
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) => buildFilterChip(category)).toList(),
      ),
    );
  }

  Widget buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: label == _selectedCategory,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = label;
            });
          }
        },
      ),
    );
  }

  Widget buildInspirationGrid(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: filteredItems.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return buildInspirationItem(filteredItems[index], index);
      },
    );
  }
  
  Widget buildInspirationItem(Map<String, dynamic> item, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: index % 2 == 0 ? 200 : 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item['image'],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey[500],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  item['category'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 