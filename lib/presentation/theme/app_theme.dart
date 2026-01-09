import 'package:flutter/material.dart';

/// App theme configuration
/// 
/// Centralized theme management for consistent UI across the app.
/// 
/// Usage:
/// ```dart
/// // In MaterialApp
/// theme: AppTheme.lightTheme,
/// darkTheme: AppTheme.darkTheme,
/// 
/// // In widgets
/// Theme.of(context).primaryColor
/// Theme.of(context).textTheme.titleLarge
/// ```
class AppTheme {
  // ══════════════════════════════════════════════════════════════════════════
  // COLORS
  // ══════════════════════════════════════════════════════════════════════════

  // Primary colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal
  static const Color secondaryDark = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4DB6AC);

  // Accent colors
  static const Color accentColor = Color(0xFFFF4081); // Pink
  static const Color accentLight = Color(0xFFFF80AB);

  // Background colors (Light theme)
  static const Color backgroundColor = Color.fromARGB(255, 238, 227, 227);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Background colors (Dark theme)
  static const Color backgroundColorDark = Color(0xFF0E1117);
  static const Color surfaceColorDark = Color(0xFF343541);
  static const Color cardColorDark = Color(0xFF343541);

  // Text colors (Light theme)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Text colors (Dark theme)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF808080);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Divider & border colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFD0D0D0);
  static const Color dividerColorDark = Color(0xFF424242);
  static const Color borderColorDark = Color(0xFF505050);

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ════════════════════════════════════════════════════════════════════════
      // COLOR SCHEME
      // ════════════════════════════════════════════════════════════════════════

      colorScheme: ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLight,
        secondary: secondaryColor,
        secondaryContainer: secondaryLight,
        error: errorColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),

  
      scaffoldBackgroundColor: const Color.fromARGB(255, 226, 223, 226),

     
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // CARD
      // ════════════════════════════════════════════════════════════════════════

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.all(8),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // ELEVATED BUTTON
      // ════════════════════════════════════════════════════════════════════════

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // TEXT BUTTON
      // ════════════════════════════════════════════════════════════════════════

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // OUTLINED BUTTON
      // ════════════════════════════════════════════════════════════════════════

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryColor, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // FLOATING ACTION BUTTON
      // ════════════════════════════════════════════════════════════════════════

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // INPUT DECORATION
      // ════════════════════════════════════════════════════════════════════════

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        
        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        // Label & hint styles
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textHint,
          fontSize: 16,
        ),
        errorStyle: const TextStyle(
          color: errorColor,
          fontSize: 12,
        ),

        // Icon theme
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // BOTTOM NAVIGATION BAR
      // ════════════════════════════════════════════════════════════════════════

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // TEXT THEME
      // ════════════════════════════════════════════════════════════════════════

      textTheme: const TextTheme(
        // Display styles (largest)
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.4,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // ICON THEME
      // ════════════════════════════════════════════════════════════════════════

      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // DIVIDER
      // ════════════════════════════════════════════════════════════════════════

      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // CHIP
      // ════════════════════════════════════════════════════════════════════════

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        selectedColor: primaryLight,
        disabledColor: Colors.grey.shade100,
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // LIST TILE
      // ════════════════════════════════════════════════════════════════════════

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: textSecondary,
        textColor: textPrimary,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // SNACKBAR
      // ════════════════════════════════════════════════════════════════════════

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // DIALOG
      // ════════════════════════════════════════════════════════════════════════

      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // PROGRESS INDICATOR
      // ════════════════════════════════════════════════════════════════════════

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      // ════════════════════════════════════════════════════════════════════════
      // SWITCH
      // ════════════════════════════════════════════════════════════════════════

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return Colors.grey.shade300;
        }),
      ),

      // ════════════════════════════════════════════════════════════════════════
      // CHECKBOX
      // ════════════════════════════════════════════════════════════════════════

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        primaryContainer: primaryColor,
        secondary: secondaryLight,
        secondaryContainer: secondaryColor,
        error: errorColor,
        surface: surfaceColorDark,
        background: backgroundColorDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onError: Colors.black,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
      ),

      scaffoldBackgroundColor: backgroundColorDark,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceColorDark,
        foregroundColor: textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: textPrimaryDark,
          size: 24,
        ),
        titleTextStyle: const TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColorDark,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.all(8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primaryLight,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade800,
          disabledForegroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryLight, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColorDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textHintDark,
          fontSize: 16,
        ),
        errorStyle: const TextStyle(
          color: errorColor,
          fontSize: 12,
        ),
        prefixIconColor: textSecondaryDark,
        suffixIconColor: textSecondaryDark,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColorDark,
        selectedItemColor: primaryLight,
        unselectedItemColor: textSecondaryDark,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
          letterSpacing: 0,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: 0.15,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: 0.15,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimaryDark,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimaryDark,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondaryDark,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryDark,
          letterSpacing: 0.5,
        ),
      ),

      iconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: 24,
      ),

      dividerTheme: const DividerThemeData(
        color: dividerColorDark,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade800,
        selectedColor: primaryColor,
        disabledColor: Colors.grey.shade900,
        labelStyle: const TextStyle(color: textPrimaryDark),
        secondaryLabelStyle: const TextStyle(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: textSecondaryDark,
        textColor: textPrimaryDark,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColorDark,
        contentTextStyle: const TextStyle(
          color: textPrimaryDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: surfaceColorDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textSecondaryDark,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryLight,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade800;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}