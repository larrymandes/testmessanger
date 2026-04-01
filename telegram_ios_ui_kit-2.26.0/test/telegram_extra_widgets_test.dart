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
  testWidgets('TelegramSearchBar renders hint', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Padding(
          padding: EdgeInsets.all(8),
          child: TelegramSearchBar(hintText: 'Search contacts'),
        ),
      ),
    );

    expect(find.text('Search contacts'), findsOneWidget);
  });

  testWidgets('TelegramContactListTile renders contact name', (tester) async {
    const contact = TelegramContact(
      id: '1',
      name: 'Alice Johnson',
      subtitle: 'Designer',
      avatarFallback: 'AJ',
      isVerified: true,
    );

    await tester.pumpWidget(
      _wrap(const TelegramContactListTile(contact: contact)),
    );
    expect(find.text('Alice Johnson'), findsOneWidget);
    expect(find.text('Designer'), findsOneWidget);
  });

  testWidgets('TelegramCallListTile renders call metadata', (tester) async {
    const call = TelegramCallLog(
      id: 'call_1',
      name: 'Design Team',
      timeLabel: 'Today 12:00',
      durationLabel: '10:02',
      direction: TelegramCallDirection.outgoing,
      type: TelegramCallType.video,
      avatarFallback: 'DT',
    );

    await tester.pumpWidget(_wrap(const TelegramCallListTile(call: call)));
    expect(find.text('Design Team'), findsOneWidget);
    expect(find.text('Today 12:00 · 10:02'), findsOneWidget);
  });
}
