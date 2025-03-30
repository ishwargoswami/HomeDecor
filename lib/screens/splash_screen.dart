import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/login_screen.dart';
import 'package:flutter_foodybite/screens/main_screen.dart';
import 'package:flutter_foodybite/services/auth_provider.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:flutter_foodybite/widgets/trending_loader.dart';
import 'package:flutter_foodybite/widgets/animated_text.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation for the icon
    _iconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );
    
    _iconController.forward();
    
    _checkIfLoggedIn();
  }
  
  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  _checkIfLoggedIn() async {
    // Add a delay to show splash screen
    await Future.delayed(Duration(seconds: 3)); // Extended delay to show animation
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isLoggedIn = await authProvider.isLoggedIn();
    
    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.secondary;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeColor,
                  themeColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
          
          // Decorative elements
          Positioned(
            top: screenSize.height * 0.1,
            left: screenSize.width * 0.1,
            child: _buildDecorativeBox(Colors.white.withOpacity(0.1), 60),
          ),
          Positioned(
            bottom: screenSize.height * 0.05,
            right: screenSize.width * 0.05,
            child: _buildDecorativeBox(Colors.white.withOpacity(0.15), 80),
          ),
          Positioned(
            top: screenSize.height * 0.2,
            right: screenSize.width * 0.15,
            child: _buildDecorativeBox(Colors.white.withOpacity(0.08), 40),
          ),
          Positioned(
            bottom: screenSize.height * 0.2,
            left: screenSize.width * 0.2,
            child: _buildDecorativeBox(Colors.white.withOpacity(0.12), 50),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated home icon
                ScaleTransition(
                  scale: _iconAnimation,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                
                // Animated app name
                AnimatedText(
                  text: Constants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                
                SizedBox(height: 10),
                
                // Subtitle with animation
                AnimatedText(
                  text: "Design your dream space",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                  duration: Duration(milliseconds: 2500),
                ),
                
                SizedBox(height: 40),
                
                // Custom trending loader
                TrendingLoader(
                  primaryColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  size: 180,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDecorativeBox(Color color, double size) {
    return Transform.rotate(
      angle: size % 100 / 100, // slight random rotation
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 