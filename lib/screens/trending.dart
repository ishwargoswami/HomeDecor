import 'package:flutter/material.dart';
import 'package:decor_home/models/decor_item_model.dart';
import 'package:decor_home/services/decor_provider.dart';
import 'package:decor_home/widgets/search_card.dart';
import 'package:decor_home/widgets/trending_item.dart';
import 'package:provider/provider.dart';

class Trending extends StatefulWidget {
  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Trending Decor Items"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10.0,
        ),
        child: Consumer<DecorProvider>(
          builder: (context, provider, child) {
            // Get filtered items from provider
            List<DecorItemModel> items = provider.decorItems;
            
            // Apply local search filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              items = items.where((item) => 
                item.title!.toLowerCase().contains(query) ||
                item.description!.toLowerCase().contains(query)
              ).toList();
            }
            
            return ListView(
              children: <Widget>[
                SearchCard(
                  hintText: "Search decor items...",
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                items.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          DecorItemModel item = items[index];

                          return TrendingItem(
                            img: item.imageUrl!,
                            title: item.title!,
                            address: item.description!,
                            rating: item.rating.toString(),
                          );
                        },
                      ),
                SizedBox(height: 10.0),
              ],
            );
          },
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
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try a different search term",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

