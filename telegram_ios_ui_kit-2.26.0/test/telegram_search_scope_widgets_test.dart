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
  testWidgets('TelegramSearchScopesBar selects scope', (tester) async {
    TelegramSearchScope? selectedScope;
    const scopes = [
      TelegramSearchScope(id: 'all', label: 'All', count: 3),
      TelegramSearchScope(id: 'people', label: 'People', count: 1),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSearchScopesBar(
          scopes: scopes,
          selectedId: 'all',
          onSelected: (scope) {
            selectedScope = scope;
          },
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    await tester.tap(find.text('People'));
    await tester.pump();
    expect(selectedScope?.id, 'people');
  });

  testWidgets('TelegramSearchSuggestionTile invokes callbacks', (tester) async {
    var tapped = false;
    var removed = false;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchSuggestionTile(
          query: 'design tokens',
          subtitle: 'Tap to run this quick search',
          icon: CupertinoIcons.sparkles,
          onTap: () {
            tapped = true;
          },
          onRemove: () {
            removed = true;
          },
        ),
      ),
    );

    expect(find.text('design tokens'), findsOneWidget);
    await tester.tap(find.text('design tokens'));
    await tester.pump();
    await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
    await tester.pump();

    expect(tapped, isTrue);
    expect(removed, isTrue);
  });
}
