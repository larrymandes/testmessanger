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
  const ranges = [
    TelegramSearchDateRange(
      id: 'anytime',
      label: 'Anytime',
      description: 'Include all matched results',
      icon: CupertinoIcons.clock_fill,
    ),
    TelegramSearchDateRange(
      id: 'today',
      label: 'Today',
      description: 'Only results from today',
      icon: CupertinoIcons.sun_max_fill,
    ),
    TelegramSearchDateRange(
      id: 'last24h',
      label: 'Last 24h',
      description: 'Today and yesterday updates',
      icon: CupertinoIcons.timer_fill,
    ),
  ];

  testWidgets('TelegramSearchDateRangesBar invokes selection callback', (
    tester,
  ) async {
    TelegramSearchDateRange? selected;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchDateRangesBar(
          ranges: ranges,
          selectedId: 'anytime',
          onSelected: (value) {
            selected = value;
          },
        ),
      ),
    );

    await tester.tap(find.text('Today'));
    await tester.pump();
    expect(selected?.id, 'today');
  });

  testWidgets('TelegramSearchDateRangesSheet selects range and closes', (
    tester,
  ) async {
    TelegramSearchDateRange? selected;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchDateRangesSheet.show(
                    context,
                    ranges: ranges,
                    selectedId: 'anytime',
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
    expect(find.text('Date Range'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'today');
    expect(find.text('Date Range'), findsNothing);
  });

  testWidgets('TelegramSearchDateRangesSheet supports clear action', (
    tester,
  ) async {
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchDateRangesSheet.show(
                    context,
                    ranges: ranges,
                    selectedId: 'today',
                    onSelected: (_) {},
                    onClear: () {
                      cleared = true;
                    },
                    clearLabel: 'Clear Range',
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
    await tester.tap(find.text('Clear Range'));
    await tester.pumpAndSettle();
    expect(cleared, isTrue);
  });
}
