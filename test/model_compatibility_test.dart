import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_native_auth/telegram_native_auth.dart';

class OtherLoginResult extends TelegramLoginResult {
  const OtherLoginResult({required super.idToken});
}

void main() {
  test('configuration equality includes the redirect and fallback scheme', () {
    const first = TelegramLoginConfiguration(
      clientId: 'bot',
      redirectUri: 'https://ios.example',
      scopes: ['profile'],
      fallbackScheme: 'example',
    );
    final same = TelegramLoginConfiguration.fromMap(first.toMap());
    const different = TelegramLoginConfiguration(
      clientId: 'bot',
      redirectUri: 'https://android.example',
      scopes: ['profile'],
      fallbackScheme: 'example',
    );
    const differentFallback = TelegramLoginConfiguration(
      clientId: 'bot',
      redirectUri: 'https://ios.example',
      scopes: ['profile'],
      fallbackScheme: 'another',
    );
    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(first, isNot(different));
    expect(first, isNot(differentFallback));
  });

  test('result equality and string representation remain compatible', () {
    const result = TelegramLoginResult(idToken: 'test-token');
    final same = TelegramLoginResult.fromMap(result.toMap());
    expect(result, same);
    expect(result.hashCode, same.hashCode);
    expect(result.toString(), 'TelegramLoginResult(idToken: test-token)');
  });

  test(
    'a result subtype remains distinct despite sharing token properties',
    () {
      const result = TelegramLoginResult(idToken: 'test-token');
      const other = OtherLoginResult(idToken: 'test-token');
      expect(result == other, isFalse);
      expect(other == result, isFalse);
    },
  );

  test('error equality preserves the code, message, and HTTP status', () {
    final first = TelegramLoginError.serverError(503);
    final same = TelegramLoginError.serverError(503);
    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(first, isNot(TelegramLoginError.serverError(500)));
    expect(first, isNot(TelegramLoginError.networkError()));
    expect(
      first.toString(),
      'TelegramLoginError(TelegramLoginErrorCode.serverError: The server returned a non-200 HTTP status code)',
    );
  });
}
