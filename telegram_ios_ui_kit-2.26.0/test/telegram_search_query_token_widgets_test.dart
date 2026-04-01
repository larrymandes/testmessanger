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
  const tokens = [
    TelegramSearchQueryToken(
      id: 'token_1',
      value: 'from:alice',
      label: 'From: from:alice',
      icon: CupertinoIcons.person_fill,
      isOperator: true,
    ),
    TelegramSearchQueryToken(
      id: 'token_2',
      value: 'moderation',
      label: 'moderation',
      isOperator: false,
    ),
  ];

  testWidgets('TelegramSearchQueryTokensBar remove and clear callbacks', (
    tester,
  ) async {
    TelegramSearchQueryToken? removed;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchQueryTokensBar(
          tokens: tokens,
          onRemove: (value) {
            removed = value;
          },
          onClearAll: () {
            cleared = true;
          },
        ),
      ),
    );

    expect(find.text('From: from:alice'), findsOneWidget);
    expect(find.text('moderation'), findsOneWidget);
    expect(find.text('Clear Tokens'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill).first);
    await tester.pump();
    expect(removed?.id, 'token_1');

    await tester.tap(find.text('Clear Tokens'));
    await tester.pump();
    expect(cleared, isTrue);
  });

  testWidgets('TelegramSearchQueryInspectorCard renders metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSearchQueryInspectorCard(
          query: 'from:alice moderation',
          keyword: 'moderation',
          resultCount: 3,
          tokenCount: 2,
          operatorCount: 1,
          scopeLabel: 'All',
          dateRangeLabel: 'Last 24h',
          sortLabel: 'Relevance',
        ),
      ),
    );

    expect(find.text('Query Inspector'), findsOneWidget);
    expect(find.text('from:alice moderation'), findsOneWidget);
    expect(find.text('Results: 3'), findsOneWidget);
    expect(find.text('Tokens: 2'), findsOneWidget);
    expect(find.text('Operators: 1'), findsOneWidget);
    expect(find.text('Keyword: moderation'), findsOneWidget);
    expect(find.text('Scope: All'), findsOneWidget);
    expect(find.text('Range: Last 24h'), findsOneWidget);
    expect(find.text('Sort: Relevance'), findsOneWidget);
  });
}
