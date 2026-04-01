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
  testWidgets('TelegramSettingsSecurityEventsCard renders and handles taps', (
    tester,
  ) async {
    String? tappedId;
    var reviewTapped = false;

    const events = [
      TelegramSettingsSecurityEvent(
        id: 'login',
        title: 'New Login',
        subtitle: 'MacBook Pro',
        timeLabel: '2m ago',
        icon: CupertinoIcons.device_laptop,
      ),
      TelegramSettingsSecurityEvent(
        id: 'recovery',
        title: 'Recovery Email Removed',
        subtitle: 'Unknown location',
        timeLabel: '1h ago',
        icon: CupertinoIcons.exclamationmark_octagon_fill,
        highRisk: true,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsSecurityEventsCard(
          events: events,
          onEventTap: (event) {
            tappedId = event.id;
          },
          onReviewAllTap: () {
            reviewTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Recent Security Events'), findsOneWidget);
    expect(find.text('New Login'), findsOneWidget);
    expect(find.text('Recovery Email Removed'), findsOneWidget);
    expect(find.text('1 Risk'), findsOneWidget);
    expect(find.text('Review All'), findsOneWidget);

    await tester.tap(find.text('Review All'));
    await tester.pumpAndSettle();
    expect(reviewTapped, isTrue);

    await tester.tap(find.text('New Login'));
    await tester.pumpAndSettle();
    expect(tappedId, 'login');
  });

  testWidgets('TelegramSettingsSecurityEventsCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsSecurityEventsCard(
          events: [],
          emptyLabel: 'No events',
        ),
      ),
    );

    expect(find.text('No events'), findsOneWidget);
  });
}
