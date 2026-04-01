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
  testWidgets('TelegramSettingsSyncStatusCard renders and handles callbacks', (
    tester,
  ) async {
    String? tappedId;
    var syncNowTapped = false;

    const items = [
      TelegramSettingsSyncStatusItem(
        id: 'contacts',
        title: 'Contacts',
        statusLabel: 'Synced',
        subtitle: '2m ago',
        icon: CupertinoIcons.person_2_fill,
      ),
      TelegramSettingsSyncStatusItem(
        id: 'messages',
        title: 'Message History',
        statusLabel: 'In Progress',
        subtitle: 'Syncing...',
        inProgress: true,
      ),
      TelegramSettingsSyncStatusItem(
        id: 'media',
        title: 'Media Index',
        statusLabel: 'Issue',
        subtitle: '3 files failed',
        warning: true,
      ),
      TelegramSettingsSyncStatusItem(
        id: 'disabled',
        title: 'Disabled Sync',
        statusLabel: 'Paused',
        enabled: false,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsSyncStatusCard(
          summaryLabel: 'Last full sync today at 09:42',
          items: items,
          onItemTap: (item) {
            tappedId = item.id;
          },
          onSyncNowTap: () {
            syncNowTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Sync Status'), findsOneWidget);
    expect(find.text('Last full sync today at 09:42'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Message History'), findsOneWidget);
    expect(find.text('Media Index'), findsOneWidget);
    expect(find.text('1 Issue'), findsOneWidget);
    expect(find.text('Sync Now'), findsOneWidget);

    await tester.tap(find.text('Sync Now'));
    await tester.pumpAndSettle();
    expect(syncNowTapped, isTrue);

    await tester.tap(find.text('Message History'));
    await tester.pumpAndSettle();
    expect(tappedId, 'messages');

    tappedId = null;
    await tester.tap(find.text('Disabled Sync'));
    await tester.pumpAndSettle();
    expect(tappedId, isNull);
  });

  testWidgets('TelegramSettingsSyncStatusCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsSyncStatusCard(
          items: [],
          emptyLabel: 'No sync tasks',
        ),
      ),
    );

    expect(find.text('No sync tasks'), findsOneWidget);
  });
}
