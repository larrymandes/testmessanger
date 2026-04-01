import 'package:flutter/cupertino.dart';
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
  testWidgets('TelegramChatBubble shows sending indicator', (tester) async {
    const message = TelegramMessage(
      id: 'sending',
      text: 'Uploading...',
      timeLabel: '10:01',
      isOutgoing: true,
      status: TelegramMessageStatus.sending,
    );

    await tester.pumpWidget(_wrap(const TelegramChatBubble(message: message)));

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('TelegramMessageSelectionWrapper shows selection marker', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TelegramMessageSelectionWrapper(
          isOutgoing: false,
          selectionMode: true,
          selected: true,
          child: const TelegramChatBubble(
            message: TelegramMessage(
              id: 'selected',
              text: 'Selected message',
              timeLabel: '10:02',
              isOutgoing: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    expect(find.text('Selected message'), findsOneWidget);
  });

  testWidgets('TelegramChatBackground accepts wallpaper config', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramChatBackground(
          wallpaper: TelegramChatWallpaper.gradient(
            primaryColor: Color(0xFFF5F9FF),
            secondaryColor: Color(0xFFE9F1FF),
            patternColor: Color(0x332E66FF),
          ),
          child: Center(child: Text('Wallpaper')),
        ),
      ),
    );

    expect(find.text('Wallpaper'), findsOneWidget);
  });
}
