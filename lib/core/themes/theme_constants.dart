import 'package:flutter/material.dart';

class ThemeConstants {
  static const animationDuration = Duration(milliseconds: 800);
  
  // Day Mode Colors
  static const dayPrimaryGradient = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFFCC70)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const daySecondaryGradient = LinearGradient(
    colors: [Color(0xFFFFF8DC), Color(0xFFFFE4B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const dayAccent = Color(0xFFFF6B35);
  
  static List<List<Color>> dayBackgroundGradients = [
    [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
    [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
    [Color(0xFFEEEEEE), Color(0xFFFAFAFA)],
  ];
  
  static final dayCardColor = Colors.white;
  
  // Night Mode Colors
  static const nightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const nightSecondaryGradient = LinearGradient(
    colors: [Color(0xFF0F3460), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const nightAccent = Color(0xFFE94560);
  
  static List<List<Color>> nightBackgroundGradients = [
    [Color(0xFF121212), Color(0xFF1A1A1A)],
    [Color(0xFF1A1A1A), Color(0xFF212121)],
    [Color(0xFF212121), Color(0xFF121212)],
  ];
  
  static final nightCardColor = const Color(0xFF1E1E1E);
  
  // Typography
  static const fontFamily = 'Poppins';
} 