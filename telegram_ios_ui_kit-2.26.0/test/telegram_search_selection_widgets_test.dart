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
  testWidgets('TelegramSearchSelectionSummaryCard triggers callbacks', (
    tester,
  ) async {
    var selectedAll = false;
    var cleared = false;
    var exited = false;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchSelectionSummaryCard(
          selectedCount: 2,
          totalCount: 4,
          onSelectAll: () {
            selectedAll = true;
          },
          onClearSelection: () {
            cleared = true;
          },
          onExit: () {
            exited = true;
          },
        ),
      ),
    );

    expect(find.text('Selected 2 of 4'), findsOneWidget);
    expect(find.text('Select All'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Select All'));
    await tester.pump();
    expect(selectedAll, isTrue);

    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(cleared, isTrue);

    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(exited, isTrue);
  });

  testWidgets('TelegramSearchResultActionBar invokes selected action', (
    tester,
  ) async {
    TelegramSearchResultAction? selectedAction;
    const actions = [
      TelegramSearchResultAction(
        id: 'mark_read',
        label: 'Mark Read',
        icon: CupertinoIcons.envelope_open_fill,
        badgeLabel: '2',
      ),
      TelegramSearchResultAction(
        id: 'delete',
        label: 'Delete',
        icon: CupertinoIcons.delete_solid,
        destructive: true,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSearchResultActionBar(
          actions: actions,
          onSelected: (value) {
            selectedAction = value;
          },
        ),
      ),
    );

    expect(find.text('Mark Read'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(selectedAction?.id, 'delete');
  });
}
