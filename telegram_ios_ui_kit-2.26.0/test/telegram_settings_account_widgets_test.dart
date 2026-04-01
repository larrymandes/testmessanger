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
  testWidgets('TelegramSettingsAccountCard renders content and handles tap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsAccountCard(
          name: 'Alex Morgan',
          subtitle: '@alex_morgan',
          detail: '+1 555 123 4567',
          badgeLabel: 'Premium',
          avatarFallback: 'AM',
          onTap: () {
            tapped = true;
          },
        ),
      ),
    );

    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('@alex_morgan'), findsOneWidget);
    expect(find.text('+1 555 123 4567'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);

    await tester.tap(find.byType(TelegramSettingsAccountCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets(
    'TelegramSettingsQuickActionsBar handles selection and disabled',
    (tester) async {
      String? selectedId;
      const actions = [
        TelegramSettingsQuickAction(
          id: 'qr',
          label: 'QR Code',
          icon: CupertinoIcons.qrcode,
        ),
        TelegramSettingsQuickAction(
          id: 'saved',
          label: 'Saved',
          icon: CupertinoIcons.bookmark_fill,
          badgeLabel: '2',
        ),
        TelegramSettingsQuickAction(
          id: 'logout',
          label: 'Logout',
          icon: CupertinoIcons.square_arrow_right,
          destructive: true,
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          TelegramSettingsQuickActionsBar(
            actions: actions,
            onSelected: (action) {
              selectedId = action.id;
            },
          ),
        ),
      );

      expect(find.text('QR Code'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(selectedId, 'saved');

      selectedId = null;
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(selectedId, isNull);
    },
  );
}
