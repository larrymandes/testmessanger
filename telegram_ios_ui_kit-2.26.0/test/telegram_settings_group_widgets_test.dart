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
  testWidgets('TelegramSettingsGroup renders header and footer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TelegramSettingsGroup(
          header: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Header'),
          ),
          footer: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Footer'),
          ),
          children: const [
            TelegramSettingsCell(title: 'Phone Number', subtitle: '+1 555'),
            TelegramSettingsCell(
              title: 'Username',
              subtitle: '@telegram',
              showDivider: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
  });

  testWidgets('TelegramSettingsCell supports switches', (tester) async {
    var value = true;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsCell(
          title: 'Enable Notifications',
          switchValue: value,
          showChevron: false,
          showDivider: false,
          onSwitchChanged: (next) {
            value = next;
          },
        ),
      ),
    );

    expect(find.text('Enable Notifications'), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();
    expect(value, isFalse);
  });
}
