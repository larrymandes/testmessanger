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
  testWidgets(
    'TelegramSettingsCleanupSuggestionsCard renders and handles callbacks',
    (tester) async {
      String? selectedId;
      var cleanupTapped = false;

      const suggestions = [
        TelegramSettingsCleanupSuggestion(
          id: 'videos',
          title: 'Large Videos',
          sizeLabel: '1.9 GB',
          subtitle: 'Older than 30 days',
          icon: CupertinoIcons.videocam_fill,
        ),
        TelegramSettingsCleanupSuggestion(
          id: 'cache',
          title: 'Temporary Cache',
          sizeLabel: '740 MB',
          subtitle: 'Safe to remove',
          icon: CupertinoIcons.archivebox_fill,
        ),
        TelegramSettingsCleanupSuggestion(
          id: 'disabled',
          title: 'Disabled Rule',
          sizeLabel: '0 B',
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          TelegramSettingsCleanupSuggestionsCard(
            suggestions: suggestions,
            onSelected: (item) {
              selectedId = item.id;
            },
            onRunCleanupTap: () {
              cleanupTapped = true;
            },
          ),
        ),
      );

      expect(find.text('Cleanup Suggestions'), findsOneWidget);
      expect(find.text('Large Videos'), findsOneWidget);
      expect(find.text('Temporary Cache'), findsOneWidget);
      expect(find.text('Run Cleanup'), findsOneWidget);

      await tester.tap(find.text('Run Cleanup'));
      await tester.pumpAndSettle();
      expect(cleanupTapped, isTrue);

      await tester.tap(find.text('Temporary Cache'));
      await tester.pumpAndSettle();
      expect(selectedId, 'cache');

      selectedId = null;
      await tester.tap(find.text('Disabled Rule'));
      await tester.pumpAndSettle();
      expect(selectedId, isNull);
    },
  );

  testWidgets('TelegramSettingsCleanupSuggestionsCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsCleanupSuggestionsCard(
          suggestions: [],
          emptyLabel: 'Nothing to clean',
        ),
      ),
    );

    expect(find.text('Nothing to clean'), findsOneWidget);
  });
}
