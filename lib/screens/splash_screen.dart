import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decor_home/services/auth_provider.dart';
import 'package:decor_home/services/cart_service.dart';
import 'package:decor_home/util/const.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _exitAnimation;
  late Animation<double> _finalPopAnimation;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1, 0.6, curve: Curves.elasticOut),
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 0.7, curve: Curves.easeOut),
    ));
    
    _finalPopAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.75, 0.85, curve: Curves.elasticInOut),
    ));
    
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.75, 0.78, curve: Curves.easeOut),
    ));

    _exitAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.85, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToNextScreen() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isLoggedIn = await authProvider.isLoggedIn();
    
    // Initialize cart service
    final cartService = Provider.of<CartService>(context, listen: false);
    await cartService.initializeCart();
    
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
        arguments: {'fromSplash': true},
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
        arguments: {'fromSplash': true},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.darkestColor,
      body: FadeTransition(
        opacity: _exitAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Constants.darkestColor,  // Brunswick green (darkest)
                Constants.darkAccentColor,  // Hunter green (dark accent)
                Constants.midColor,  // Fern green (mid)
              ],
              stops: [0.2, 0.5, 0.8],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Animated background elements
                ...List.generate(5, (index) => _buildFloatingIcon(index)),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(flex: 2),
                      // Logo container with animations
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _finalPopAnimation,
                          builder: (context, child) {
                            // Create a slight pulse with shadow expansion when popping
                            final bool isPopping = _controller.value >= 0.75 && _controller.value <= 0.85;
                            final bool isFlashing = _controller.value >= 0.75 && _controller.value <= 0.78;
                            final double flashOpacity = isFlashing ? _flashAnimation.value : 0.0;
                            
                            return Stack(
                              children: [
                                // The main icon with scale effect
                                Transform.scale(
                                  scale: _controller.value >= 0.75 ? _finalPopAnimation.value : 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        if (isPopping)
                                          BoxShadow(
                                            color: Constants.lightestColor.withOpacity(0.3),
                                            blurRadius: 30,
                                            spreadRadius: 10,
                                          ),
                                      ],
                                    ),
                                    child: RotationTransition(
                                      turns: _rotateAnimation,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Constants.lightAccentColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Constants.lightAccentColor.withOpacity(0.1),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Constants.lightAccentColor.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Icon(
                                                Icons.home_rounded,
                                                size: 60,
                                                color: Constants.lightestColor.withOpacity(0.9),
                                              ),
                                            ),
                                            Center(
                                              child: Icon(
                                                Icons.design_services_rounded,
                                                size: 30,
                                                color: Constants.lightAccentColor.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // The flash overlay
                                if (isFlashing)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Constants.lightestColor.withOpacity(flashOpacity * 0.5),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 40),
                      // Animated text
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: DefaultTextStyle(
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Constants.lightestColor,
                            letterSpacing: 1.5,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'DecorHome',
                                speed: Duration(milliseconds: 150),
                              ),
                            ],
                            repeatForever: false,
                            totalRepeatCount: 1,
                            pause: Duration(milliseconds: 1000),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Transform Your Space',
                          style: GoogleFonts.poppins(
                            color: Constants.lightAccentColor,
                            fontSize: 16,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Spacer(),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(int index) {
    final random = index * 0.2;
    return Positioned(
      top: 100.0 + (index * 150),
      right: index.isEven ? -20 : null,
      left: index.isEven ? null : -20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: index.isEven 
              ? Offset(-1 - random, 0)
              : Offset(1 + random, 0),
            end: index.isEven
              ? Offset(1 + random, 0)
              : Offset(-1 - random, 0),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                0.2,
                0.8,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Icon(
            _getIconData(index),
            size: 40 - (index * 4),
            color: Constants.lightAccentColor.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(int index) {
    final icons = [
      Icons.chair_rounded,
      Icons.table_restaurant_rounded,
      Icons.light_rounded,
      Icons.bed_rounded,
      Icons.kitchen_rounded,
    ];
    return icons[index % icons.length];
  }
} 