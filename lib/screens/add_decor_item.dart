import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/decor_item_model.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:provider/provider.dart';

class AddDecorItemScreen extends StatefulWidget {
  @override
  _AddDecorItemScreenState createState() => _AddDecorItemScreenState();
}

class _AddDecorItemScreenState extends State<AddDecorItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = "Furniture";
  String _selectedRoom = "Living Room";
  double _rating = 4.5;

  List<String> _categories = [
    "Furniture", 
    "Lighting", 
    "Décor", 
    "Storage", 
    "Textiles", 
    "Appliances", 
    "Fixtures", 
    "Outdoor"
  ];

  List<String> _rooms = [
    "Living Room", 
    "Bedroom", 
    "Kitchen", 
    "Bathroom", 
    "Office", 
    "Dining Room", 
    "Outdoor", 
    "Other"
  ];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Item"),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Category Dropdown
              _buildSectionTitle("Category"),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Room Dropdown
              _buildSectionTitle("Room"),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: _selectedRoom,
                items: _rooms.map<DropdownMenuItem<String>>((room) {
                  return DropdownMenuItem<String>(
                    value: room,
                    child: Text(room),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoom = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Rating
              _buildSectionTitle("Rating"),
              SizedBox(height: 8),
              _buildRatingSelector(),
              SizedBox(height: 16),
              
              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty to use a placeholder image',
                ),
              ),
              SizedBox(height: 24),
              
              // Image Preview
              if (_imageUrlController.text.isNotEmpty)
                _buildImagePreview(),
              SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addDecorItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.lightAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    "ADD ITEM",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _rating,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            activeColor: Constants.lightAccent,
            label: _rating.toString(),
            onChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Constants.lightAccent,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            children: [
              Text(
                _rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Image Preview"),
        SizedBox(height: 8.0),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              _imageUrlController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Invalid image URL",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _addDecorItem() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DecorProvider>(context, listen: false);
      
      final newItem = DecorItemModel(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        room: _selectedRoom,
        imageUrl: _imageUrlController.text.isEmpty
            ? Constants.placeholderImage
            : _imageUrlController.text,
        price: double.parse(_priceController.text),
        rating: _rating,
      );
      
      await provider.addDecorItem(newItem);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: Constants.lightAccent,
        ),
      );
      
      Navigator.pop(context);
    }
  }
} 