import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_native_auth/telegram_native_auth.dart';
import 'package:telegram_native_auth/telegram_login_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('telegram_login');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late MethodChannelTelegramLogin platform;
  late List<MethodCall> calls;

  setUp(() {
    platform = MethodChannelTelegramLogin();
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'login':
          return {'idToken': 'test-token'};
        case 'handleUrl':
        case 'cancelLogin':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  const config = TelegramLoginConfiguration(
    clientId: 'test-client',
    redirectUri: 'https://ios-login.example',
    scopes: ['profile'],
    fallbackScheme: 'example',
  );

  test('configuration forwards the platform URL and fallback scheme unchanged',
      () async {
    await platform.configure(config);
    expect(platform.isConfigured, isTrue);
    expect(calls.single.method, 'configure');
    expect(calls.single.arguments, {
      'clientId': 'test-client',
      'redirectUri': 'https://ios-login.example',
      'scopes': ['profile'],
      'fallbackScheme': 'example',
    });
  });

  test('failed configuration leaves login unconfigured', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
          code: 'INVALID_ARGUMENTS', message: 'Invalid configuration');
    });
    await expectLater(
        platform.configure(config), throwsA(isA<TelegramLoginError>()));
    expect(platform.isConfigured, isFalse);
  });

  test('unconfigured login never opens the native flow', () async {
    await expectLater(
        platform.login(),
        throwsA(isA<TelegramLoginError>().having(
          (error) => error.code,
          'code',
          TelegramLoginErrorCode.notConfigured,
        )));
    expect(calls, isEmpty);
  });

  test('login delivers the native id token without alteration', () async {
    await platform.configure(config);
    final result = await platform.login();
    expect(result.idToken, 'test-token');
    expect(calls.last.method, 'login');
  });

  test('missing native login result is an authorization-code error', () async {
    await platform.configure(config);
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    await expectLater(
        platform.login(),
        throwsA(isA<TelegramLoginError>().having(
          (error) => error.code,
          'code',
          TelegramLoginErrorCode.noAuthorizationCode,
        )));
  });

  const errors = {
    'CANCELLED': TelegramLoginErrorCode.cancelled,
    'NETWORK_ERROR': TelegramLoginErrorCode.networkError,
    'REQUEST_FAILED': TelegramLoginErrorCode.requestFailed,
    'NO_AUTH_CODE': TelegramLoginErrorCode.noAuthorizationCode,
    'NOT_CONFIGURED': TelegramLoginErrorCode.notConfigured,
    'UNKNOWN_ERROR': TelegramLoginErrorCode.platformError,
  };
  for (final entry in errors.entries) {
    test('native ${entry.key} retains its Dart error classification', () async {
      await platform.configure(config);
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: entry.key, message: 'Test failure');
      });
      await expectLater(
          platform.login(),
          throwsA(isA<TelegramLoginError>().having(
            (error) => error.code,
            'code',
            entry.value,
          )));
    });
  }

  test('server error preserves the HTTP status', () async {
    await platform.configure(config);
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
          code: 'SERVER_ERROR', message: 'Server error: 503');
    });
    await expectLater(
        platform.login(),
        throwsA(isA<TelegramLoginError>()
            .having((error) => error.code, 'code',
                TelegramLoginErrorCode.serverError)
            .having((error) => error.statusCode, 'statusCode', 503)));
  });

  test('manual forwarding retains the entire callback URI', () async {
    final uri = Uri.parse('example://callback?code=test-code&state=test-state');
    expect(await platform.handleUrl(uri), isTrue);
    expect(calls.single.method, 'handleUrl');
    expect(calls.single.arguments, {'url': uri.toString()});
  });

  test('cancel forwards the request and preserves native cancellation status',
      () async {
    expect(await platform.cancelLogin(), isTrue);
    expect(calls.single.method, 'cancelLogin');
    messenger.setMockMethodCallHandler(channel, (_) async => false);
    expect(await platform.cancelLogin(), isFalse);
  });

  test('configuration round trip retains fallbackScheme', () {
    expect(TelegramLoginConfiguration.fromMap(config.toMap()), config);
  });
}
