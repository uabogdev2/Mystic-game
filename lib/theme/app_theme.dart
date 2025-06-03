import 'package:flutter/material.dart';
import 'theme_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeConstants.dayPrimaryGradient.colors.first,
      colorScheme: ColorScheme.light(
        primary: ThemeConstants.dayPrimaryGradient.colors.first,
        secondary: ThemeConstants.daySecondaryGradient.colors.first,
        tertiary: ThemeConstants.dayAccent,
      ),
      scaffoldBackgroundColor: ThemeConstants.dayBackgroundGradients[0][0],
      cardColor: ThemeConstants.dayCardColor,
      fontFamily: ThemeConstants.fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Colors.black.withOpacity(0.9)),
        headlineMedium: TextStyle(color: Colors.black.withOpacity(0.9)),
        headlineSmall: TextStyle(color: Colors.black.withOpacity(0.9)),
        titleLarge: TextStyle(color: Colors.black.withOpacity(0.9)),
        titleMedium: TextStyle(color: Colors.black.withOpacity(0.85)),
        titleSmall: TextStyle(color: Colors.black.withOpacity(0.85)),
        bodyLarge: TextStyle(color: Colors.black.withOpacity(0.85)),
        bodyMedium: TextStyle(color: Colors.black.withOpacity(0.85)),
        bodySmall: TextStyle(color: Colors.black.withOpacity(0.75)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: ThemeConstants.nightPrimaryGradient.colors.first,
      colorScheme: ColorScheme.dark(
        primary: ThemeConstants.nightPrimaryGradient.colors.first,
        secondary: ThemeConstants.nightSecondaryGradient.colors.first,
        tertiary: ThemeConstants.nightAccent,
      ),
      scaffoldBackgroundColor: ThemeConstants.nightBackgroundGradients[0][0],
      cardColor: ThemeConstants.nightCardColor,
      fontFamily: ThemeConstants.fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Colors.white.withOpacity(0.95)),
        headlineMedium: TextStyle(color: Colors.white.withOpacity(0.95)),
        headlineSmall: TextStyle(color: Colors.white.withOpacity(0.95)),
        titleLarge: TextStyle(color: Colors.white.withOpacity(0.95)),
        titleMedium: TextStyle(color: Colors.white.withOpacity(0.9)),
        titleSmall: TextStyle(color: Colors.white.withOpacity(0.9)),
        bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
        bodyMedium: TextStyle(color: Colors.white.withOpacity(0.9)),
        bodySmall: TextStyle(color: Colors.white.withOpacity(0.8)),
      ),
    );
  }
} 