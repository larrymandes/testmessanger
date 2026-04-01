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
  const commands = [
    TelegramSearchCommand(
      id: 'clear_filters',
      title: 'Clear Filters',
      subtitle: 'Remove all active filters',
      icon: CupertinoIcons.slider_horizontal_3,
      badgeLabel: '2',
    ),
    TelegramSearchCommand(
      id: 'clear_history',
      title: 'Clear History',
      subtitle: 'Remove recent search records',
      icon: CupertinoIcons.trash_fill,
      destructive: true,
    ),
  ];

  testWidgets('TelegramSearchCommandTile renders metadata and callback', (
    tester,
  ) async {
    TelegramSearchCommand? tapped;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchCommandTile(
          command: commands.first,
          onTap: (command) {
            tapped = command;
          },
        ),
      ),
    );

    expect(find.text('Clear Filters'), findsOneWidget);
    expect(find.text('Remove all active filters'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pump();
    expect(tapped?.id, 'clear_filters');
  });

  testWidgets('TelegramSearchCommandsSheet selects action and closes', (
    tester,
  ) async {
    TelegramSearchCommand? selected;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchCommandsSheet.show(
                    context,
                    commands: commands,
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
    expect(find.text('Search Actions'), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'clear_filters');
    expect(find.text('Search Actions'), findsNothing);
  });

  testWidgets('TelegramSearchCommandsSheet supports empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const TelegramSearchCommandsSheet(commands: [])),
    );

    expect(find.text('No actions available.'), findsOneWidget);
  });
}
