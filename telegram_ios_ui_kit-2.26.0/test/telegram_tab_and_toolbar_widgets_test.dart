import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';

Widget _wrap(Widget child, {double textScaleFactor = 1}) {
  final theme = TelegramThemeData.light();
  return TelegramTheme(
    data: theme,
    child: MaterialApp(
      theme: theme.toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('TelegramBottomTabBar handles taps and avoids overflow', (
    tester,
  ) async {
    int? tappedIndex;
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 280,
          child: TelegramBottomTabBar(
            currentIndex: 2,
            onTap: (index) => tappedIndex = index,
            items: const [
              TelegramTabItem(icon: CupertinoIcons.person_2, label: 'Contacts'),
              TelegramTabItem(icon: CupertinoIcons.phone, label: 'Calls'),
              TelegramTabItem(
                icon: CupertinoIcons.chat_bubble_2,
                label: 'Chats',
              ),
              TelegramTabItem(
                icon: CupertinoIcons.square_grid_2x2,
                label: 'UI Kit',
              ),
              TelegramTabItem(
                icon: CupertinoIcons.app_badge,
                label: 'Mini Apps',
              ),
              TelegramTabItem(icon: CupertinoIcons.settings, label: 'Settings'),
            ],
          ),
        ),
        textScaleFactor: 2,
      ),
    );

    await tester.tap(find.text('Calls'));
    await tester.pump();

    expect(tappedIndex, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TelegramChatActionToolbar renders and invokes callbacks', (
    tester,
  ) async {
    var deletePressed = false;
    await tester.pumpWidget(
      _wrap(
        TelegramChatActionToolbar(
          title: '2 selected',
          actions: [
            TelegramActionItem(
              label: 'Delete',
              icon: CupertinoIcons.delete,
              isDestructive: true,
              onPressed: () async {
                deletePressed = true;
              },
            ),
          ],
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TelegramChatActionToolbar),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(container.color, isNull);
    expect(decoration.color, isNotNull);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(deletePressed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
