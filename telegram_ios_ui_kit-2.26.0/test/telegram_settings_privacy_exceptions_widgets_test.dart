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
    'TelegramSettingsPrivacyExceptionsCard renders and handles callbacks',
    (tester) async {
      String? selectedId;
      var manageTapped = false;

      const items = [
        TelegramSettingsPrivacyException(
          id: 'always',
          title: 'Always Share With',
          subtitle: 'Visibility allow-list',
          countLabel: '8',
          icon: CupertinoIcons.eye_fill,
        ),
        TelegramSettingsPrivacyException(
          id: 'never',
          title: 'Never Share With',
          subtitle: 'Visibility deny-list',
          countLabel: '3',
          icon: CupertinoIcons.eye_slash_fill,
        ),
        TelegramSettingsPrivacyException(
          id: 'blocked',
          title: 'Blocked Users',
          countLabel: '12',
          destructive: true,
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          TelegramSettingsPrivacyExceptionsCard(
            description: 'Manage privacy overrides',
            items: items,
            onSelected: (item) {
              selectedId = item.id;
            },
            onManageTap: () {
              manageTapped = true;
            },
          ),
        ),
      );

      expect(find.text('Privacy Exceptions'), findsOneWidget);
      expect(find.text('Manage privacy overrides'), findsOneWidget);
      expect(find.text('Always Share With'), findsOneWidget);
      expect(find.text('Never Share With'), findsOneWidget);
      expect(find.text('Blocked Users'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(manageTapped, isTrue);

      await tester.tap(find.text('Never Share With'));
      await tester.pumpAndSettle();
      expect(selectedId, 'never');

      selectedId = null;
      await tester.tap(find.text('Blocked Users'));
      await tester.pumpAndSettle();
      expect(selectedId, isNull);
    },
  );

  testWidgets('TelegramSettingsPrivacyExceptionsCard shows empty message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsPrivacyExceptionsCard(
          items: [],
          emptyLabel: 'No exceptions',
        ),
      ),
    );

    expect(find.text('No exceptions'), findsOneWidget);
  });
}
