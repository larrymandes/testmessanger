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
  const options = [
    TelegramSettingsOption(
      id: 'tone_note',
      label: 'Note',
      subtitle: 'Default Telegram tone',
      icon: CupertinoIcons.music_note,
    ),
    TelegramSettingsOption(
      id: 'tone_chime',
      label: 'Chime',
      subtitle: 'Soft system chime',
      icon: CupertinoIcons.waveform_path,
      badgeLabel: 'New',
    ),
  ];

  testWidgets('TelegramSettingsOptionTile triggers callback', (tester) async {
    TelegramSettingsOption? selected;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsOptionTile(
          option: options[1],
          selected: true,
          onTap: (value) {
            selected = value;
          },
        ),
      ),
    );

    expect(find.text('Chime'), findsOneWidget);
    expect(find.text('Soft system chime'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);

    await tester.tap(find.text('Chime'));
    await tester.pump();
    expect(selected?.id, 'tone_chime');
  });

  testWidgets('TelegramSettingsOptionsSheet selects option and closes', (
    tester,
  ) async {
    TelegramSettingsOption? selected;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSettingsOptionsSheet.show(
                    context,
                    title: 'Notification Tone',
                    options: options,
                    selectedId: 'tone_note',
                    onSelected: (value) {
                      selected = value;
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
    expect(find.text('Notification Tone'), findsOneWidget);

    await tester.tap(find.text('Chime'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'tone_chime');
    expect(find.text('Notification Tone'), findsNothing);
  });

  testWidgets('TelegramSettingsOptionsSheet shows empty state', (tester) async {
    await tester.pumpWidget(
      _wrap(const TelegramSettingsOptionsSheet(options: [])),
    );

    expect(find.text('No options available.'), findsOneWidget);
  });
}
