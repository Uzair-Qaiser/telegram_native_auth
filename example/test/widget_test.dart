import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_native_auth_example/main.dart';

void main() {
  testWidgets(
      'missing configuration stays on the example without opening login',
      (tester) async {
    await tester.pumpWidget(const TelegramExample());
    await tester.tap(find.text('Sign in with Telegram'));
    await tester.pump();
    expect(find.textContaining('Dart defines'), findsOneWidget);
    expect(find.text('Sign in with Telegram'), findsOneWidget);
  });
}
