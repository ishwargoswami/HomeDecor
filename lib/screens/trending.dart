import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/decor_items.dart';
import 'package:flutter_foodybite/widgets/search_card.dart';
import 'package:flutter_foodybite/widgets/trending_item.dart';

class Trending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Trending Decor Items"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10.0,
        ),
        child: ListView(
          children: <Widget>[
            SearchCard(hintText: "Search decor items..."),
            SizedBox(height: 10.0),
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: decorItems == null ? 0 : decorItems.length,
              itemBuilder: (BuildContext context, int index) {
                Map item = decorItems[index];

                return TrendingItem(
                  img: item["img"],
                  title: item["title"],
                  address: item["address"],
                  rating: item["rating"],
                );
              },
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
