import 'package:flutter/material.dart';
import 'package:decor_home/models/project_model.dart';
import 'package:decor_home/services/decor_provider.dart';
import 'package:decor_home/widgets/project_card.dart';
import 'package:decor_home/widgets/search_card.dart';
import 'package:provider/provider.dart';

class Projects extends StatefulWidget {
  @override
  _ProjectsState createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  String _selectedFilter = "All";
  String _searchQuery = "";

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
        appBar: AppBar(
          title: Text("My Projects"),
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          child: Consumer<DecorProvider>(
            builder: (context, provider, child) {
              // Get all projects from provider
              List<ProjectModel> allProjects = provider.projects;
              
              // Filter projects based on search query and selected filter
              List<ProjectModel> filteredProjects = _filterProjects(allProjects);
              
              return ListView(
                children: <Widget>[
                  buildSearchBar(context),
                  SizedBox(height: 20.0),
                  buildSortFilters(),
                  SizedBox(height: 20.0),
                  filteredProjects.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: buildProjectsList(context, filteredProjects),
                        ),
                  SizedBox(height: 30.0),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "No projects found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? "Try a different search term"
                : "Try a different filter",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Filter projects based on search query and selected filter
  List<ProjectModel> _filterProjects(List<ProjectModel> projects) {
    return projects.where((project) {
      // Apply progress filter
      if (_selectedFilter == "In Progress" && (project.progress ?? 0) >= 1.0) {
        return false;
      }
      if (_selectedFilter == "Completed" && (project.progress ?? 0) < 1.0) {
        return false;
      }
      
      // Apply search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return project.name!.toLowerCase().contains(query) ||
               project.description!.toLowerCase().contains(query) ||
               project.room!.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }

  buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: SearchCard(
        hintText: "Search projects...",
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  buildSortFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilterChip(
          label: Text('All'),
          selected: _selectedFilter == "All",
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedFilter = "All";
              });
            }
          },
        ),
        FilterChip(
          label: Text('In Progress'),
          selected: _selectedFilter == "In Progress",
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedFilter = "In Progress";
              });
            }
          },
        ),
        FilterChip(
          label: Text('Completed'),
          selected: _selectedFilter == "Completed",
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedFilter = "Completed";
              });
            }
          },
        ),
      ],
    );
  }

  List<Widget> buildProjectsList(BuildContext context, List<ProjectModel> projects) {
    return List.generate(
      projects.length,
      (index) {
        ProjectModel project = projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: ProjectCard(
            id: project.id ?? "",
            name: project.name!,
            description: project.description!,
            progress: project.progress!,
            room: project.room!,
            img: project.imageUrl!,
            items: project.items ?? [],
            budget: project.budget,
            userId: project.userId,
          ),
        );
      },
    );
  }
} 
