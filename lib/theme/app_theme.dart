import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class AppTheme {
  // Telegram iOS Dark colors
  static const Color bgColor = Color(0xFF000000);
  static const Color secondaryBgColor = Color(0xFF000000);
  static const Color sectionBgColor = Color(0xFF1c1c1d);
  static const Color headerBgColor = Color(0xFF1a1a1a);
  static const Color bottomBarBgColor = Color(0xFF1d1d1d);
  static const Color textColor = Color(0xFFffffff);
  static const Color subtitleTextColor = Color(0xFF98989e);
  static const Color accentTextColor = Color(0xFF3e88f7);
  static const Color linkColor = Color(0xFF3e88f7);
  static const Color buttonColor = Color(0xFF3e88f7);
  static const Color buttonTextColor = Color(0xFFffffff);
  static const Color destructiveTextColor = Color(0xFFeb5545);
  static const Color sectionHeaderTextColor = Color(0xFF8d8e93);
  static const Color sectionSeparatorColor = Color(0xFF545458);
  static const Color hintColor = Color(0xFF98989e);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      primaryColor: accentTextColor,
      colorScheme: const ColorScheme.dark(
        primary: accentTextColor,
        secondary: accentTextColor,
        surface: sectionBgColor,
        background: bgColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: headerBgColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bottomBarBgColor,
        selectedItemColor: accentTextColor,
        unselectedItemColor: subtitleTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: sectionBgColor,
        elevation: 0,
      ),
      dividerColor: sectionSeparatorColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: subtitleTextColor),
      ),
      useMaterial3: true,
    );
  }

  static ChatTheme get chatTheme {
    return ChatTheme.dark().copyWith(
      colors: ChatTheme.dark().colors.copyWith(
        primary: accentTextColor,
        secondary: sectionBgColor,
        surface: bgColor,
        onSurface: textColor,
        onPrimary: buttonTextColor,
        error: destructiveTextColor,
      ),
      typography: ChatTheme.dark().typography.copyWith(
        bodyTextStyle: const TextStyle(
          color: textColor,
          fontSize: 16,
          height: 1.4,
        ),
        sentTextStyle: const TextStyle(
          color: textColor,
          fontSize: 16,
          height: 1.4,
        ),
        receivedTextStyle: const TextStyle(
          color: textColor,
          fontSize: 16,
          height: 1.4,
        ),
      ),
      spacing: ChatTheme.dark().spacing.copyWith(
        messageBorderRadius: 18,
      ),
    );
  }
}
