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
  testWidgets('TelegramSettingsQuietHoursCard renders and handles callbacks', (
    tester,
  ) async {
    String? selectedId;
    bool? enabledValue;
    var customizeTapped = false;

    const presets = [
      TelegramSettingsQuietHoursPreset(
        id: 'night',
        label: 'Night',
        timeRangeLabel: '22:00 - 07:00',
        daysLabel: 'Every day',
      ),
      TelegramSettingsQuietHoursPreset(
        id: 'work',
        label: 'Work Focus',
        timeRangeLabel: '09:30 - 12:00',
        daysLabel: 'Mon - Fri',
      ),
      TelegramSettingsQuietHoursPreset(
        id: 'disabled',
        label: 'Disabled',
        timeRangeLabel: '--',
        enabled: false,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsQuietHoursCard(
          enabled: true,
          presets: presets,
          selectedPresetId: 'night',
          onEnabledChanged: (enabled) {
            enabledValue = enabled;
          },
          onPresetSelected: (preset) {
            selectedId = preset.id;
          },
          onCustomizeTap: () {
            customizeTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Quiet Hours'), findsOneWidget);
    expect(find.text('Night · 22:00 - 07:00'), findsOneWidget);
    expect(find.text('Customize'), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsOneWidget);

    await tester.tap(find.text('Customize'));
    await tester.pumpAndSettle();
    expect(customizeTapped, isTrue);

    await tester.tap(find.text('Work Focus'));
    await tester.pumpAndSettle();
    expect(selectedId, 'work');

    selectedId = null;
    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();
    expect(selectedId, isNull);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(enabledValue, isFalse);
  });

  testWidgets('TelegramSettingsQuietHoursCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsQuietHoursCard(
          enabled: false,
          presets: [],
          selectedPresetId: '',
          emptyLabel: 'No presets',
        ),
      ),
    );

    expect(find.text('Quiet hours disabled'), findsOneWidget);
    expect(find.text('No presets'), findsOneWidget);
  });
}
