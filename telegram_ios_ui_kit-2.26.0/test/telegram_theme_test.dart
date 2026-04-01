import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';

void main() {
  test('light and dark token sets are different', () {
    const light = TelegramColors.light;
    const dark = TelegramColors.dark;

    expect(light.bgColor, isNot(dark.bgColor));
    expect(light.textColor, isNot(dark.textColor));
    expect(light.linkColor, isNot(dark.linkColor));
  });

  testWidgets('TelegramTheme.of falls back from Material brightness', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (context) {
            final data = TelegramTheme.of(context);
            expect(data.colors.bgColor, TelegramColors.light.bgColor);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
