import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/theme_constants.dart';
import '../constants/strings.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _backgroundAnimation;
  bool _showSun = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _controller.addListener(() {
      if (_controller.value > 0.5 && !_showSun) {
        setState(() => _showSun = true);
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(
                  ThemeConstants.nightPrimaryGradient.colors.first,
                  ThemeConstants.dayPrimaryGradient.colors.first,
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  ThemeConstants.nightPrimaryGradient.colors.last,
                  ThemeConstants.dayPrimaryGradient.colors.last,
                  _backgroundAnimation.value,
                )!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 4,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _showSun ? ThemeConstants.dayAccent : ThemeConstants.nightAccent,
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Icon(
                        _showSun ? Icons.wb_sunny : Icons.nightlight_round,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 28,
                    fontFamily: ThemeConstants.fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        Strings.appTitle,
                        duration: const Duration(milliseconds: 2000),
                        fadeOutBegin: 0.8,
                        fadeInEnd: 0.2,
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 