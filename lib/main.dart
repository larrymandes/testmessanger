import 'package:flutter/material.dart';
import 'screens/account_select_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const SecureMessengerApp());
}

class SecureMessengerApp extends StatelessWidget {
  const SecureMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Messenger',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        
        // Основные цвета
        scaffoldBackgroundColor: const Color(0xFF000000), // bg_color
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3e88f7),        // button_color / accent_text_color
          secondary: Color(0xFF3e88f7),      // link_color
          surface: Color(0xFF1c1c1d),        // section_bg_color
          background: Color(0xFF000000),     // secondary_bg_color
          error: Color(0xFFeb5545),          // destructive_text_color
          onPrimary: Color(0xFFffffff),      // button_text_color
          onSecondary: Color(0xFFffffff),
          onSurface: Color(0xFFffffff),      // text_color
          onBackground: Color(0xFFffffff),
          onError: Color(0xFFffffff),
        ),
        
        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a1a),  // header_bg_color
          foregroundColor: Color(0xFFffffff),  // text_color
          elevation: 0,
        ),
        
        // Card
        cardTheme: const CardTheme(
          color: Color(0xFF1c1c1d),           // section_bg_color
          elevation: 0,
        ),
        
        // Divider
        dividerTheme: const DividerThemeData(
          color: Color(0xFF545458),           // section_separator_color
          thickness: 0.5,
        ),
        
        // Text
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFffffff)),    // text_color
          bodyMedium: TextStyle(color: Color(0xFFffffff)),   // text_color
          bodySmall: TextStyle(color: Color(0xFF98989e)),    // subtitle_text_color
          titleLarge: TextStyle(color: Color(0xFFffffff)),
          titleMedium: TextStyle(color: Color(0xFFffffff)),
          titleSmall: TextStyle(color: Color(0xFF8d8e93)),   // section_header_text_color
          labelLarge: TextStyle(color: Color(0xFFffffff)),
          labelMedium: TextStyle(color: Color(0xFF98989e)),  // hint_color
          labelSmall: TextStyle(color: Color(0xFF98989e)),
        ),
        
        // Input
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1c1c1d),       // section_bg_color
          hintStyle: TextStyle(color: Color(0xFF98989e)),  // hint_color
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF545458)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF545458)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3e88f7)),
          ),
        ),
        
        // Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3e88f7),  // button_color
            foregroundColor: const Color(0xFFffffff),  // button_text_color
            elevation: 0,
          ),
        ),
        
        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1d1d1d),          // bottom_bar_bg_color
          selectedItemColor: Color(0xFF3e88f7),        // accent_text_color
          unselectedItemColor: Color(0xFF98989e),      // subtitle_text_color
        ),
        
        // List Tile
        listTileTheme: const ListTileThemeData(
          tileColor: Color(0xFF1c1c1d),                // section_bg_color
          textColor: Color(0xFFffffff),                // text_color
          iconColor: Color(0xFF3e88f7),                // accent_text_color
        ),
      ),
      home: const AccountSelectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
