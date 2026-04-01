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
  testWidgets('TelegramSettingsTwoStepCard renders and handles actions', (
    tester,
  ) async {
    String? selectedId;
    var manageTapped = false;

    const actions = [
      TelegramSettingsSecurityAction(
        id: 'password',
        title: 'Change Password',
        subtitle: 'Updated 3 months ago',
        icon: CupertinoIcons.lock_fill,
      ),
      TelegramSettingsSecurityAction(
        id: 'recovery',
        title: 'Recovery Email',
        subtitle: 'alex@telegram.dev',
        icon: CupertinoIcons.mail,
      ),
      TelegramSettingsSecurityAction(
        id: 'disable',
        title: 'Disable Two-Step Verification',
        subtitle: 'Requires confirmation',
        icon: CupertinoIcons.exclamationmark_octagon_fill,
        destructive: true,
        enabled: false,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        TelegramSettingsTwoStepCard(
          enabled: true,
          description: 'Secure your account with an extra password.',
          actions: actions,
          onManageTap: () {
            manageTapped = true;
          },
          onActionSelected: (action) {
            selectedId = action.id;
          },
        ),
      ),
    );

    expect(find.text('Two-Step Verification'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);
    expect(
      find.text('Secure your account with an extra password.'),
      findsOneWidget,
    );
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Recovery Email'), findsOneWidget);
    expect(find.text('Disable Two-Step Verification'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);

    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    expect(manageTapped, isTrue);

    await tester.tap(find.text('Recovery Email'));
    await tester.pumpAndSettle();
    expect(selectedId, 'recovery');

    selectedId = null;
    await tester.tap(find.text('Disable Two-Step Verification'));
    await tester.pumpAndSettle();
    expect(selectedId, isNull);
  });

  testWidgets(
    'TelegramSettingsTwoStepCard renders empty state when no actions',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const TelegramSettingsTwoStepCard(
            enabled: false,
            actions: [],
            emptyLabel: 'No actions',
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('No actions'), findsOneWidget);
    },
  );
}
