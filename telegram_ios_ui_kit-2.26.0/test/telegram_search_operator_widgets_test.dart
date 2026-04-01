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
  const operators = [
    TelegramSearchOperator(
      id: 'op_1',
      label: 'From',
      token: 'from:alice',
      description: 'Filter by sender',
      icon: CupertinoIcons.person_fill,
    ),
    TelegramSearchOperator(
      id: 'op_2',
      label: 'Has Link',
      token: 'has:link',
      description: 'Contains links',
      icon: CupertinoIcons.link,
    ),
  ];

  testWidgets('TelegramSearchOperatorsBar triggers selection callback', (
    tester,
  ) async {
    TelegramSearchOperator? selected;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchOperatorsBar(
          operators: operators,
          highlightedId: 'op_1',
          onSelected: (value) {
            selected = value;
          },
        ),
      ),
    );

    expect(find.text('From'), findsOneWidget);
    expect(find.text('from:alice'), findsOneWidget);
    expect(find.text('Has Link'), findsOneWidget);

    await tester.tap(find.text('Has Link'));
    await tester.pump();
    expect(selected?.id, 'op_2');
  });

  testWidgets('TelegramSearchOperatorsSheet selects operator and closes', (
    tester,
  ) async {
    TelegramSearchOperator? selected;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchOperatorsSheet.show(
                    context,
                    operators: operators,
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
    expect(find.text('Search Operators'), findsOneWidget);

    await tester.tap(find.text('From · from:alice'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'op_1');
    expect(find.text('Search Operators'), findsNothing);
  });

  testWidgets('TelegramSearchOperatorsSheet supports empty state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSearchOperatorsSheet(
          operators: [],
        ),
      ),
    );

    expect(find.text('No operators.'), findsOneWidget);
  });
}
