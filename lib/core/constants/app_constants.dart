import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color.fromARGB(228, 30, 106, 236);
  static const Color primaryDark = Color.fromARGB(229, 241, 69, 69);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white; // The "Sidebar" gray
  static const Color lightTextPrimary = Colors.black;
  static const Color lightTextSecondary = Color.fromARGB(255, 71, 71, 71);
  static const Color lightBorder = Color.fromARGB(255, 91, 91, 92);
  static const Color lightIconColor = Colors.black;

  // Dark Theme Colors
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0); // Updated dark background
  static const Color darkSurface = Color(0xFF2A2B2E); // The classic dark surface
  static const Color darkTextPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color darkTextSecondary = Color.fromARGB(255, 217, 217, 217);
  static const Color darkBorder = Color(0xFF565869);
  static const Color darkIconColor = Color.fromARGB(255, 255, 255, 255);

  // Status Colors
  static const Color error = Color(0xFFEF4146);
  static const Color success = Color(0xFF10A37F);
}

class AppStrings {
  static const String appName = "MediBot";
  static const String themeKey = "theme_mode";
}