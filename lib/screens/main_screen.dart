import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/add.dart';
import 'package:flutter_foodybite/screens/project_dashboard.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/profile.dart';
import 'package:flutter_foodybite/screens/projects.dart';
import 'package:flutter_foodybite/screens/inspiration.dart';
import 'package:flutter_foodybite/util/const.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _page = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;
  
  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.view_module_rounded,
    Icons.analytics_outlined,
    Icons.lightbulb_outline,
    Icons.person_outline,
  ];

  final List<String> labels = [
    "Home",
    "Projects",
    "Dashboard",
    "Inspiration",
    "Profile"
  ];

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    pages = [
      Home(),
      Projects(),
      ProjectDashboardScreen(),
      Inspiration(),
      Profile(),
    ];
    
    // Start animation after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final bool fromSplash = args != null && args['fromSplash'] == true;
      
      if (fromSplash) {
        setState(() {
          _isAnimating = true;
        });
        _animationController.forward().then((_) {
          setState(() {
            _isAnimating = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_page == index) return;
    
    setState(() {
      _page = index;
    });
    
    _animationController.reset();
    _animationController.forward();
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool fromSplash = args != null && args['fromSplash'] == true;
    
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: fromSplash && _isAnimating
            ? FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildMainContent(),
                ),
              )
            : _buildMainContent(),
        bottomNavigationBar: fromSplash && _isAnimating
            ? FadeTransition(
                opacity: _fadeInAnimation,
                child: _buildBottomNav(),
              )
            : _buildBottomNav(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: fromSplash && _isAnimating
            ? FadeTransition(
                opacity: _fadeInAnimation,
                child: _buildAnimatedFAB(),
              )
            : _buildAnimatedFAB(),
      ),
    );
  }
  
  Widget _buildMainContent() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: onPageChanged,
      children: pages,
    );
  }
  
  Widget _buildBottomNav() {
    return Container(
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Constants.darkPrimary
            : Colors.white,
        child: SizedBox(
          height: 56,
          child: Padding(
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
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _page == 2 
              ? 1.0 - _animationController.value * 0.2
              : 1.0,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            elevation: 8.0,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              if (_page == 2) {
                // If already on dashboard, navigate to Add screen
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => Add(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  ),
                );
              } else {
                // Otherwise just switch to dashboard
                _onItemTapped(2);
              }
            },
          ),
        );
      },
    );
  }

  Widget buildNavItem(int index) {
    bool isSelected = _page == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected 
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[index],
              size: 22,
              color: isSelected 
                  ? Theme.of(context).colorScheme.secondary 
                  : Colors.grey[400],
            ),
            SizedBox(height: 4),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 11,
                color: isSelected 
                    ? Theme.of(context).colorScheme.secondary 
                    : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
