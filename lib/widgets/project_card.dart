import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/project_details.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProjectCard extends StatelessWidget {
  final String name;
  final String description;
  final double progress;
  final String room;
  final String img;
  final List<dynamic> items;

  ProjectCard({
    required this.name,
    required this.description,
    required this.progress,
    required this.room,
    required this.img,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProjectDetails(
                name: name,
                description: description,
                progress: progress,
                room: room,
                img: img,
                items: items,
              );
            },
          ),
        );
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
            // Project details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          room,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Progress: ${(progress * 100).toInt()}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 10.0,
                    percent: progress,
                    backgroundColor: Colors.grey[200],
                    progressColor: Theme.of(context).colorScheme.secondary,
                    barRadius: Radius.circular(5),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Items (${items.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: items
                        .map((item) => Chip(
                              label: Text(
                                item,
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 