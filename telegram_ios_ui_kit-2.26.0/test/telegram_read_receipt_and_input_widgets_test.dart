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
  testWidgets('TelegramReadReceiptsStrip renders count and time label', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramReadReceiptsStrip(
          receipts: [
            TelegramReadReceipt(id: '1', name: 'Alice', avatarFallback: 'AL'),
            TelegramReadReceipt(id: '2', name: 'Bob', avatarFallback: 'BO'),
          ],
          timeLabel: '14:10',
        ),
      ),
    );

    expect(find.text('Seen by 2 · 14:10'), findsOneWidget);
  });

  testWidgets('TelegramReadReceiptsStrip renders single receiver name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramReadReceiptsStrip(
          receipts: [
            TelegramReadReceipt(
              id: 'single',
              name: 'Alice Johnson',
              avatarFallback: 'AJ',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Seen by Alice Johnson'), findsOneWidget);
  });

  testWidgets('TelegramStickyDateHeader keeps label after scrolling', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CustomScrollView(
          slivers: [
            const TelegramStickyDateHeader(label: 'Today'),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return const SizedBox(height: 56, child: Text('Message row'));
              }, childCount: 20),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets(
    'TelegramExpandableMessageInputBar expands tools and sends text',
    (tester) async {
      final controller = TextEditingController();
      String? sentMessage;
      var toolTapped = false;

      await tester.pumpWidget(
        _wrap(
          TelegramExpandableMessageInputBar(
            controller: controller,
            onSend: (value) => sentMessage = value,
            tools: [
              TelegramAttachmentAction(
                label: 'Photo',
                icon: CupertinoIcons.photo_fill,
                onPressed: () async {
                  toolTapped = true;
                },
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.plus_circle_fill));
      await tester.pumpAndSettle();
      expect(find.text('Photo'), findsOneWidget);

      await tester.tap(find.text('Photo'));
      await tester.pump();
      expect(toolTapped, isTrue);

      await tester.enterText(find.byType(TextField), 'Hello Telegram');
      await tester.tap(find.byIcon(CupertinoIcons.paperplane_fill));
      await tester.pump();

      expect(sentMessage, 'Hello Telegram');
      expect(controller.text, isEmpty);
    },
  );
}
