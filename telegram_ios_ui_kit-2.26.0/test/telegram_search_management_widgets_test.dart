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
  testWidgets('TelegramSearchSortBar invokes selection callback', (
    tester,
  ) async {
    TelegramSearchSortOption? selected;
    const options = [
      TelegramSearchSortOption(id: 'relevance', label: 'Relevance'),
      TelegramSearchSortOption(id: 'newest', label: 'Newest'),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSearchSortBar(
          options: options,
          selectedId: 'relevance',
          onSelected: (value) {
            selected = value;
          },
        ),
      ),
    );

    await tester.tap(find.text('Newest'));
    await tester.pump();
    expect(selected?.id, 'newest');
  });

  testWidgets('TelegramSearchResultStatsBar renders count and metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSearchResultStatsBar(
          query: 'video',
          resultCount: 4,
          scopeLabel: 'Chats',
          dateRangeLabel: 'Last 24h',
          sortLabel: 'Newest',
          activeFilterCount: 2,
          elapsedMs: 18,
        ),
      ),
    );

    expect(find.text('Results for "video"'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Scope: Chats'), findsOneWidget);
    expect(find.text('Range: Last 24h'), findsOneWidget);
    expect(find.text('Sort: Newest'), findsOneWidget);
    expect(find.text('Filters: 2'), findsOneWidget);
  });

  testWidgets('TelegramSearchHistorySheet supports remove and clear', (
    tester,
  ) async {
    String? removed;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchHistorySheet.show(
                    context,
                    entries: const ['design tokens', 'moderation'],
                    onRemove: (value) {
                      removed = value;
                    },
                    onClearAll: () {
                      cleared = true;
                    },
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Search History'), findsOneWidget);

    final firstTile = find.byType(TelegramSearchSuggestionTile).first;
    final removeButton = find.descendant(
      of: firstTile,
      matching: find.byIcon(CupertinoIcons.xmark_circle_fill),
    );
    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    expect(removed, 'design tokens');

    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    expect(cleared, isTrue);
    expect(find.text('No recent searches.'), findsOneWidget);
  });

  testWidgets('TelegramSearchHistorySheet selects query and closes', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchHistorySheet.show(
                    context,
                    entries: const ['design tokens', 'moderation'],
                    onSelected: (value) {
                      selected = value;
                    },
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('moderation'));
    await tester.pumpAndSettle();
    expect(selected, 'moderation');
    expect(find.text('Search History'), findsNothing);
  });
}
