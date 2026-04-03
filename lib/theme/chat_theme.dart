import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

/// Telegram iOS стиль для flutter_chat_ui
/// Цвета взяты из Telegram iOS Dark Theme
class TelegramChatTheme {
  // Цвета из Telegram iOS Dark Theme
  static const Color bgColor = Color(0xFF000000);
  static const Color secondaryBgColor = Color(0xFF000000);
  static const Color sectionBgColor = Color(0xFF1c1c1d);
  static const Color headerBgColor = Color(0xFF1a1a1a);
  static const Color textColor = Color(0xFFffffff);
  static const Color subtitleTextColor = Color(0xFF98989e);
  static const Color hintColor = Color(0xFF98989e);
  static const Color linkColor = Color(0xFF3e88f7);
  static const Color accentTextColor = Color(0xFF3e88f7);
  static const Color buttonColor = Color(0xFF3e88f7);
  static const Color buttonTextColor = Color(0xFFffffff);
  static const Color destructiveTextColor = Color(0xFFeb5545);
  static const Color separatorColor = Color(0xFF545458);
  static const Color bottomBarBgColor = Color(0xFF1d1d1d);
  static const Color sectionHeaderTextColor = Color(0xFF8d8e93);
  
  // Цвета для пузырей сообщений (как в Telegram iOS)
  static const Color outgoingBubbleColor = Color(0xFF2b5278); // Синий для исходящих
  static const Color incomingBubbleColor = Color(0xFF1c1c1d); // Тёмно-серый для входящих
  
  /// Создаёт ChatTheme в стиле Telegram iOS Dark
  static ChatTheme createDarkTheme() {
    return ChatTheme.dark().copyWith(
      // Основные цвета
      colors: ChatTheme.dark().colors.copyWith(
        primary: outgoingBubbleColor,        // Цвет исходящих сообщений
        surface: bgColor,                     // Фон чата
        onSurface: textColor,                 // Текст на фоне
        secondary: incomingBubbleColor,       // Цвет входящих сообщений
        onSecondary: textColor,               // Текст во входящих
        onPrimary: textColor,                 // Текст в исходящих
        inputBackground: sectionBgColor,      // Фон поля ввода
        inputText: textColor,                 // Текст в поле ввода
      ),
      
      // Радиусы скругления (как в Telegram iOS)
      messageBorderRadius: 18.0,              // Скругление пузырей
      
      // Отступы (как в Telegram iOS)
      messageInsetsVertical: 8.0,
      messageInsetsHorizontal: 12.0,
      
      // Шрифты
      receivedMessageBodyTextStyle: const TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      sentMessageBodyTextStyle: const TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      
      // Время сообщения
      receivedMessageCaptionTextStyle: TextStyle(
        color: subtitleTextColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      sentMessageCaptionTextStyle: TextStyle(
        color: subtitleTextColor.withOpacity(0.8),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      
      // Ссылки
      receivedMessageLinkTitleTextStyle: const TextStyle(
        color: linkColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      sentMessageLinkTitleTextStyle: const TextStyle(
        color: linkColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      
      // Поле ввода
      inputTextStyle: const TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      inputTextDecoration: InputDecoration(
        hintText: 'Сообщение',
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 16,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // Кнопка отправки
      sendButtonIcon: const Icon(
        Icons.arrow_upward_rounded,
        color: buttonTextColor,
        size: 24,
      ),
    );
  }
  
  /// ThemeData для всего приложения в стиле Telegram iOS Dark
  static ThemeData createAppTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Основные цвета
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.dark(
        surface: bgColor,
        onSurface: textColor,
        primary: buttonColor,
        onPrimary: buttonTextColor,
        secondary: sectionBgColor,
        onSecondary: textColor,
        error: destructiveTextColor,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: headerBgColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Карточки и поверхности
      cardTheme: CardTheme(
        color: sectionBgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      
      // Списки
      listTileTheme: ListTileThemeData(
        tileColor: sectionBgColor,
        textColor: textColor,
        iconColor: textColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      
      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: linkColor,
        ),
      ),
      
      // Текст
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: subtitleTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Разделители
      dividerTheme: DividerThemeData(
        color: separatorColor,
        thickness: 0.5,
        space: 0,
      ),
      
      // Иконки
      iconTheme: const IconThemeData(
        color: textColor,
        size: 24,
      ),
    );
  }
}
