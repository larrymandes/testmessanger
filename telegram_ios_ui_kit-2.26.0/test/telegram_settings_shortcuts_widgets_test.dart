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
  const shortcuts = [
    TelegramSettingsShortcut(
      id: 'shortcut_privacy',
      title: 'Privacy',
      subtitle: 'Last Seen, blocked users',
      icon: CupertinoIcons.lock_fill,
    ),
    TelegramSettingsShortcut(
      id: 'shortcut_devices',
      title: 'Devices',
      subtitle: '3 active sessions',
      icon: CupertinoIcons.device_phone_portrait,
      badgeLabel: '3',
    ),
  ];

  testWidgets('TelegramSettingsShortcutTile triggers callback', (tester) async {
    TelegramSettingsShortcut? selected;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsShortcutTile(
          shortcut: shortcuts[0],
          onTap: (value) {
            selected = value;
          },
        ),
      ),
    );

    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Last Seen, blocked users'), findsOneWidget);

    await tester.tap(find.text('Privacy'));
    await tester.pump();
    expect(selected?.id, 'shortcut_privacy');
  });

  testWidgets('TelegramSettingsShortcutsGrid renders and selects shortcut', (
    tester,
  ) async {
    TelegramSettingsShortcut? selected;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsShortcutsGrid(
          shortcuts: shortcuts,
          onSelected: (value) {
            selected = value;
          },
        ),
      ),
    );

    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('Devices'));
    await tester.pump();
    expect(selected?.id, 'shortcut_devices');
  });
}
