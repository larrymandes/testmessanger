import 'package:flutter/material.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';
import 'screens/main_screen.dart';
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
    // Используем темную тему Telegram с твоими цветами
    final telegramTheme = TelegramThemeData.dark().copyWith(
      colors: TelegramColors.fromTelegramTheme({
        'section_separator_color': '#545458',
        'link_color': '#3e88f7',
        'hint_color': '#98989e',
        'secondary_bg_color': '#000000',
        'bg_color': '#000000',
        'header_bg_color': '#1a1a1a',
        'destructive_text_color': '#eb5545',
        'subtitle_text_color': '#98989e',
        'bottom_bar_bg_color': '#1d1d1d',
        'accent_text_color': '#3e88f7',
        'section_bg_color': '#1c1c1d',
        'section_header_text_color': '#8d8e93',
        'text_color': '#ffffff',
        'button_text_color': '#ffffff',
        'button_color': '#3e88f7',
      }),
    );

    return TelegramTheme(
      data: telegramTheme,
      child: MaterialApp(
        title: 'Secure Messenger',
        theme: telegramTheme.toThemeData(),
        home: const AccountSelectScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
