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
  testWidgets('TelegramAdminAuditLogTile renders actor and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramAdminAuditLogTile(
          entry: TelegramAdminAuditLog(
            id: 'audit_1',
            actorName: 'Alex Morgan',
            actionLabel: 'promoted',
            targetLabel: 'Emma Rivera to Admin',
            timeLabel: 'Today 10:20',
          ),
        ),
      ),
    );

    expect(find.text('Alex Morgan promoted'), findsOneWidget);
    expect(find.text('Emma Rivera to Admin'), findsOneWidget);
    expect(find.text('Today 10:20'), findsOneWidget);
  });

  testWidgets('TelegramModerationDetailCard invokes action callbacks', (
    tester,
  ) async {
    var approved = false;
    var rejected = false;
    var threadOpened = false;

    await tester.pumpWidget(
      _wrap(
        TelegramModerationDetailCard(
          request: const TelegramModerationRequest(
            id: 'review_1',
            title: 'Reported message',
            subtitle: 'Possible phishing',
            timeLabel: '11:02',
          ),
          tags: const ['Urgent'],
          evidenceCount: 2,
          onApprove: () {
            approved = true;
          },
          onReject: () {
            rejected = true;
          },
          onOpenThread: () {
            threadOpened = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Approve'));
    await tester.pump();
    await tester.tap(find.text('Reject'));
    await tester.pump();
    await tester.tap(find.text('Open Thread'));
    await tester.pump();

    expect(approved, isTrue);
    expect(rejected, isTrue);
    expect(threadOpened, isTrue);
  });

  testWidgets('TelegramBannedMemberTile triggers unban callback', (
    tester,
  ) async {
    var unbanned = false;
    await tester.pumpWidget(
      _wrap(
        TelegramBannedMemberTile(
          member: const TelegramBannedMember(
            id: 'banned_1',
            name: 'SpamUser',
            reasonLabel: 'Scam links',
            untilLabel: 'Muted until Mar 12',
            avatarFallback: 'SU',
          ),
          onUnban: () {
            unbanned = true;
          },
        ),
      ),
    );

    expect(find.text('SpamUser'), findsOneWidget);
    expect(find.text('Scam links'), findsOneWidget);
    await tester.tap(find.text('Unban'));
    await tester.pump();
    expect(unbanned, isTrue);
  });
}
