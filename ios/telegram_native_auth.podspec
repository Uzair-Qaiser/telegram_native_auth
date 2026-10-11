Pod::Spec.new do |s|
  s.name             = 'telegram_native_auth'
  s.version          = '1.0.0'
  s.summary          = 'Native Telegram login for Flutter'
  s.description      = 'Telegram login for iOS with universal-link callbacks and browser authentication.'
  s.homepage         = 'https://pub.dev/packages/telegram_native_auth'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Uzair Qaiser'
  s.source           = { :path => '.' }
  s.source_files     = 'telegram_native_auth/Sources/telegram_native_auth/**/*.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.0'
  s.framework        = 'AuthenticationServices'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
  s.resource_bundles = { 'telegram_native_auth_privacy' => ['telegram_native_auth/Sources/telegram_native_auth/PrivacyInfo.xcprivacy'] }
end
