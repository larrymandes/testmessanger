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
  testWidgets('TelegramAdminMemberTile renders member content', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramAdminMemberTile(
          member: TelegramAdminMember(
            id: 'admin_1',
            name: 'Alex Morgan',
            roleLabel: 'Owner',
            avatarFallback: 'AM',
            pendingReports: 2,
          ),
        ),
      ),
    );

    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('TelegramPermissionsPanel notifies switch updates', (
    tester,
  ) async {
    TelegramPermissionToggle? changed;
    bool? changedValue;
    await tester.pumpWidget(
      _wrap(
        TelegramPermissionsPanel(
          toggles: const [
            TelegramPermissionToggle(
              id: 'perm_pin',
              label: 'Pin Messages',
              enabled: false,
              icon: CupertinoIcons.pin_fill,
            ),
          ],
          onToggleChanged: (toggle, value) {
            changed = toggle;
            changedValue = value;
          },
        ),
      ),
    );

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();

    expect(changed?.id, 'perm_pin');
    expect(changedValue, isTrue);
  });

  testWidgets('TelegramModerationQueueCard callbacks are invoked', (
    tester,
  ) async {
    TelegramModerationRequest? opened;
    var reviewAllTapped = false;
    const requests = [
      TelegramModerationRequest(
        id: 'review_1',
        title: 'Reported message in #general',
        subtitle: 'Contains external promotion link',
        timeLabel: '10:42',
        pendingCount: 3,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramModerationQueueCard(
          requests: requests,
          onRequestTap: (request) {
            opened = request;
          },
          onReviewAll: () {
            reviewAllTapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Reported message in #general'));
    await tester.pump();
    expect(opened?.id, 'review_1');

    await tester.tap(find.text('Review All'));
    await tester.pump();
    expect(reviewAllTapped, isTrue);
  });
}
