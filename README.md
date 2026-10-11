# telegram_native_auth

Native Telegram sign-in for Flutter on Android and iOS. A maintained fork of
[`telegram_login` 1.2.1](https://pub.dev/packages/telegram_login/versions/1.2.1)
by khode-io, preserving its Dart API and Android behavior.

## What changes

- Corrects the iOS universal-link callback signature used by Flutter.
- Supports Swift Package Manager and CocoaPods, with a shared Swift source tree.
- Keeps `TelegramLogin`, configuration, results, cancellation, and error types compatible.
- Uses the current Kotlin compiler DSL without applying the legacy Kotlin Android plugin.
- Includes no app credentials or debug token logging.

Android API 24+ and iOS 15+ are supported by the native code. This package
requires Flutter 3.44+ and Dart 3.12+. SwiftPM uses Xcode 15+ / Swift 5.9+;
CocoaPods remains supported. The example requires Flutter 3.47+ and enables
built-in Kotlin on Android Gradle Plugin 9.1.0.

## Install / migrate

```yaml
dependencies:
  telegram_native_auth: ^1.0.0
```

For development before the first pub.dev release, use a local path or the
[GitHub repository](https://github.com/Uzair-Qaiser/telegram_native_auth).
Remove `telegram_login` and any override for it. Do not install both packages:
the native plugin class and method channel are deliberately retained.

Change the import; existing class names and method calls remain valid:

```dart
import 'package:telegram_native_auth/telegram_native_auth.dart';
```

`package:telegram_native_auth/telegram_login.dart` is also available.

## BotFather configuration

Register each native platform separately in BotFather's Login settings:

- iOS: Apple Team ID and bundle identifier.
- Android: application ID and signing certificate SHA-256 fingerprint.

Use the **App URL shown for that platform**. The iOS and Android App URLs can
be different, and their numeric domain IDs are not necessarily your bot client ID.
Only the public bot client ID belongs in the mobile app; no client secret is needed.

## iOS setup

For an HTTPS App URL, add both Associated Domains to the app target:

```text
applinks:<IOS_APP_URL_HOST>
webcredentials:<IOS_APP_URL_HOST>
```

Ensure the entitlements apply to every build configuration you use, including
Debug, Profile, and Release. Keep the registered bundle ID and Team ID consistent
with the installed application.

Add the Telegram query schemes to Info.plist:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tg</string>
  <string>telegram</string>
</array>
```

If you use a custom callback scheme, append its own dictionary to the existing
`CFBundleURLTypes` array, preserving other providers' entries:

```xml
<dict>
  <key>CFBundleURLSchemes</key>
  <array><string>myapp</string></array>
</dict>
```

When Flutter's default deep-link routing intercepts authentication callbacks,
allow this plugin to handle native callbacks by adding:

```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

Coordinate this with any other app deep-link handling; `handleUrl` remains
available for explicit forwarding.

The browser flow uses HTTPS callbacks on iOS 17.4+. Below 17.4, it listens for
`fallbackScheme` (or the redirect URI's scheme when omitted). **Setting a
fallback scheme does not convert an HTTPS redirect into a custom-scheme
redirect.** Older-iOS browser login requires a registered redirect that actually
returns through that scheme. This fork preserves upstream behavior; it does not
claim to fix every older-iOS browser configuration.

## Android setup

Keep the BotFather application ID and certificate fingerprint matched to the
installed build. Add the App URL host to an intent filter in the main activity:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="YOUR_ANDROID_APP_URL_HOST" />
</intent-filter>
```

If Flutter's own deep-link routing consumes callbacks, set the activity metadata
`flutter_deeplinking_enabled` to `false`, or explicitly forward the received URL.
The Android SDK dependency remains `io.khode:telegram-login-sdk:1.0.0`.

## Usage

```dart
final telegram = TelegramLogin();

await telegram.configure(
  const TelegramLoginConfiguration(
    clientId: 'YOUR_PUBLIC_BOT_CLIENT_ID',
    redirectUri: 'YOUR_PLATFORM_SPECIFIC_APP_URL',
    scopes: ['profile'],
    fallbackScheme: 'myapp', // Optional custom scheme on iOS.
  ),
);

try {
  final result = await telegram.login();
  // Send result.idToken to your backend over HTTPS for verification.
} on TelegramLoginError catch (error) {
  if (error.code != TelegramLoginErrorCode.cancelled) {
    // Show an appropriate error; allow retry.
  }
}
```

Only start one login at a time. Disable the sign-in button while it is pending;
the upstream native SDK can overwrite a concurrent request's completion.

```dart
await telegram.cancelLogin(); // Cancels a pending login; late results are discarded.
await telegram.handleUrl(callbackUri); // Manual callback forwarding, if needed.
```

Verify the ID token's signature and claims on your backend before creating a
session. The plugin returns a token; it does not implement your app's backend,
Supabase edge function, or profile storage. Avoid logging tokens or authorization codes.

## Development

```sh
flutter pub get
flutter analyze
flutter test
cd example
flutter pub get
flutter build ios --debug --no-codesign
flutter build apk --debug
```

The example uses public configuration via Dart defines; see [example/README.md](example/README.md).
SwiftPM callback-registration tests are in
`ios/telegram_native_auth/Tests/TelegramNativeAuthTests`. Run them in an iOS
Xcode test destination with FlutterFramework available through Flutter tooling.

Run `dart pub publish --dry-run` before publishing. Validate
CocoaPods and SwiftPM builds and perform real-device login/cancellation tests
before advertising platform coverage.

## Attribution

Based on `telegram_login` 1.2.1 by khode-io. See [UPSTREAM.md](UPSTREAM.md) for the
precise changes. The original MIT copyright and license are retained in
[LICENSE](LICENSE). This is an independent fork and is not an official Telegram package.
