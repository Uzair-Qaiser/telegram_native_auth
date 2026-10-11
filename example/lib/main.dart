import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telegram_native_auth/telegram_native_auth.dart';

void main() => runApp(const TelegramExample());

class TelegramExample extends StatelessWidget {
  const TelegramExample({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Telegram native auth',
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: const LoginExample(),
      );
}

class LoginExample extends StatefulWidget {
  const LoginExample({super.key});

  @override
  State<LoginExample> createState() => _LoginExampleState();
}

class _LoginExampleState extends State<LoginExample> {
  final _telegram = TelegramLogin();
  bool _busy = false;
  String _status = 'Set your public BotFather configuration before signing in.';

  String get _redirectUri => defaultTargetPlatform == TargetPlatform.iOS
      ? const String.fromEnvironment('TELEGRAM_IOS_REDIRECT_URI')
      : const String.fromEnvironment('TELEGRAM_ANDROID_REDIRECT_URI');

  Future<void> _signIn() async {
    if (_busy) return;
    const clientId = String.fromEnvironment('TELEGRAM_CLIENT_ID');
    if (kIsWeb || clientId.isEmpty || _redirectUri.isEmpty) {
      setState(() => _status =
          'Run on Android or iOS with the Dart defines listed in example/README.md.');
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Waiting for Telegram approval…';
    });
    try {
      await _telegram.configure(TelegramLoginConfiguration(
        clientId: clientId,
        redirectUri: _redirectUri,
        scopes: const ['profile'],
        fallbackScheme: const String.fromEnvironment(
          'TELEGRAM_FALLBACK_SCHEME',
          defaultValue: 'telegram-native-auth-example',
        ),
      ));
      final result = await _telegram.login();
      if (mounted) {
        setState(() => _status = result.idToken.isNotEmpty
            ? 'Token received. Verify it on your backend to complete sign-in.'
            : 'No token received.');
      }
    } on TelegramLoginError catch (error) {
      if (mounted) {
        setState(() => _status = error.code == TelegramLoginErrorCode.cancelled
            ? 'Login cancelled.'
            : 'Login failed: ${error.code.name}.');
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => _status = 'Login failed. Check your native configuration.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    try {
      await _telegram.cancelLogin();
    } on TelegramLoginError catch (_) {
      if (mounted) setState(() => _status = 'Unable to cancel login.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Telegram native auth')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_status, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _signIn,
                  child: Text(_busy ? 'Signing in…' : 'Sign in with Telegram'),
                ),
                if (_busy)
                  TextButton(onPressed: _cancel, child: const Text('Cancel')),
              ],
            ),
          ),
        ),
      );
}
