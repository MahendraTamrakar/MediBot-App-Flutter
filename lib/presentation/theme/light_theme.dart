import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Color.fromARGB(228, 30, 106, 236),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: const Color.fromRGBO(255, 255, 255, 1),
    iconTheme: const IconThemeData(color: AppColors.lightIconColor),


    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(228, 30, 106, 236),
      secondary: Color.fromARGB(255, 116, 76, 248),
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
    ),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.lightTextPrimary, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.lightIconColor),
      actionsIconTheme: IconThemeData(color: AppColors.lightIconColor),
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Input Decoration (ChatGPT style rounded borders)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
