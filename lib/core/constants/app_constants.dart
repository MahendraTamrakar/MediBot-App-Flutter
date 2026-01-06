import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color.fromARGB(228, 30, 106, 236);
  static const Color primaryDark = Color.fromARGB(229, 241, 69, 69);

  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F7F8); // The "Sidebar" gray
  static const Color lightTextPrimary = Color(0xFF343541);
  static const Color lightTextSecondary = Color(0xFF6E6E80);
  static const Color lightBorder = Color(0xFFD9D9E3);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF343541); // The classic dark bg
  static const Color darkSurface = Color(0xFF444654); // The lighter message bubble
  static const Color darkTextPrimary = Color(0xFFECECF1);
  static const Color darkTextSecondary = Color(0xFFACACBE);
  static const Color darkBorder = Color(0xFF565869);

  // Status Colors
  static const Color error = Color(0xFFEF4146);
  static const Color success = Color(0xFF10A37F);
}

class AppStrings {
  static const String appName = "MediBot";
  static const String themeKey = "theme_mode";
}