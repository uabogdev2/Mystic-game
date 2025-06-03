import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = StateNotifierProvider<ThemeController, bool>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<bool> {
  static const _themePreferenceKey = 'is_dark_mode';
  late SharedPreferences _prefs;
  
  ThemeController() : super(false) {
    _initializeTheme();
  }
  
  Future<void> _initializeTheme() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool(_themePreferenceKey) ?? false;
  }
  
  Future<void> toggleTheme() async {
    final newState = !state;
    state = newState;
    
    _prefs.setBool(_themePreferenceKey, newState);
  }
  
  bool get isDarkMode => state;
} 