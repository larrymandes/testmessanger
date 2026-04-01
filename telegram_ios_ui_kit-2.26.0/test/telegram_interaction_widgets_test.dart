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
  testWidgets('TelegramNoticeBanner renders title and message', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramNoticeBanner(
          title: 'Updated',
          message: 'Design tokens refreshed',
          actionLabel: 'Apply',
        ),
      ),
    );

    expect(find.text('Updated'), findsOneWidget);
    expect(find.text('Design tokens refreshed'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('TelegramLargeTitleHeader renders content', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramLargeTitleHeader(
          title: 'UI Kit',
          subtitle: 'Components',
          showBottomDivider: false,
        ),
      ),
    );

    expect(find.text('UI Kit'), findsOneWidget);
    expect(find.text('Components'), findsOneWidget);
  });

  testWidgets('TelegramSwipeActions reveals end actions on drag', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          height: 72,
          child: TelegramSwipeActions(
            endActions: const [
              TelegramSwipeAction(
                label: 'Delete',
                icon: CupertinoIcons.delete,
                destructive: true,
              ),
            ],
            child: const ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: Center(child: Text('Chat Tile')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(TelegramSwipeActions), const Offset(-180, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('TelegramContextMenuPreview renders labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramContextMenuPreview(
          title: 'Long press item',
          subtitle: 'Preview text',
        ),
      ),
    );

    expect(find.text('Long press item'), findsOneWidget);
    expect(find.text('Preview text'), findsOneWidget);
  });
}
