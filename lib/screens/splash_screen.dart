import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart'; // Added
// import '../theme/theme_constants.dart'; // Commented out - will use direct colors
// import '../constants/strings.dart'; // Commented out - will use direct text

class SplashScreen extends StatefulWidget {
  // final VoidCallback onComplete; // Removed
  static const String routeName = '/splash'; // Added
  const SplashScreen({super.key}); // Modified constructor

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _backgroundAnimation; // Will be used for gradient color transition
  bool _showSun = false;

  // Define night and day gradient colors as per requirements
  final Color _nightStartColor = const Color(0xFF141E30);
  final Color _nightEndColor = const Color(0xFF243B55);
  final Color _dayStartColor = const Color(0xFFFFA726);
  final Color _dayEndColor = const Color(0xFFFFE082);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Requirement: 3 seconds
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1, // Requirement: 1 full 360° rotation
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Using simple easeInOut, interval from original code removed for now
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Linear for progress
    ));

    // Using the existing _backgroundAnimation for color transition timing
    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smooth transition for colors
    ));

    _controller.addListener(() {
      // Original logic to change icon:
      if (_controller.value >= 0.5 && !_showSun) { // Change icon around halfway
        setState(() {
          _showSun = true;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          context.go('/auth'); // Requirement: Navigate using go_router
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Added Scaffold as good practice, though original didn't have one directly
      body: AnimatedBuilder(
        animation: _controller, // Listen to controller for all animations
        builder: (context, child) {
          // Determine current gradient colors based on _backgroundAnimation
          final Color currentStartColor = Color.lerp(
            _nightStartColor,
            _dayStartColor,
            _backgroundAnimation.value,
          )!;
          final Color currentEndColor = Color.lerp(
            _nightEndColor,
            _dayEndColor,
            _backgroundAnimation.value,
          )!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [currentStartColor, currentEndColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RotationTransition(
                    turns: _rotationAnimation, // Uses the modified _rotationAnimation
                    child: Icon(
                      _showSun ? Icons.wb_sunny : Icons.nightlight_round,
                      size: 100.0, // Requirement: Icon size 100
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40.0), // Spacing as per example
                  SizedBox(
                    width: 60, // Size of progress indicator as per example
                    height: 60,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value, // Direct progress
                      strokeWidth: 5.0, // As per example
                      backgroundColor: Colors.white.withOpacity(0.3), // As per example
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // As per example
                    ),
                  ),
                  const SizedBox(height: 40.0), // Spacing as per example
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 30.0, // Requirement
                      fontFamily: 'Poppins', // Requirement (ensure font is available)
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        ScaleAnimatedText( // Requirement
                          'Cercle Mystique', // Requirement
                          duration: const Duration(milliseconds: 2800), // Requirement (slightly less than controller)
                        ),
                      ],
                      isRepeatingAnimation: false, // Requirement
                      totalRepeatCount: 1, // Requirement
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
