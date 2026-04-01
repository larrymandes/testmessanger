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
  testWidgets('TelegramChatHeader renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramChatHeader(
          title: 'Design Team',
          subtitle: 'last seen recently',
          avatarFallback: 'DT',
        ),
      ),
    );

    expect(find.text('Design Team'), findsOneWidget);
    expect(find.text('last seen recently'), findsOneWidget);
  });

  testWidgets('TelegramQuickRepliesBar calls onReplyTap', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        TelegramQuickRepliesBar(
          replies: const ['A', 'B'],
          onReplyTap: (reply) {
            selected = reply;
          },
        ),
      ),
    );

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, 'B');
  });

  testWidgets('TelegramReactionBar calls onReactionTap', (tester) async {
    TelegramReaction? selected;
    const reactions = [
      TelegramReaction(emoji: '👍', count: 3),
      TelegramReaction(emoji: '🔥', count: 2),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramReactionBar(
          reactions: reactions,
          onReactionTap: (reaction) {
            selected = reaction;
          },
        ),
      ),
    );

    await tester.tap(find.text('🔥 2'));
    await tester.pump();
    expect(selected?.emoji, '🔥');
  });

  testWidgets('TelegramMediaGrid renders media labels', (tester) async {
    const items = [
      TelegramMediaItem(id: '1', label: 'One'),
      TelegramMediaItem(
        id: '2',
        label: 'Two',
        isVideo: true,
        durationLabel: '0:12',
      ),
      TelegramMediaItem(id: '3', label: 'Three'),
    ];

    await tester.pumpWidget(_wrap(const TelegramMediaGrid(items: items)));
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('0:12'), findsOneWidget);
  });
}
