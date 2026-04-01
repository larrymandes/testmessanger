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
  testWidgets('TelegramSettingsSessionsCard renders sessions and callbacks', (
    tester,
  ) async {
    String? tappedSessionId;
    var manageTapped = false;
    var viewAllTapped = false;

    const sessions = [
      TelegramSettingsSession(
        id: 's1',
        deviceName: 'iPhone 15 Pro',
        platformLabel: 'iOS',
        lastActiveLabel: 'now',
        isCurrentDevice: true,
      ),
      TelegramSettingsSession(
        id: 's2',
        deviceName: 'MacBook Pro',
        platformLabel: 'macOS',
        lastActiveLabel: '2m ago',
        isOnline: true,
      ),
      TelegramSettingsSession(
        id: 's3',
        deviceName: 'iPad',
        platformLabel: 'iPadOS',
        lastActiveLabel: '1h ago',
        icon: CupertinoIcons.device_phone_portrait,
      ),
      TelegramSettingsSession(
        id: 's4',
        deviceName: 'Telegram Web',
        platformLabel: 'Chrome',
        lastActiveLabel: '3h ago',
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsSessionsCard(
          subtitle: '4 devices signed in',
          sessions: sessions,
          onSessionTap: (session) {
            tappedSessionId = session.id;
          },
          onManageTap: () {
            manageTapped = true;
          },
          onViewAllTap: () {
            viewAllTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Active Sessions'), findsOneWidget);
    expect(find.text('4 devices signed in'), findsOneWidget);
    expect(find.text('iPhone 15 Pro'), findsOneWidget);
    expect(find.text('MacBook Pro'), findsOneWidget);
    expect(find.text('iPad'), findsOneWidget);
    expect(find.text('Telegram Web'), findsNothing);
    expect(find.text('This Device'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('View All (4)'), findsOneWidget);

    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    expect(manageTapped, isTrue);

    await tester.tap(find.text('iPad'));
    await tester.pumpAndSettle();
    expect(tappedSessionId, 's3');

    await tester.tap(find.text('View All (4)'));
    await tester.pumpAndSettle();
    expect(viewAllTapped, isTrue);
  });

  testWidgets('TelegramSettingsSessionsCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsSessionsCard(
          sessions: [],
          emptyLabel: 'No signed in devices',
        ),
      ),
    );

    expect(find.text('No signed in devices'), findsOneWidget);
  });
}
