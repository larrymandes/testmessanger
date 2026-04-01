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
  testWidgets('TelegramSettingsSectionFooter renders message', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsSectionFooter(
          message: 'Advanced rules apply to all chats.',
        ),
      ),
    );

    expect(find.text('Advanced rules apply to all chats.'), findsOneWidget);
  });

  testWidgets('TelegramSettingsCollapsibleSection toggles and reports state', (
    tester,
  ) async {
    bool? expandedValue;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsCollapsibleSection(
          title: 'Advanced Notifications',
          initiallyExpanded: false,
          onExpandedChanged: (expanded) {
            expandedValue = expanded;
          },
          children: const [
            TelegramSettingsCell(
              title: 'Show Message Preview',
              showChevron: false,
              showDivider: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Show Message Preview'), findsNothing);
    expect(find.text('Expand'), findsOneWidget);

    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();
    expect(expandedValue, isTrue);
    expect(find.text('Show Message Preview'), findsOneWidget);
    expect(find.text('Collapse'), findsOneWidget);
  });
}
