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
  const savedSearches = [
    TelegramSavedSearch(
      id: 'saved_1',
      label: 'Moderation Radar',
      query: 'moderation',
      scopeLabel: 'Moderation',
      sortLabel: 'Unread',
      filterIds: ['priority', 'unread'],
      icon: CupertinoIcons.shield_fill,
      expectedCount: 3,
    ),
    TelegramSavedSearch(
      id: 'saved_2',
      label: 'Design Tokens',
      query: 'design tokens',
      scopeLabel: 'Chats',
      sortLabel: 'Newest',
      filterIds: ['links'],
      icon: CupertinoIcons.paintbrush_fill,
      expectedCount: 2,
    ),
  ];

  testWidgets(
    'TelegramSavedSearchesBar invokes selection and clear callbacks',
    (tester) async {
      TelegramSavedSearch? selected;
      var cleared = false;

      await tester.pumpWidget(
        _wrap(
          TelegramSavedSearchesBar(
            searches: savedSearches,
            selectedId: 'saved_1',
            clearLabel: 'Detach',
            onSelected: (search) {
              selected = search;
            },
            onClearSelection: () {
              cleared = true;
            },
          ),
        ),
      );

      expect(find.text('Moderation Radar'), findsOneWidget);
      expect(find.text('Design Tokens'), findsOneWidget);
      expect(find.text('Detach'), findsOneWidget);

      await tester.tap(find.text('Design Tokens'));
      await tester.pump();
      expect(selected?.id, 'saved_2');

      await tester.tap(find.text('Detach'));
      await tester.pump();
      expect(cleared, isTrue);
    },
  );

  testWidgets('TelegramSavedSearchCard renders metadata and actions', (
    tester,
  ) async {
    TelegramSavedSearch? applied;
    TelegramSavedSearch? removed;

    await tester.pumpWidget(
      _wrap(
        TelegramSavedSearchCard(
          search: savedSearches.first,
          selected: true,
          applyLabel: 'Re-run',
          deleteLabel: 'Detach',
          onApply: (search) {
            applied = search;
          },
          onDelete: (search) {
            removed = search;
          },
        ),
      ),
    );

    expect(find.text('Moderation Radar'), findsOneWidget);
    expect(find.text('moderation'), findsOneWidget);
    expect(find.text('Scope: Moderation'), findsOneWidget);
    expect(find.text('Sort: Unread'), findsOneWidget);
    expect(find.text('Filters: 2'), findsOneWidget);
    expect(find.text('Re-run'), findsOneWidget);
    expect(find.text('Detach'), findsOneWidget);

    await tester.tap(find.text('Re-run'));
    await tester.pump();
    expect(applied?.id, 'saved_1');

    await tester.tap(find.text('Detach'));
    await tester.pump();
    expect(removed?.id, 'saved_1');
  });
}
