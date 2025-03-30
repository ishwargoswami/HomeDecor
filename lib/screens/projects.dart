import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/decor_projects.dart';
import 'package:flutter_foodybite/widgets/project_card.dart';
import 'package:flutter_foodybite/widgets/search_card.dart';

class Projects extends StatelessWidget {
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
          child: ListView(
            children: <Widget>[
              buildSearchBar(context),
              SizedBox(height: 20.0),
              buildSortFilters(),
              SizedBox(height: 20.0),
              ...buildProjectsList(context),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: SearchCard(hintText: "Search projects..."),
    );
  }

  buildSortFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilterChip(
          label: Text('All'),
          selected: true,
          onSelected: (selected) {},
        ),
        FilterChip(
          label: Text('In Progress'),
          selected: false,
          onSelected: (selected) {},
        ),
        FilterChip(
          label: Text('Completed'),
          selected: false,
          onSelected: (selected) {},
        ),
      ],
    );
  }

  List<Widget> buildProjectsList(BuildContext context) {
    return List.generate(
      decorProjects.length,
      (index) {
        Map project = decorProjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: ProjectCard(
            name: project["name"],
            description: project["description"],
            progress: project["progress"],
            room: project["room"],
            img: project["img"],
            items: project["items"],
          ),
        );
      },
    );
  }
} 