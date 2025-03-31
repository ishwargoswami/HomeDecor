import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/screens/project_details.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final double progress;
  final String room;
  final String img;
  final List<dynamic> items;
  final double? budget;
  final String? userId;

  ProjectCard({
    this.id = "",
    required this.name,
    required this.description,
    required this.progress,
    required this.room,
    required this.img,
    required this.items,
    this.budget,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProjectDetails(
                id: id,
                name: name,
                description: description,
                progress: progress,
                room: room,
                img: img,
                items: items,
                budget: budget,
              );
            },
          ),
        );
      },
      onLongPress: () {
        _showProjectOptions(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Project image
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(img),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        return;
                      },
                    ),
                  ),
                ),
                // Action buttons
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.edit,
                        onTap: () => _showUpdateProgressDialog(context),
                      ),
                      SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        icon: Icons.add_task,
                        onTap: () => _showAddItemDialog(context),
                      ),
                    ],
                  ),
                ),
                // Progress indicator overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${(progress * 100).toInt()}% complete",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (budget != null)
                              Text(
                                "\$${budget!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        LinearPercentIndicator(
                          lineHeight: 5.0,
                          percent: progress,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          progressColor: progress == 1.0
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                          barRadius: Radius.circular(3),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Project details
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          room,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  // Items chips
                  _buildItemsChips(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsChips(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        "No items added yet",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: items.take(3).map<Widget>((item) {
        return Chip(
          label: Text(
            item.toString(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList() + (items.length > 3
          ? [
              Chip(
                label: Text(
                  "+${items.length - 3} more",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.grey,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              )
            ]
          : []),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 18,
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context) {
    double updatedProgress = progress;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(updatedProgress * 100).toInt()}%'),
                  Slider(
                    value: updatedProgress,
                    onChanged: (value) {
                      setState(() {
                        updatedProgress = value;
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(updatedProgress * 100).toInt()}%',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Update'),
                  onPressed: () {
                    _updateProjectProgress(context, updatedProgress);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item to Project'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addItemToProject(context, controller.text);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showProjectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Progress'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateProgressDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.add_task),
                title: Text('Add Item'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddItemDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ProjectDetails(
                          id: id,
                          name: name,
                          description: description,
                          progress: progress,
                          room: room,
                          img: img,
                          items: items,
                          budget: budget,
                        );
                      },
                    ),
                  );
                },
              ),
              if (progress != 1.0)
                ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Mark as Complete'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateProjectProgress(context, 1.0);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _updateProjectProgress(BuildContext context, double updatedProgress) {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update project: No project ID'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final provider = Provider.of<DecorProvider>(context, listen: false);
    
    final updatedProject = ProjectModel(
      id: id,
      name: name,
      description: description,
      room: room,
      imageUrl: img,
      progress: updatedProgress,
      items: items.cast<String>(),
      budget: budget,
      userId: userId,
    );
    
    provider.updateProject(updatedProject);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project progress updated to ${(updatedProgress * 100).toInt()}%'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addItemToProject(BuildContext context, String itemName) {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add item: No project ID'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final provider = Provider.of<DecorProvider>(context, listen: false);
    
    provider.addItemToProject(id, itemName);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item "$itemName" added to project'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 