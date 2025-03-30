import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/add.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/label.dart';
import 'package:flutter_foodybite/screens/profile.dart';
import 'package:flutter_foodybite/screens/projects.dart';
import 'package:flutter_foodybite/screens/inspiration.dart';

import 'notifications.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _page = 0;

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.view_module_rounded,
    Icons.add,
    Icons.lightbulb_outline,
    Icons.person_outline,
  ];

  final List<String> labels = [
    "Home",
    "Projects",
    "Add",
    "Inspiration",
    "Profile"
  ];

  List<Widget> pages = [
    Home(),
    Projects(),
    Add(),
    Inspiration(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(5, (index) => pages[index]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          notchMargin: 10,
          shape: CircularNotchedRectangle(),
          color: Colors.white,
          child: Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildNavItem(0),
                buildNavItem(1),
                SizedBox(width: 40), // Space for FAB
                buildNavItem(3),
                buildNavItem(4),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 8.0,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => _pageController.jumpToPage(2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  Widget buildNavItem(int index) {
    bool isSelected = _page == index;
    return InkWell(
      onTap: () => _pageController.jumpToPage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icons[index],
            size: 24,
            color: isSelected 
                ? Theme.of(context).colorScheme.secondary 
                : Colors.grey[400],
          ),
          SizedBox(height: 4),
          Text(
            labels[index],
            style: TextStyle(
              fontSize: 12,
              color: isSelected 
                  ? Theme.of(context).colorScheme.secondary 
                  : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
