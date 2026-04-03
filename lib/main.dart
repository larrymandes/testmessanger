import 'package:flutter/material.dart';
import 'screens/account_select_screen.dart';
import 'services/storage_service.dart';
import 'theme/chat_theme.dart';

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
      theme: TelegramChatTheme.createAppTheme(),
      home: const AccountSelectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
