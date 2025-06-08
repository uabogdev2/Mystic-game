import 'package:flutter/material.dart';

// TODO (Accessibility): Test all TextStyles with significantly larger font sizes
// to ensure UI elements adapt gracefully (e.g., buttons, cards, input fields expand or wrap text).
// Consider using Typography.adaptivePlatformDensity for more native text scaling.

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue, // Example color
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins', // Set default font family
    // Define other properties like colorScheme, textTheme, etc.
    textTheme: const TextTheme( // Using const for default TextTheme
      bodyLarge: TextStyle(fontFamily: 'Poppins'), // Base size usually 16.0
      bodyMedium: TextStyle(fontFamily: 'Poppins'), // Base size usually 14.0
      displayLarge: TextStyle(fontFamily: 'Poppins'),
      displayMedium: TextStyle(fontFamily: 'Poppins'),
      displaySmall: TextStyle(fontFamily: 'Poppins'),
      headlineMedium: TextStyle(fontFamily: 'Poppins'),
      headlineSmall: TextStyle(fontFamily: 'Poppins'),
      titleLarge: TextStyle(fontFamily: 'Poppins'),
      titleMedium: TextStyle(fontFamily: 'Poppins'),
      titleSmall: TextStyle(fontFamily: 'Poppins'),
      bodySmall: TextStyle(fontFamily: 'Poppins'), // Base size usually 12.0
      labelLarge: TextStyle(fontFamily: 'Poppins'), // For buttons, base size usually 14.0
      labelSmall: TextStyle(fontFamily: 'Poppins'),
    ).apply( // Apply default display and body colors that contrast with brightness
      bodyColor: Colors.black87, // Common body text color for light theme
      displayColor: Colors.black, // Common heading/display text color for light theme
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      secondary: Colors.amber, // Example secondary color
      // Ensure error, surface, background etc. colors are well-defined
      // error: Colors.red.shade700,
    ),
    // TODO (Accessibility): Ensure button themes, card themes, input decoration themes, etc.,
    // defined here or in their respective widget styles, also respect text scaling.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal, // Example color
    scaffoldBackgroundColor: const Color(0xFF121212), // Common dark theme background
    fontFamily: 'Poppins', // Set default font family
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Poppins'),
      bodyMedium: TextStyle(fontFamily: 'Poppins'),
      displayLarge: TextStyle(fontFamily: 'Poppins'),
      displayMedium: TextStyle(fontFamily: 'Poppins'),
      displaySmall: TextStyle(fontFamily: 'Poppins'),
      headlineMedium: TextStyle(fontFamily: 'Poppins'),
      headlineSmall: TextStyle(fontFamily: 'Poppins'),
      titleLarge: TextStyle(fontFamily: 'Poppins'),
      titleMedium: TextStyle(fontFamily: 'Poppins'),
      titleSmall: TextStyle(fontFamily: 'Poppins'),
      bodySmall: TextStyle(fontFamily: 'Poppins'),
      labelLarge: TextStyle(fontFamily: 'Poppins'),
      labelSmall: TextStyle(fontFamily: 'Poppins'),
    ).apply(
      bodyColor: Colors.white70, // Common body text color for dark theme
      displayColor: Colors.white,  // Common heading/display text color for dark theme
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      brightness: Brightness.dark, // Important for ColorScheme to generate dark-appropriate colors
    ).copyWith(
      secondary: Colors.orangeAccent, // Example secondary color
      // error: Colors.red.shade400,
    ),
  );
}
