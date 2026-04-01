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
  testWidgets(
    'TelegramSettingsNetworkPoliciesCard renders and handles toggle',
    (tester) async {
      TelegramSettingsNetworkPolicy? changedPolicy;
      var manageTapped = false;

      const policies = [
        TelegramSettingsNetworkPolicy(
          id: 'wifi',
          title: 'Auto-Download on Wi-Fi',
          enabled: true,
          subtitle: 'Download photos and videos',
          limitLabel: '20 MB',
          icon: CupertinoIcons.wifi,
        ),
        TelegramSettingsNetworkPolicy(
          id: 'mobile',
          title: 'Auto-Download on Mobile',
          enabled: false,
          subtitle: 'Photos only',
          limitLabel: '2 MB',
        ),
        TelegramSettingsNetworkPolicy(
          id: 'locked',
          title: 'Locked Policy',
          enabled: false,
          locked: true,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          TelegramSettingsNetworkPoliciesCard(
            policies: policies,
            onPolicyChanged: (policy) {
              changedPolicy = policy;
            },
            onManageTap: () {
              manageTapped = true;
            },
          ),
        ),
      );

      expect(find.text('Network Policies'), findsOneWidget);
      expect(find.text('Auto-Download on Wi-Fi'), findsOneWidget);
      expect(find.text('Auto-Download on Mobile'), findsOneWidget);
      expect(find.text('20 MB'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(manageTapped, isTrue);

      await tester.tap(find.byType(CupertinoSwitch).at(1));
      await tester.pumpAndSettle();
      expect(changedPolicy?.id, 'mobile');
      expect(changedPolicy?.enabled, isTrue);

      changedPolicy = null;
      await tester.tap(find.byType(CupertinoSwitch).at(2));
      await tester.pumpAndSettle();
      expect(changedPolicy, isNull);
    },
  );

  testWidgets('TelegramSettingsNetworkPoliciesCard renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSettingsNetworkPoliciesCard(
          policies: [],
          emptyLabel: 'No policies',
        ),
      ),
    );

    expect(find.text('No policies'), findsOneWidget);
  });
}
