import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_foodybite/services/storage_service.dart';

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
  
  File? _imageFile;
  bool _isUploading = false;

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
              
              // Image Preview
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
        Text(
          'Project Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : _imageUrlController.text.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Invalid image URL',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap to add an image',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
        SizedBox(height: 8),
        if (_imageFile != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Image selected',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                  });
                },
                child: Text('Clear'),
              ),
            ],
          ),
        SizedBox(height: 8),
        Text(
          'OR',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _imageUrlController,
          decoration: InputDecoration(
            labelText: 'Image URL',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          onChanged: (_) {
            // Force update to show the image preview
            setState(() {});
          },
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _createProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });
      
      try {
        final provider = Provider.of<DecorProvider>(context, listen: false);
        
        // Handle image upload if an image file is selected
        String? imageUrl = _imageUrlController.text;
        
        if (_imageFile != null) {
          final storageService = StorageService();
          final uploadedUrl = await storageService.uploadImage(
            _imageFile!,
            'project_images',
          );
          
          if (uploadedUrl != null) {
            imageUrl = uploadedUrl;
          }
        }
        
        final newProject = ProjectModel(
          name: _nameController.text,
          description: _descriptionController.text,
          room: _selectedRoom,
          imageUrl: imageUrl.isEmpty ? Constants.placeholderImage : imageUrl,
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
} 