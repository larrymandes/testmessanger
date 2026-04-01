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
  const successExecution = TelegramSearchExecution(
    id: 'execution_success',
    query: 'design tokens',
    status: 'success',
    scopeLabel: 'Chats',
    startedAtLabel: 'Just now',
    durationMs: 28,
    resultCount: 2,
  );

  const failedExecution = TelegramSearchExecution(
    id: 'execution_failed',
    query: 'timeout report',
    status: 'failed',
    scopeLabel: 'Moderation',
    startedAtLabel: '2m ago',
    durationMs: 90,
    resultCount: 0,
    errorMessage: 'Gateway timeout while querying the moderation index.',
  );

  testWidgets('TelegramSearchExecutionTile handles tap and retry', (
    tester,
  ) async {
    TelegramSearchExecution? selected;
    TelegramSearchExecution? retried;

    await tester.pumpWidget(
      _wrap(
        TelegramSearchExecutionTile(
          execution: failedExecution,
          onTap: (value) {
            selected = value;
          },
          onRetry: (value) {
            retried = value;
          },
        ),
      ),
    );

    expect(find.text('timeout report'), findsOneWidget);
    expect(find.textContaining('Failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('timeout report'));
    await tester.pump();
    expect(selected?.id, failedExecution.id);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried?.id, failedExecution.id);
  });

  testWidgets(
    'TelegramSearchExecutionStatusCard renders and triggers actions',
    (tester) async {
      var openedHistory = false;
      var reranLatest = false;

      await tester.pumpWidget(
        _wrap(
          TelegramSearchExecutionStatusCard(
            totalCount: 3,
            successCount: 2,
            failedCount: 1,
            averageDurationMs: 54,
            latestExecution: successExecution,
            onOpenHistory: () {
              openedHistory = true;
            },
            onRerunLatest: () {
              reranLatest = true;
            },
          ),
        ),
      );

      expect(find.text('Execution Status'), findsOneWidget);
      expect(find.text('Latest query: design tokens'), findsOneWidget);
      expect(find.text('Status: Success'), findsOneWidget);
      expect(find.text('Runs: 3'), findsOneWidget);
      expect(find.text('Success: 2'), findsOneWidget);
      expect(find.text('Failed: 1'), findsOneWidget);
      expect(find.text('Avg: 54ms'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pump();
      expect(openedHistory, isTrue);

      await tester.tap(find.text('Re-run Last'));
      await tester.pump();
      expect(reranLatest, isTrue);
    },
  );

  testWidgets('TelegramSearchExecutionsSheet selects and retries execution', (
    tester,
  ) async {
    TelegramSearchExecution? selected;
    TelegramSearchExecution? retried;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  TelegramSearchExecutionsSheet.show(
                    context,
                    executions: const [successExecution, failedExecution],
                    onSelected: (value) {
                      selected = value;
                    },
                    onRetry: (value) {
                      retried = value;
                    },
                    onClearAll: () {
                      cleared = true;
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
    expect(find.text('Search Executions'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried?.id, failedExecution.id);

    await tester.tap(find.text('design tokens'));
    await tester.pumpAndSettle();
    expect(selected?.id, successExecution.id);
    expect(find.text('Search Executions'), findsNothing);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear All'));
    await tester.pump();
    expect(cleared, isTrue);
    expect(find.text('No executions yet.'), findsOneWidget);
  });
}
