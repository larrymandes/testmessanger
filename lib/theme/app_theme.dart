import 'package:flutter/material.dart';

/// Тёмная тема приложения (Telegram Dark Theme - ТОЧНЫЕ ЦВЕТА)
class AppTheme {
  // ✅ ТОЧНЫЕ цвета из Telegram Dark Theme
  static const Color bgColor = Color(0xFF000000);
  static const Color secondaryBgColor = Color(0xFF000000);
  static const Color sectionBgColor = Color(0xFF1c1c1d);
  static const Color headerBgColor = Color(0xFF1a1a1a);
  static const Color bottomBarBgColor = Color(0xFF1d1d1d);
  
  static const Color textColor = Color(0xFFffffff);
  static const Color subtitleTextColor = Color(0xFF98989e);
  static const Color sectionHeaderTextColor = Color(0xFF8d8e93);
  static const Color hintColor = Color(0xFF98989e);
  
  static const Color accentTextColor = Color(0xFF3e88f7);
  static const Color linkColor = Color(0xFF3e88f7);
  static const Color buttonColor = Color(0xFF3e88f7);
  static const Color buttonTextColor = Color(0xFFffffff);
  
  static const Color destructiveTextColor = Color(0xFFeb5545);
  static const Color sectionSeparatorColor = Color(0xFF545458);
  
  /// Основная тема приложения
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Основные цвета
      scaffoldBackgroundColor: bgColor,
      primaryColor: buttonColor,
      colorScheme: const ColorScheme.dark(
        primary: buttonColor,
        secondary: accentTextColor,
        surface: sectionBgColor,
        error: destructiveTextColor,
        onPrimary: buttonTextColor,
        onSecondary: textColor,
        onSurface: textColor,
        onError: textColor,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: headerBgColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: sectionBgColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: sectionBgColor,
        textColor: textColor,
        iconColor: textColor,
        subtitleTextStyle: TextStyle(color: subtitleTextColor),
      ),
      
      // Text
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColor, fontSize: 16),
        bodyMedium: TextStyle(color: textColor, fontSize: 14),
        bodySmall: TextStyle(color: subtitleTextColor, fontSize: 12),
        titleLarge: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: subtitleTextColor, fontSize: 14),
        labelLarge: TextStyle(color: textColor, fontSize: 14),
        labelMedium: TextStyle(color: subtitleTextColor, fontSize: 12),
        labelSmall: TextStyle(color: hintColor, fontSize: 11),
      ),
      
      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentTextColor,
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sectionBgColor,
        hintStyle: const TextStyle(color: hintColor),
        labelStyle: const TextStyle(color: subtitleTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: sectionSeparatorColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: sectionSeparatorColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: buttonColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: destructiveTextColor),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: sectionBgColor,
        titleTextStyle: const TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: sectionBgColor,
        contentTextStyle: TextStyle(color: textColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: sectionSeparatorColor,
        thickness: 0.5,
      ),
      
      // Icon
      iconTheme: const IconThemeData(
        color: textColor,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bottomBarBgColor,
        selectedItemColor: accentTextColor,
        unselectedItemColor: subtitleTextColor,
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return buttonColor;
          }
          return subtitleTextColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return buttonColor.withOpacity(0.5);
          }
          return sectionSeparatorColor;
        }),
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return buttonColor;
          }
          return sectionSeparatorColor;
        }),
        checkColor: WidgetStateProperty.all(buttonTextColor),
      ),
      
      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return buttonColor;
          }
          return sectionSeparatorColor;
        }),
      ),
    );
  }
}
