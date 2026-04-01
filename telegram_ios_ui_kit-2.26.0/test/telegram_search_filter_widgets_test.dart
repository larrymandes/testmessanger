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
  testWidgets('TelegramActiveSearchFiltersBar handles remove and clear', (
    tester,
  ) async {
    TelegramSearchFilterOption? removed;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        TelegramActiveSearchFiltersBar(
          filters: const [
            TelegramSearchFilterOption(
              id: 'links',
              label: 'Has Link',
              selected: true,
            ),
            TelegramSearchFilterOption(
              id: 'verified',
              label: 'Verified',
              selected: true,
            ),
            TelegramSearchFilterOption(id: 'media', label: 'Media'),
          ],
          onRemove: (filter) {
            removed = filter;
          },
          onClearAll: () {
            cleared = true;
          },
        ),
      ),
    );

    expect(find.text('Active Filters'), findsOneWidget);
    await tester.tap(find.text('Has Link'));
    await tester.pump();
    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(removed?.id, 'links');
    expect(cleared, isTrue);
  });

  testWidgets('TelegramSearchFiltersSheet updates options and applies', (
    tester,
  ) async {
    TelegramSearchFilterOption? updated;
    var resetCalled = false;
    var appliedCalled = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchFiltersSheet.show(
                    context,
                    options: const [
                      TelegramSearchFilterOption(id: 'unread', label: 'Unread'),
                      TelegramSearchFilterOption(
                        id: 'links',
                        label: 'Has Link',
                        selected: true,
                      ),
                    ],
                    onOptionChanged: (option) {
                      updated = option;
                    },
                    onReset: () {
                      resetCalled = true;
                    },
                    onApply: () {
                      appliedCalled = true;
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
    expect(find.text('Search Filters'), findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch).first);
    await tester.pumpAndSettle();
    expect(updated?.id, 'unread');
    expect(updated?.selected, isTrue);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(resetCalled, isTrue);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.startsWith('Apply') ?? false),
      ),
    );
    await tester.pumpAndSettle();
    expect(appliedCalled, isTrue);
    expect(find.text('Search Filters'), findsNothing);
  });
}
