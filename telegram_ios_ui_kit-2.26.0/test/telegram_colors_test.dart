import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';

void main() {
  test('fromTelegramTheme maps known keys', () {
    final colors = TelegramColors.fromTelegramTheme(const {
      'bg_color': '#111111',
      'Telegram/text_color': '#eeeeee',
      'button_color': '#007aff',
    }, fallback: TelegramColors.light);

    expect(colors.bgColor, const Color(0xFF111111));
    expect(colors.textColor, const Color(0xFFEEEEEE));
    expect(colors.buttonColor, const Color(0xFF007AFF));
    expect(colors.linkColor, TelegramColors.light.linkColor);
  });

  test('toTelegramThemeMap exports Telegram key set', () {
    final map = TelegramColors.dark.toTelegramThemeMap();
    expect(map['bg_color'], isNotNull);
    expect(map['text_color'], isNotNull);
    expect(map['button_color'], isNotNull);
    expect(map['outgoing_bubble_color'], isNotNull);
  });

  test('toTelegramThemeMap supports prefixed keys', () {
    final map = TelegramColors.light.toTelegramThemeMap(withPrefix: true);
    expect(map.containsKey('Telegram/bg_color'), isTrue);
    expect(map.containsKey('Telegram/text_color'), isTrue);
  });
}
