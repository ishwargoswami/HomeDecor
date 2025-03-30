import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class ProjectDetails extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final double progress;
  final String room;
  final String img;
  final List<dynamic> items;
  final double? budget;

  ProjectDetails({
    this.id = "",
    required this.name,
    required this.description,
    required this.progress,
    required this.room,
    required this.img,
    required this.items,
    this.budget,
  });

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  late String _id;
  late double _progress;
  late List<dynamic> _items;
  late double? _budget;
  List<dynamic> _completedItems = [];
  bool _isEditing = false;
  
  final TextEditingController _addItemController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    _progress = widget.progress;
    _items = List.from(widget.items);
    _budget = widget.budget;
    
    if (_budget != null) {
      _budgetController.text = _budget!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _addItemController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.name),
              background: Image.network(
                widget.img,
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
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;

                    if (!_isEditing && _id.isNotEmpty) {
                      // Save changes to provider
                      _saveChanges();
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: _id.isNotEmpty ? _showDeleteDialog : null,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Room and Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              widget.room,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                          _isEditing
                              ? _buildProgressEditor()
                              : Text(
                                  "Progress: ${(_progress * 100).toInt()}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      
                      // Progress bar
                      LinearPercentIndicator(
                        lineHeight: 14.0,
                        percent: _progress,
                        backgroundColor: Colors.grey[200],
                        progressColor: _progress == 1.0
                            ? Colors.green
                            : Theme.of(context).colorScheme.secondary,
                        barRadius: Radius.circular(7),
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(height: 16.0),
                      
                      // Budget section
                      _buildBudgetSection(),
                      SizedBox(height: 16.0),
                      
                      // Description
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      
                      // Items section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Items (${_items.length})",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isEditing)
                            TextButton.icon(
                              icon: Icon(Icons.add),
                              label: Text("Add Item"),
                              onPressed: () {
                                _showAddItemDialog();
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      
                      // Items list
                      ..._buildItemsList(),
                      SizedBox(height: 32.0),
                      
                      // Complete button
                      if (!_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: _progress == 1.0 
                                  ? Colors.green 
                                  : Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if (_progress == 1.0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Project is already complete!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  _progress = 1.0;
                                });
                                if (_id.isNotEmpty) {
                                  _saveChanges();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Project marked as complete!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _progress == 1.0 ? "COMPLETED" : "MARK AS COMPLETE",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildProgressEditor() {
    return Container(
      width: 150,
      child: Row(
        children: [
          Text(
            "${(_progress * 100).toInt()}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Slider(
              value: _progress,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _progress = value;
                });
              },
              activeColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Budget",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isEditing)
                  Container(
                    width: 120,
                    child: TextField(
                      controller: _budgetController,
                      decoration: InputDecoration(
                        prefixText: "\$",
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _budget = double.tryParse(value) ?? _budget;
                        }
                      },
                    ),
                  )
                else
                  Text(
                    "\$${_budget?.toStringAsFixed(0) ?? 'Not Set'}",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
            if (_budget != null && _budget! > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Estimated total items cost:"),
                      Text(
                        "\$${(_budget! * 0.9).toStringAsFixed(0)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Estimated labor cost:"),
                      Text(
                        "\$${(_budget! * 0.1).toStringAsFixed(0)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Divider(),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Per item budget:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${_items.isEmpty ? '0' : ((_budget! * 0.9) / _items.length).toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemsList() {
    return _items.map((item) {
      final isCompleted = _completedItems.contains(item);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: ListTile(
            title: Text(
              item.toString(),
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isCompleted) {
                        _completedItems.remove(item);
                      } else {
                        _completedItems.add(item);
                      }
                      
                      // Update progress based on completed items
                      if (_items.isNotEmpty) {
                        _progress = _completedItems.length / _items.length;
                      }
                    });
                    
                    if (_id.isNotEmpty) {
                      _saveChanges();
                    }
                  },
                ),
                if (_isEditing)
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _items.remove(item);
                        if (_completedItems.contains(item)) {
                          _completedItems.remove(item);
                        }
                        
                        // Update progress
                        if (_items.isNotEmpty) {
                          _progress = _completedItems.length / _items.length;
                        }
                      });
                      
                      if (_id.isNotEmpty) {
                        final provider = Provider.of<DecorProvider>(context, listen: false);
                        provider.removeItemFromProject(_id, item.toString());
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Item to Project"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _addItemController,
                    decoration: InputDecoration(
                      labelText: "Item Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text("Or select from common items:"),
                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _getCommonItemsForRoom().map((item) {
                      return ActionChip(
                        label: Text(item),
                        onPressed: () {
                          _addItemController.text = item;
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addItemController.clear();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Add"),
                  onPressed: () {
                    if (_addItemController.text.isNotEmpty) {
                      setState(() {
                        _items.add(_addItemController.text);
                        
                        // Update progress
                        if (_items.isNotEmpty) {
                          _progress = _completedItems.length / _items.length;
                        }
                      });
                      
                      if (_id.isNotEmpty) {
                        final provider = Provider.of<DecorProvider>(context, listen: false);
                        provider.addItemToProject(_id, _addItemController.text);
                      }
                      
                      Navigator.of(context).pop();
                      _addItemController.clear();
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Project"),
          content: Text("Are you sure you want to delete this project? This action cannot be undone."),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Delete"),
              onPressed: () {
                final provider = Provider.of<DecorProvider>(context, listen: false);
                provider.deleteProject(_id);
                
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Project deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<String> _getCommonItemsForRoom() {
    switch (widget.room) {
      case "Living Room":
        return ["Sofa", "Coffee Table", "TV Stand", "End Table", "Area Rug", "Wall Art", "Curtains"];
      case "Bedroom":
        return ["Bed Frame", "Mattress", "Nightstand", "Dresser", "Mirror", "Accent Chair"];
      case "Kitchen":
        return ["Cabinets", "Countertops", "Backsplash", "Appliances", "Island", "Lighting"];
      case "Bathroom":
        return ["Vanity", "Mirror", "Shower", "Bathtub", "Toilet", "Tiles"];
      case "Office":
        return ["Desk", "Chair", "Bookshelf", "File Cabinet", "Lamp", "Rug"];
      case "Dining Room":
        return ["Dining Table", "Chairs", "Buffet", "Chandelier", "China Cabinet"];
      case "Outdoor":
        return ["Patio Set", "Grill", "Lounge Chairs", "Fire Pit", "Planters"];
      default:
        return ["Chair", "Table", "Shelf", "Lighting", "Decor", "Storage"];
    }
  }

  void _saveChanges() {
    final provider = Provider.of<DecorProvider>(context, listen: false);
    
    double? budget = null;
    if (_budgetController.text.isNotEmpty) {
      budget = double.tryParse(_budgetController.text);
    }
    
    final updatedProject = ProjectModel(
      id: _id,
      name: widget.name,
      description: widget.description,
      room: widget.room,
      imageUrl: widget.img,
      progress: _progress,
      items: List<String>.from(_items),
      budget: budget,
    );
    
    provider.updateProject(updatedProject);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project updated successfully!'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
} 