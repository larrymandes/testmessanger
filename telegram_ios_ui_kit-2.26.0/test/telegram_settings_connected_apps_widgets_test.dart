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
    'TelegramSettingsConnectedAppsCard renders and triggers callbacks',
    (tester) async {
      String? selectedId;
      String? revokedId;
      var manageTapped = false;

      const apps = [
        TelegramSettingsConnectedApp(
          id: 'wallet',
          name: 'Wallet Mini App',
          subtitle: 'Balance and transfers',
          lastUsedLabel: '5m ago',
          icon: CupertinoIcons.creditcard_fill,
          verified: true,
        ),
        TelegramSettingsConnectedApp(
          id: 'crm',
          name: 'CRM Bot',
          subtitle: 'Reads contact metadata',
          lastUsedLabel: '2h ago',
          icon: CupertinoIcons.archivebox_fill,
          warningCount: 1,
        ),
        TelegramSettingsConnectedApp(
          id: 'disabled',
          name: 'Disabled App',
          lastUsedLabel: '1d ago',
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          TelegramSettingsConnectedAppsCard(
            apps: apps,
            onSelected: (app) {
              selectedId = app.id;
            },
            onManageTap: () {
              manageTapped = true;
            },
            onRevokeTap: (app) {
              revokedId = app.id;
            },
          ),
        ),
      );

      expect(find.text('Connected Apps'), findsOneWidget);
      expect(find.text('Wallet Mini App'), findsOneWidget);
      expect(find.text('CRM Bot'), findsOneWidget);
      expect(find.text('Disabled App'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('Revoke'), findsNWidgets(2));
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(manageTapped, isTrue);

      await tester.tap(find.text('Wallet Mini App'));
      await tester.pumpAndSettle();
      expect(selectedId, 'wallet');

      await tester.tap(find.text('Revoke').first);
      await tester.pumpAndSettle();
      expect(revokedId, 'wallet');

      selectedId = null;
      await tester.tap(find.text('Disabled App'));
      await tester.pumpAndSettle();
      expect(selectedId, isNull);
    },
  );

  testWidgets('TelegramSettingsConnectedAppsCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsConnectedAppsCard(
          apps: [],
          emptyLabel: 'No authorized apps',
        ),
      ),
    );

    expect(find.text('No authorized apps'), findsOneWidget);
  });
}
