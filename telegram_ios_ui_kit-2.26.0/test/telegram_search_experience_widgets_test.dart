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
  testWidgets('TelegramRecentSearchesBar invokes callbacks', (tester) async {
    String? selected;
    String? removed;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        TelegramRecentSearchesBar(
          queries: const ['moderation', 'mini apps'],
          onSelected: (value) {
            selected = value;
          },
          onRemove: (value) {
            removed = value;
          },
          onClearAll: () {
            cleared = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('moderation'));
    await tester.pump();
    await tester.tap(find.text('Clear'));
    await tester.pump();
    await tester.tap(find.byIcon(CupertinoIcons.xmark).first);
    await tester.pump();

    expect(selected, 'moderation');
    expect(cleared, isTrue);
    expect(removed, isNotNull);
  });

  testWidgets('TelegramSearchResultTile renders and handles tap', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        TelegramSearchResultTile(
          result: const TelegramSearchResult(
            id: 'r1',
            title: 'Design Team',
            subtitle: 'Alice Johnson',
            sectionLabel: '#ui-kit',
            snippet: 'Telegram blue color token was updated.',
            timeLabel: '11:12',
            avatarFallback: 'DT',
            unreadCount: 2,
            isVerified: true,
          ),
          onTap: () {
            tapped = true;
          },
        ),
      ),
    );

    expect(find.text('Design Team'), findsOneWidget);
    expect(find.text('#ui-kit'), findsOneWidget);
    expect(find.text('11:12'), findsOneWidget);
    await tester.tap(find.text('Design Team'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('TelegramSearchEmptyState shows action button callback', (
    tester,
  ) async {
    var actionPressed = false;
    await tester.pumpWidget(
      _wrap(
        TelegramSearchEmptyState(
          title: 'No matches',
          message: 'Try another keyword.',
          actionLabel: 'Clear Search',
          onActionPressed: () {
            actionPressed = true;
          },
        ),
      ),
    );

    expect(find.text('No matches'), findsOneWidget);
    await tester.tap(find.text('Clear Search'));
    await tester.pump();
    expect(actionPressed, isTrue);
  });
}
