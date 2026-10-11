import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/model.dart';
import 'telegram_login_method_channel.dart';

abstract class TelegramLoginPlatform extends PlatformInterface {
  TelegramLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TelegramLoginPlatform _instance = MethodChannelTelegramLogin();

  static TelegramLoginPlatform get instance => _instance;

  static set instance(TelegramLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> configure(TelegramLoginConfiguration config) {
    throw UnimplementedError('configure() has not been implemented.');
  }

  bool get isConfigured {
    throw UnimplementedError('isConfigured has not been implemented.');
  }

  Future<TelegramLoginResult> login() {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<bool> handleUrl(Uri url) {
    throw UnimplementedError('handleUrl() has not been implemented.');
  }

  Future<bool> cancelLogin() {
    throw UnimplementedError('cancelLogin() has not been implemented.');
  }
}
