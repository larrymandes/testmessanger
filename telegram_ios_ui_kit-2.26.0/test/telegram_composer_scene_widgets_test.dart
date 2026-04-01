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
  testWidgets('TelegramReplyPreviewBar renders author and message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramReplyPreviewBar(
          author: 'Alice',
          message: 'Check this update',
        ),
      ),
    );

    expect(find.text('Replying to Alice'), findsOneWidget);
    expect(find.text('Check this update'), findsOneWidget);
  });

  testWidgets('TelegramAttachmentPanel renders action labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        TelegramAttachmentPanel(
          wrapInSafeArea: false,
          actions: const [
            TelegramAttachmentAction(
              label: 'Photo',
              icon: CupertinoIcons.photo,
            ),
            TelegramAttachmentAction(label: 'File', icon: CupertinoIcons.doc),
          ],
        ),
      ),
    );

    expect(find.text('Attach'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
  });

  testWidgets('TelegramInlineKeyboard notifies tapped button', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      _wrap(
        TelegramInlineKeyboard(
          rows: const [
            [
              TelegramKeyboardButton(label: 'A'),
              TelegramKeyboardButton(label: 'B'),
            ],
          ],
          onButtonTap: (button) {
            tapped = button.label;
          },
        ),
      ),
    );

    await tester.tap(find.text('B'));
    await tester.pump();

    expect(tapped, 'B');
  });

  testWidgets('TelegramFileMessageTile renders metadata', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramFileMessageTile(
          fileName: 'ui-kit.fig',
          fileSizeLabel: '2.4 MB',
          timeLabel: '14:05',
          extension: 'FIG',
          caption: 'Community file',
        ),
      ),
    );

    expect(find.text('ui-kit.fig'), findsOneWidget);
    expect(find.text('2.4 MB'), findsOneWidget);
    expect(find.text('14:05'), findsOneWidget);
    expect(find.text('Community file'), findsOneWidget);
  });

  testWidgets('TelegramPollCard renders question and options', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramPollCard(
          question: 'Release date?',
          options: [
            TelegramPollOption(id: '1', label: 'Today', votes: 3),
            TelegramPollOption(id: '2', label: 'Tomorrow', votes: 1),
          ],
        ),
      ),
    );

    expect(find.text('Release date?'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('4 votes'), findsOneWidget);
  });

  testWidgets('TelegramReferenceMessageCard renders sender and text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramReferenceMessageCard(
          sender: 'Alice',
          message: 'Please check this',
          type: TelegramReferenceMessageType.forwarded,
        ),
      ),
    );

    expect(find.text('Forwarded from Alice'), findsOneWidget);
    expect(find.text('Please check this'), findsOneWidget);
  });

  testWidgets('TelegramVoiceMessageTile renders duration and time', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramVoiceMessageTile(
          durationLabel: '0:46',
          timeLabel: '14:06',
          progress: 0.5,
        ),
      ),
    );

    expect(find.text('0:46'), findsOneWidget);
    expect(find.text('14:06'), findsOneWidget);
  });

  testWidgets('TelegramChatActionToolbar renders title and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TelegramChatActionToolbar(
          title: 'Selection Mode',
          actions: const [
            TelegramActionItem(label: 'Copy', icon: CupertinoIcons.doc_on_doc),
            TelegramActionItem(label: 'Delete', icon: CupertinoIcons.delete),
          ],
        ),
      ),
    );

    expect(find.text('Selection Mode'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('TelegramLinkPreviewCard renders title and domain', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramLinkPreviewCard(
          preview: TelegramLinkPreview(
            url: 'https://core.telegram.org',
            title: 'Telegram API',
            description: 'Bot APIs and mini apps',
            domain: 'core.telegram.org',
          ),
        ),
      ),
    );

    expect(find.text('Telegram API'), findsOneWidget);
    expect(find.text('core.telegram.org'), findsOneWidget);
  });

  testWidgets('TelegramLocationMessageTile renders metadata', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramLocationMessageTile(
          title: 'Downtown Office',
          subtitle: 'Live location',
          timeLabel: '15:24',
        ),
      ),
    );

    expect(find.text('Downtown Office'), findsOneWidget);
    expect(find.text('Live location'), findsOneWidget);
    expect(find.text('15:24'), findsOneWidget);
  });

  testWidgets('TelegramContactMessageTile renders contact details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramContactMessageTile(
          name: 'Bot Support',
          phoneLabel: '+1 555 123 0000',
          timeLabel: '14:08',
          avatarFallback: 'BS',
        ),
      ),
    );

    expect(find.text('Bot Support'), findsOneWidget);
    expect(find.text('+1 555 123 0000'), findsOneWidget);
    expect(find.text('14:08'), findsOneWidget);
  });
}
