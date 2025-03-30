import 'package:flutter/material.dart';
import 'package:flutter_foodybite/widgets/search_card.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Inspiration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Design Inspiration"),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            buildSearchBar(context),
            SizedBox(height: 20.0),
            buildCategoryFilters(),
            SizedBox(height: 20.0),
            buildInspirationGrid(context),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: SearchCard(hintText: "Search inspiration..."),
    );
  }

  buildCategoryFilters() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildFilterChip('All'),
          buildFilterChip('Modern'),
          buildFilterChip('Minimalist'),
          buildFilterChip('Rustic'),
          buildFilterChip('Scandinavian'),
          buildFilterChip('Industrial'),
          buildFilterChip('Bohemian'),
        ],
      ),
    );
  }

  Widget buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: label == 'All',
        onSelected: (selected) {},
      ),
    );
  }

  Widget buildInspirationGrid(BuildContext context) {
    // For now, we'll use the categories list for demo purposes
    // In a real app, you'd have a dedicated inspiration images list
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return buildInspirationCard(categories[index]["img"], index % 2 == 0 ? 200.0 : 250.0);
      },
    );
  }

  Widget buildInspirationCard(String imageUrl, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: IconButton(
                icon: Icon(Icons.bookmark_border, size: 18),
                color: Colors.black,
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 