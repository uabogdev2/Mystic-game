import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_mode.dart'; // Using the created AppThemeMode enum

class ThemeController with ChangeNotifier {
  static const String _themePrefKey = 'app_theme_mode';
  SharedPreferences? _prefs;

  AppThemeMode _currentAppThemeMode = AppThemeMode.system; // Default

  // Getter for the Flutter ThemeMode based on our AppThemeMode
  ThemeMode get themeMode {
    if (_currentAppThemeMode == AppThemeMode.light) return ThemeMode.light;
    if (_currentAppThemeMode == AppThemeMode.dark) return ThemeMode.dark;
    return ThemeMode.system;
  }

  // Getter for our internal AppThemeMode state
  AppThemeMode get currentAppThemeMode => _currentAppThemeMode;

  ThemeController() {
    _loadThemePreference();
  }

  Future<void> _initPrefs() async {
    // Initialize SharedPreferences instance if it hasn't been already.
    // This check is important because SharedPreferences.getInstance() can be costly.
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadThemePreference() async {
    // Ensure SharedPreferences is initialized.
    // Note: If 'flutter pub add shared_preferences' failed, this will throw an error at runtime
    // when SharedPreferences.getInstance() is called.
    try {
      await _initPrefs();
      final String? themeString = _prefs?.getString(_themePrefKey);
      if (themeString != null) {
        _currentAppThemeMode = AppThemeMode.values.firstWhere(
          (e) => e.toString() == themeString,
          orElse: () {
            print('Warning: Saved theme string "$themeString" is not a valid AppThemeMode. Defaulting to system.');
            return AppThemeMode.system;
          },
        );
      }
    } catch (e) {
      // This catch block is important, especially if shared_preferences is missing.
      print('Error loading theme preference (possibly due to missing shared_preferences plugin or other issues): $e');
      _currentAppThemeMode = AppThemeMode.system; // Default to system theme on error
    }
    notifyListeners(); // Notify listeners after attempting to load, even if it fails and defaults
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentAppThemeMode == mode) return; // No change needed
    _currentAppThemeMode = mode;

    try {
      await _initPrefs(); // Ensure SharedPreferences is initialized
      await _prefs?.setString(_themePrefKey, mode.toString());
    } catch (e) {
      // Log error if saving fails.
      print('Error saving theme preference (possibly due to missing shared_preferences plugin or other issues): $e');
    }
    notifyListeners(); // Notify listeners of the change
  }

  // A simple toggle logic: Light -> Dark -> System -> Light
  void toggleTheme() {
    if (_currentAppThemeMode == AppThemeMode.light) {
      setThemeMode(AppThemeMode.dark);
    } else if (_currentAppThemeMode == AppThemeMode.dark) {
      setThemeMode(AppThemeMode.system);
    } else { // System or any other state defaults to Light
      setThemeMode(AppThemeMode.light);
    }
  }
}
