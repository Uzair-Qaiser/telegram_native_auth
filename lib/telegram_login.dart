import 'models/model.dart';
import 'telegram_login_platform_interface.dart';

export 'models/model.dart';

class TelegramLogin {
  TelegramLoginPlatform get _platform => TelegramLoginPlatform.instance;

  Future<void> configure(TelegramLoginConfiguration config) {
    return _platform.configure(config);
  }

  bool get isConfigured => _platform.isConfigured;

  Future<TelegramLoginResult> login() {
    return _platform.login();
  }

  Future<bool> handleUrl(Uri url) {
    return _platform.handleUrl(url);
  }

  Future<bool> cancelLogin() {
    return _platform.cancelLogin();
  }
}
