/// Telegram login configuration, authentication, and callback forwarding.
library;

import 'models/model.dart';
import 'telegram_login_platform_interface.dart';

export 'models/model.dart';

/// Provides native Telegram sign-in on Android and iOS.
class TelegramLogin {
  TelegramLoginPlatform get _platform => TelegramLoginPlatform.instance;

  /// Configures the SDK with the bot client ID and platform redirect URI.
  ///
  /// Call this before [login].
  Future<void> configure(TelegramLoginConfiguration config) {
    return _platform.configure(config);
  }

  /// Whether the SDK has been successfully configured.
  bool get isConfigured => _platform.isConfigured;

  /// Opens Telegram or browser authentication and returns an ID token.
  ///
  /// Throws [TelegramLoginError] on failure. Start only one login at a time.
  /// Verify the returned token on your backend before creating a session.
  Future<TelegramLoginResult> login() {
    return _platform.login();
  }

  /// Forwards a callback intercepted by the app to the native login SDK.
  ///
  /// Returns whether the native handler accepted the request.
  Future<bool> handleUrl(Uri url) {
    return _platform.handleUrl(url);
  }

  /// Cancels a pending login and discards any later callback result.
  ///
  /// Returns `true` if a pending login was cancelled, or `false` otherwise.
  Future<bool> cancelLogin() {
    return _platform.cancelLogin();
  }
}
