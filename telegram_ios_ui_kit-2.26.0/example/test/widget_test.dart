import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_ios_ui_kit_example/main.dart';

void main() {
  testWidgets('Example app renders Telegram tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const TelegramExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('UI Kit'), findsOneWidget);
  });
}
