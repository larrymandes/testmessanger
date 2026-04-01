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
  testWidgets('TelegramChannelInfoHeader renders basic content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramChannelInfoHeader(
          title: 'Telegram iOS UI Kit',
          subtitle: '@telegram_ios_ui_kit',
          description: 'Reusable widgets and layouts',
          avatarFallback: 'TK',
          isVerified: true,
        ),
      ),
    );

    expect(find.text('Telegram iOS UI Kit'), findsOneWidget);
    expect(find.text('@telegram_ios_ui_kit'), findsOneWidget);
    expect(find.text('Reusable widgets and layouts'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.checkmark_seal_fill), findsOneWidget);
  });

  testWidgets('TelegramChannelInfoHeader action taps callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        TelegramChannelInfoHeader(
          title: 'Channel',
          subtitle: '@channel',
          avatarFallback: 'CH',
          actions: [
            TelegramChannelInfoAction(
              icon: CupertinoIcons.bell,
              label: 'Mute',
              onTap: () {
                tapped = true;
              },
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Mute'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('TelegramChannelStatsGrid renders metrics and handles tap', (
    tester,
  ) async {
    TelegramChannelStatItem? tapped;
    const stats = [
      TelegramChannelStatItem(
        label: 'Subscribers',
        value: '48.2K',
        icon: CupertinoIcons.person_3_fill,
      ),
      TelegramChannelStatItem(label: 'Media', value: '1.3K'),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramChannelStatsGrid(
          items: stats,
          onItemTap: (item) {
            tapped = item;
          },
        ),
      ),
    );

    expect(find.text('48.2K'), findsOneWidget);
    expect(find.text('Subscribers'), findsOneWidget);
    expect(find.text('1.3K'), findsOneWidget);

    await tester.tap(find.text('Media'));
    await tester.pump();
    expect(tapped?.label, 'Media');
  });
}
