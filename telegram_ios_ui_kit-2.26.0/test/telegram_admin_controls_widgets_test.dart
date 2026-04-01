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
  testWidgets('TelegramAdminAuditFilterBar invokes filter selection', (
    tester,
  ) async {
    TelegramAdminAuditFilter? selected;
    const filters = [
      TelegramAdminAuditFilter(id: 'all', label: 'All', count: 4),
      TelegramAdminAuditFilter(id: 'critical', label: 'Critical', count: 1),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramAdminAuditFilterBar(
          filters: filters,
          selectedId: 'all',
          onSelected: (filter) {
            selected = filter;
          },
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    await tester.tap(find.text('Critical'));
    await tester.pump();
    expect(selected?.id, 'critical');
  });

  testWidgets('TelegramModerationDetailDrawer opens and approves', (
    tester,
  ) async {
    var approved = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramModerationDetailDrawer.show(
                    context,
                    request: const TelegramModerationRequest(
                      id: 'review_1',
                      title: 'Reported message',
                      subtitle: 'Potential phishing link',
                      timeLabel: '11:02',
                      highPriority: true,
                    ),
                    tags: const ['Urgent'],
                    evidenceCount: 2,
                    reporterLabel: 'Reported by community',
                    onApprove: () {
                      approved = true;
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
    expect(find.text('Moderation Detail'), findsOneWidget);
    expect(find.text('Reported by community'), findsOneWidget);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(approved, isTrue);
    expect(find.text('Moderation Detail'), findsNothing);
  });

  testWidgets('TelegramBulkBanActionBar invokes action callbacks', (
    tester,
  ) async {
    var unbanned = false;
    var extended = false;
    var deleted = false;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        TelegramBulkBanActionBar(
          selectedCount: 2,
          onClearSelection: () {
            cleared = true;
          },
          onUnban: () {
            unbanned = true;
          },
          onExtend: () {
            extended = true;
          },
          onDelete: () {
            deleted = true;
          },
        ),
      ),
    );

    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.text('2 selected'));
    await tester.pump();
    await tester.tap(find.text('Unban'));
    await tester.pump();
    await tester.tap(find.text('Extend'));
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(cleared, isTrue);
    expect(unbanned, isTrue);
    expect(extended, isTrue);
    expect(deleted, isTrue);
  });
}
