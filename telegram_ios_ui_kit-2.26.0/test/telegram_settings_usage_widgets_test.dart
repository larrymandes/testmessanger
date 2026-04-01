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
  testWidgets('TelegramSettingsUsageCard renders segments and manage action', (
    tester,
  ) async {
    var manageTapped = false;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsUsageCard(
          title: 'Device Storage',
          totalLabel: '2.3 GB used',
          onManageTap: () {
            manageTapped = true;
          },
          segments: const [
            TelegramSettingsUsageSegment(
              id: 'media',
              label: 'Media',
              ratio: 0.5,
              valueLabel: '1.1 GB',
            ),
            TelegramSettingsUsageSegment(
              id: 'files',
              label: 'Files',
              ratio: 0.3,
              valueLabel: '600 MB',
            ),
            TelegramSettingsUsageSegment(
              id: 'cache',
              label: 'Cache',
              ratio: 0.2,
              valueLabel: '600 MB',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Device Storage'), findsOneWidget);
    expect(find.text('2.3 GB used'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('Cache'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);

    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    expect(manageTapped, isTrue);
  });

  testWidgets('TelegramSettingsUsageCard shows empty state when no segments', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsUsageCard(
          totalLabel: '0 B used',
          segments: [],
          emptyLabel: 'Nothing stored yet',
        ),
      ),
    );

    expect(find.text('0 B used'), findsOneWidget);
    expect(find.text('Nothing stored yet'), findsOneWidget);
  });
}
