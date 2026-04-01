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
  testWidgets('TelegramUnreadSeparator renders label', (tester) async {
    await tester.pumpWidget(
      _wrap(const TelegramUnreadSeparator(label: 'Unread')),
    );
    expect(find.text('Unread'), findsOneWidget);
  });

  testWidgets('TelegramComposeFab renders extended label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Align(
          alignment: Alignment.bottomRight,
          child: TelegramComposeFab(label: 'New'),
        ),
      ),
    );
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('TelegramChatFoldersBar emits onFolderSelected', (tester) async {
    TelegramChatFolder? selected;
    const folders = [
      TelegramChatFolder(id: 'all', title: 'All'),
      TelegramChatFolder(id: 'work', title: 'Work'),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramChatFoldersBar(
          folders: folders,
          selectedFolderId: 'all',
          onFolderSelected: (folder) {
            selected = folder;
          },
        ),
      ),
    );

    await tester.tap(find.text('Work'));
    await tester.pump();

    expect(selected?.id, 'work');
  });
}
