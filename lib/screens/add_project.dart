import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:provider/provider.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedRoom = "Living Room";
  double _progress = 0.0;
  List<String> _selectedItems = [];

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

  List<String> _availableItems = [
    "Sofa", 
    "Coffee Table", 
    "TV Stand", 
    "End Table", 
    "Area Rug", 
    "Wall Art",
    "Lighting", 
    "Curtains/Blinds",
    "Bed Frame", 
    "Mattress", 
    "Nightstand", 
    "Dresser",
    "Kitchen Island", 
    "Cabinets", 
    "Backsplash", 
    "Countertops",
    "Appliances", 
    "Vanity", 
    "Shower Remodel", 
    "Tub",
    "Desk", 
    "Office Chair", 
    "Bookshelf", 
    "Filing Cabinet",
    "Dining Table", 
    "Dining Chairs", 
    "Buffet", 
    "China Cabinet",
    "Patio Furniture", 
    "Grill", 
    "Outdoor Lighting", 
    "Garden Beds"
  ];
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Project"),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
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
              
              // Room Type Dropdown
              _buildSectionTitle("Room Type"),
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
                    // Reset selected items when room changes
                    _selectedItems = [];
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Budget
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: 'Budget (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Progress Slider
              _buildSectionTitle("Initial Progress: ${(_progress * 100).toInt()}%"),
              SizedBox(height: 8),
              Slider(
                value: _progress,
                onChanged: (value) {
                  setState(() {
                    _progress = value;
                  });
                },
                activeColor: Constants.lightAccent,
              ),
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
              
              // Items Selection
              _buildSectionTitle("Items for Project"),
              SizedBox(height: 8),
              _buildItemsSelection(),
              SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.lightAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    "CREATE PROJECT",
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

  Widget _buildItemsSelection() {
    // Filter items based on selected room
    List<String> roomItems = _availableItems.where((item) {
      if (_selectedRoom == "Living Room") {
        return ["Sofa", "Coffee Table", "TV Stand", "End Table", "Area Rug", "Wall Art", "Lighting", "Curtains/Blinds"].contains(item);
      } else if (_selectedRoom == "Bedroom") {
        return ["Bed Frame", "Mattress", "Nightstand", "Dresser", "Area Rug", "Wall Art", "Lighting", "Curtains/Blinds"].contains(item);
      } else if (_selectedRoom == "Kitchen") {
        return ["Kitchen Island", "Cabinets", "Backsplash", "Countertops", "Appliances", "Lighting"].contains(item);
      } else if (_selectedRoom == "Bathroom") {
        return ["Vanity", "Shower Remodel", "Tub", "Toilet", "Lighting", "Fixtures"].contains(item);
      } else if (_selectedRoom == "Office") {
        return ["Desk", "Office Chair", "Bookshelf", "Filing Cabinet", "Lighting", "Wall Art"].contains(item);
      } else if (_selectedRoom == "Dining Room") {
        return ["Dining Table", "Dining Chairs", "Buffet", "China Cabinet", "Lighting", "Area Rug"].contains(item);
      } else if (_selectedRoom == "Outdoor") {
        return ["Patio Furniture", "Grill", "Outdoor Lighting", "Garden Beds"].contains(item);
      }
      return true; // For "Other" room
    }).toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: roomItems.map((item) {
        final isSelected = _selectedItems.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedItems.add(item);
              } else {
                _selectedItems.remove(item);
              }
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Constants.lightAccent.withOpacity(0.25),
          checkmarkColor: Constants.lightAccent,
          labelStyle: TextStyle(
            color: isSelected ? Constants.lightAccent : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
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

  void _createProject() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DecorProvider>(context, listen: false);
      
      final newProject = ProjectModel(
        name: _nameController.text,
        description: _descriptionController.text,
        room: _selectedRoom,
        imageUrl: _imageUrlController.text.isEmpty
            ? Constants.placeholderImage
            : _imageUrlController.text,
        progress: _progress,
        items: _selectedItems,
        budget: _budgetController.text.isEmpty
            ? 0.0
            : double.parse(_budgetController.text),
      );
      
      await provider.addProject(newProject);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project created successfully!'),
          backgroundColor: Constants.lightAccent,
        ),
      );
      
      Navigator.pop(context);
    }
  }
} 