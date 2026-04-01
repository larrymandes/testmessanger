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
  testWidgets('TelegramSettingsDataUsageCard renders and triggers callbacks', (
    tester,
  ) async {
    String? selectedId;
    var resetTapped = false;

    const items = [
      TelegramSettingsDataUsageItem(
        id: 'photos',
        title: 'Photos',
        valueLabel: '1.2 GB',
        subtitle: 'Auto-download on Wi-Fi',
        icon: CupertinoIcons.photo_fill,
      ),
      TelegramSettingsDataUsageItem(
        id: 'videos',
        title: 'Videos',
        valueLabel: '2.1 GB',
        subtitle: 'Streaming',
        icon: CupertinoIcons.videocam_fill,
        highlighted: true,
      ),
      TelegramSettingsDataUsageItem(
        id: 'disabled',
        title: 'Documents',
        valueLabel: '320 MB',
        enabled: false,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsDataUsageCard(
          subtitle: 'Updated 4 minutes ago',
          items: items,
          onItemTap: (item) {
            selectedId = item.id;
          },
          onResetTap: () {
            resetTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Data Usage'), findsOneWidget);
    expect(find.text('Updated 4 minutes ago'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(resetTapped, isTrue);

    await tester.tap(find.text('Videos'));
    await tester.pumpAndSettle();
    expect(selectedId, 'videos');

    selectedId = null;
    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();
    expect(selectedId, isNull);
  });

  testWidgets('TelegramSettingsDataUsageCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsDataUsageCard(items: [], emptyLabel: 'No stats'),
      ),
    );

    expect(find.text('No stats'), findsOneWidget);
  });
}
