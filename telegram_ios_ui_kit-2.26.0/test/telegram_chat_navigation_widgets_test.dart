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
  testWidgets('TelegramServiceMessageBubble renders icon and text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramServiceMessageBubble(
          message: 'Messages are end-to-end encrypted',
          icon: CupertinoIcons.lock_shield_fill,
        ),
      ),
    );

    expect(find.text('Messages are end-to-end encrypted'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.lock_shield_fill), findsOneWidget);
  });

  testWidgets('TelegramServiceMessageBubble hides on empty content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const TelegramServiceMessageBubble(message: '   ')),
    );

    expect(find.text('Messages are end-to-end encrypted'), findsNothing);
    expect(find.byIcon(CupertinoIcons.lock_shield_fill), findsNothing);
  });

  testWidgets('TelegramJumpToBottomButton shows unread badge and handles tap', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        TelegramJumpToBottomButton(
          unreadCount: 108,
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );

    expect(find.text('99+'), findsOneWidget);
    await tester.tap(find.byType(TelegramJumpToBottomButton));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('TelegramJumpToBottomButton ignores events when hidden', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        TelegramJumpToBottomButton(
          visible: false,
          unreadCount: 5,
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );

    final ignorePointer = tester.widget<IgnorePointer>(
      find.byType(IgnorePointer),
    );
    expect(ignorePointer.ignoring, isTrue);
    expect(tapped, isFalse);
  });
}
