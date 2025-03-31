import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/screens/project_details.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class ProjectPreview extends StatelessWidget {
  final ProjectModel project;

  ProjectPreview({
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProjectDetails(
                id: project.id ?? "",
                name: project.name ?? "",
                description: project.description ?? "",
                progress: project.progress ?? 0.0,
                room: project.room ?? "",
                img: project.imageUrl ?? "",
                items: project.items ?? [],
                budget: project.budget,
              );
            },
          ),
        );
      },
      onLongPress: () {
        _showProjectOptions(context);
      },
      child: Container(
        width: 250,
        height: 200,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project image
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(project.imageUrl ?? ""),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        return;
                      },
                    ),
                  ),
                ),
                // Action buttons
                Positioned(
                  top: 5,
                  right: 5,
                  child: Row(
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.edit,
                        onTap: () => _showUpdateProgressDialog(context),
                      ),
                      SizedBox(width: 5),
                      _buildActionButton(
                        context,
                        icon: Icons.add_task,
                        onTap: () => _showAddItemDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Project details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          project.name ?? "",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          project.room ?? "",
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    project.description ?? "",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress: ${((project.progress ?? 0.0) * 100).toInt()}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      if (project.budget != null)
                        Text(
                          "\$${project.budget!.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearPercentIndicator(
                    lineHeight: 6.0,
                    percent: project.progress ?? 0.0,
                    backgroundColor: Colors.grey[200],
                    progressColor: (project.progress ?? 0.0) == 1.0
                        ? Colors.green
                        : Theme.of(context).colorScheme.secondary,
                    barRadius: Radius.circular(3),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 4),
                  // Show item count
                  Text(
                    "${project.items?.length ?? 0} items",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 16,
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context) {
    double updatedProgress = project.progress ?? 0.0;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(updatedProgress * 100).toInt()}%'),
              Slider(
                value: updatedProgress,
                onChanged: (value) {
                  updatedProgress = value;
                  // Rebuild the dialog to show updated percentage
                  (context as Element).markNeedsBuild();
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
                          id: project.id ?? "",
                          name: project.name ?? "",
                          description: project.description ?? "",
                          progress: project.progress ?? 0.0,
                          room: project.room ?? "",
                          img: project.imageUrl ?? "",
                          items: project.items ?? [],
                          budget: project.budget,
                        );
                      },
                    ),
                  );
                },
              ),
              if (project.progress != 1.0)
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

  void _updateProjectProgress(BuildContext context, double progress) {
    final provider = Provider.of<DecorProvider>(context, listen: false);
    
    final updatedProject = ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      room: project.room,
      imageUrl: project.imageUrl,
      progress: progress,
      items: project.items,
      budget: project.budget,
      userId: project.userId,
    );
    
    provider.updateProject(updatedProject);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project progress updated to ${(progress * 100).toInt()}%'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addItemToProject(BuildContext context, String itemName) {
    final provider = Provider.of<DecorProvider>(context, listen: false);
    
    provider.addItemToProject(project.id ?? "", itemName);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item "$itemName" added to project'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 