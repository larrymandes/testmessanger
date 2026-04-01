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
  testWidgets('TelegramChatBackground renders child', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramChatBackground(
          child: Center(child: Text('Background Child')),
        ),
      ),
    );

    expect(find.text('Background Child'), findsOneWidget);
  });

  testWidgets('TelegramMediaAlbumMessage renders labels and caption', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramMediaAlbumMessage(
          items: ['One', 'Two', 'Three'],
          caption: 'Album preview',
          timeLabel: '14:10',
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Album preview'), findsOneWidget);
    expect(find.text('14:10'), findsOneWidget);
  });

  testWidgets('TelegramScheduleTimeline renders title and events', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramScheduleTimeline(
          title: 'Timeline',
          events: [
            TelegramTimelineEvent(
              id: '1',
              title: 'Design QA',
              timeLabel: '10:00',
            ),
            TelegramTimelineEvent(
              id: '2',
              title: 'Publish',
              timeLabel: '12:00',
              completed: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Design QA'), findsOneWidget);
    expect(find.text('Publish'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
  });
}
