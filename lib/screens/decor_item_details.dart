import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/decor_item_model.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:provider/provider.dart';

class DecorItemDetails extends StatefulWidget {
  final String? img;
  final String? title;
  final String? address;
  final String? rating;
  final DecorItemModel? item;

  DecorItemDetails({
    this.img,
    this.title,
    this.address,
    this.rating,
    this.item,
  });

  @override
  _DecorItemDetailsState createState() => _DecorItemDetailsState();
}

class _DecorItemDetailsState extends State<DecorItemDetails> {
  String? _selectedProjectId;
  
  @override
  Widget build(BuildContext context) {
    final DecorItemModel item = widget.item ?? 
      DecorItemModel(
        id: "",
        title: widget.title,
        description: widget.address,
        imageUrl: widget.img,
        rating: widget.rating != null ? double.tryParse(widget.rating!) : null,
      );
      
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                item.imageUrl ?? "",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 50,
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title ?? "",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "${item.rating?.toStringAsFixed(1) ?? "0.0"}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(width: 4.0),
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      if (item.price != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "\$${item.price!.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      Text(
                        item.description ?? "",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Divider(height: 32.0),
                      
                      // Category and Room
                      Row(
                        children: [
                          if (item.category != null)
                            Chip(
                              label: Text(
                                item.category!,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                            ),
                          SizedBox(width: 8),
                          if (item.room != null)
                            Chip(
                              label: Text(
                                item.room!,
                                style: TextStyle(color: Colors.white70),
                              ),
                              backgroundColor: Colors.grey[700],
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 24.0),
                      Text(
                        "Product Details",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        item.description ?? 
                          "This stylish and high-quality ${item.title?.toLowerCase() ?? ''} will transform your space with its elegant design and durable construction. Perfect for any home that values both aesthetics and functionality.",
                        style: TextStyle(
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Text(
                        "Specifications",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      buildSpecificationRow("Material", "Premium quality"),
                      buildSpecificationRow("Dimensions", "Custom sized"),
                      if (item.category != null)
                        buildSpecificationRow("Category", item.category!),
                      if (item.room != null)
                        buildSpecificationRow("Room", item.room!),
                      SizedBox(height: 24.0),
                      
                      // Add to project section
                      Text(
                        "Add to Project",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _buildProjectSelector(),
                      SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _selectedProjectId != null ? _addToProject : null,
                          child: Text(
                            "ADD TO PROJECT",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSpecificationRow(String property, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            property,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectSelector() {
    return Consumer<DecorProvider>(
      builder: (context, provider, child) {
        final projects = provider.projects;
        
        if (projects.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You don't have any projects yet.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.0),
              TextButton.icon(
                icon: Icon(Icons.add),
                label: Text("Create a Project"),
                onPressed: () {
                  Navigator.pushNamed(context, '/add_project');
                },
              ),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select a project",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              value: _selectedProjectId,
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                });
              },
              items: projects.map((project) {
                return DropdownMenuItem<String>(
                  value: project.id,
                  child: Text(project.name ?? "Unnamed Project"),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
  
  void _addToProject() {
    if (_selectedProjectId == null) return;
    
    final provider = Provider.of<DecorProvider>(context, listen: false);
    final DecorItemModel item = widget.item ?? 
      DecorItemModel(
        id: "",
        title: widget.title,
        description: widget.address,
        imageUrl: widget.img,
        rating: widget.rating != null ? double.tryParse(widget.rating!) : null,
      );
      
    provider.addItemToProject(_selectedProjectId!, item.title ?? "Item");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to your project!'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
} 