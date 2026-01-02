import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Toggle Theme: User clicks "Light", "Dark", or "System"
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    _saveTheme(mode);
  }

  // Load from Storage
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeString = prefs.getString(AppStrings.themeKey);

    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  // Save to Storage
  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value;
    if (mode == ThemeMode.light)
    {
      value = 'light';
    }
    else if (mode == ThemeMode.dark){
      value = 'dark';
    }
    else{
      value = 'system';
    }
    
    await prefs.setString(AppStrings.themeKey, value);
  }
}