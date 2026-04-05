import 'package:flutter/material.dart';
import 'screens/account_select_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart'; // ✅ Импортируем тему

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
      title: 'Beta Chat',
      theme: AppTheme.darkTheme, // ✅ Применяем тёмную тему
      home: const AccountSelectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
