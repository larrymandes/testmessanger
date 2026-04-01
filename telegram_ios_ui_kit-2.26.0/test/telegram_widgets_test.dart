import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';

Widget _wrap(Widget child) {
  final theme = TelegramThemeData.light();
  return TelegramTheme(
    data: theme,
    child: MaterialApp(
      theme: theme.toThemeData(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('TelegramBadge hides when count <= 0', (tester) async {
    await tester.pumpWidget(_wrap(const TelegramBadge(count: 0)));
    expect(find.text('0'), findsNothing);
  });

  testWidgets('TelegramBadge renders count label', (tester) async {
    await tester.pumpWidget(_wrap(const TelegramBadge(count: 12)));
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('TelegramChatBubble renders text and timestamp', (tester) async {
    const message = TelegramMessage(
      id: 'm1',
      text: 'Test bubble',
      timeLabel: '09:41',
      isOutgoing: true,
      status: TelegramMessageStatus.read,
    );
    await tester.pumpWidget(_wrap(const TelegramChatBubble(message: message)));
    expect(find.text('Test bubble'), findsOneWidget);
    expect(find.text('09:41'), findsOneWidget);
  });
}
