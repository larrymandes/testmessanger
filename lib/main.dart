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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2b5278),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AccountSelectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
