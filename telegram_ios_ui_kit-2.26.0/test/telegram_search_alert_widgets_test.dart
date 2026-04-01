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
  const alerts = [
    TelegramSearchAlert(
      id: 'alert_1',
      label: 'Moderation Escalations',
      query: 'moderation',
      scopeLabel: 'Moderation',
      triggerLabel: 'When unread appears',
      deliveryLabel: 'In-app + Push',
      icon: CupertinoIcons.bell_fill,
      enabled: true,
      unreadCount: 2,
    ),
    TelegramSearchAlert(
      id: 'alert_2',
      label: 'Token Updates',
      query: 'design tokens',
      scopeLabel: 'Chats',
      triggerLabel: 'Daily digest',
      deliveryLabel: 'Summary',
      icon: CupertinoIcons.paintbrush_fill,
      enabled: false,
    ),
  ];

  testWidgets('TelegramSearchAlertTile renders metadata and callbacks', (
    tester,
  ) async {
    var tapped = false;
    bool? changed;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchAlertTile(
          alert: alerts.first,
          onTap: () {
            tapped = true;
          },
          onChanged: (value) {
            changed = value;
          },
        ),
      ),
    );

    expect(find.text('Moderation Escalations'), findsOneWidget);
    expect(find.text('moderation'), findsOneWidget);
    expect(
      find.text('Moderation · When unread appears · In-app + Push'),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Moderation Escalations'));
    await tester.pump();
    expect(tapped, isTrue);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();
    expect(changed, isFalse);
  });

  testWidgets('TelegramSearchAlertsSheet updates and disables alerts', (
    tester,
  ) async {
    TelegramSearchAlert? updated;
    var disabledAll = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchAlertsSheet.show(
                    context,
                    alerts: alerts,
                    onAlertChanged: (value) {
                      updated = value;
                    },
                    onDisableAll: () {
                      disabledAll = true;
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
    expect(find.text('Search Alerts'), findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch).first);
    await tester.pumpAndSettle();
    expect(updated?.id, 'alert_1');
    expect(updated?.enabled, isFalse);

    await tester.tap(find.text('Disable All'));
    await tester.pumpAndSettle();
    expect(disabledAll, isTrue);
    expect(find.text('Disable All'), findsNothing);
  });

  testWidgets('TelegramSearchAlertsSheet shows empty state', (tester) async {
    await tester.pumpWidget(_wrap(const TelegramSearchAlertsSheet(alerts: [])));

    expect(find.text('No alerts yet.'), findsOneWidget);
  });
}
