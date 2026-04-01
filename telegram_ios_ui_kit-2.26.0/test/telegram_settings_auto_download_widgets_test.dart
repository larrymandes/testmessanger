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
  testWidgets(
    'TelegramSettingsAutoDownloadCard renders presets and callbacks',
    (tester) async {
      String? selectedId;
      var manageTapped = false;

      const presets = [
        TelegramSettingsAutoDownloadPreset(
          id: 'low',
          label: 'Low',
          mediaLimitLabel: 'Up to 256 KB',
        ),
        TelegramSettingsAutoDownloadPreset(
          id: 'standard',
          label: 'Standard',
          mediaLimitLabel: 'Up to 2 MB',
        ),
        TelegramSettingsAutoDownloadPreset(
          id: 'high',
          label: 'High',
          mediaLimitLabel: 'Up to 20 MB',
        ),
        TelegramSettingsAutoDownloadPreset(
          id: 'disabled',
          label: 'Disabled',
          mediaLimitLabel: 'No downloads',
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          TelegramSettingsAutoDownloadCard(
            presets: presets,
            selectedId: 'standard',
            onSelected: (preset) {
              selectedId = preset.id;
            },
            onManageTap: () {
              manageTapped = true;
            },
          ),
        ),
      );

      expect(find.text('Auto-Download'), findsOneWidget);
      expect(find.text('Standard · Up to 2 MB'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(manageTapped, isTrue);

      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();
      expect(selectedId, 'high');

      selectedId = null;
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      expect(selectedId, isNull);
    },
  );

  testWidgets('TelegramSettingsAutoDownloadCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsAutoDownloadCard(
          presets: [],
          selectedId: '',
          emptyLabel: 'No presets',
        ),
      ),
    );

    expect(find.text('No presets'), findsOneWidget);
  });
}
