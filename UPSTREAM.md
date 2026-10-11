# Upstream and compatibility

Based on `telegram_login` version 1.2.1 by khode-io:
https://github.com/khode-io/telegram-login-flutter
https://pub.dev/packages/telegram_login/versions/1.2.1

The upstream MIT license and copyright are preserved in LICENSE.

The Dart and Android implementations preserve upstream behavior; explanatory code comments have been removed. The original Dart class names, method channel (`telegram_login`), Android namespace, SDK dependency, and login behavior are retained. Only the package imports change. Do not install this fork alongside `telegram_login`; both register the same native plugin and channel.

The iOS implementation differs in one functional line: `restorationHandler` on `application(_:continue:restorationHandler:)` is `@escaping ([Any]) -> Void`, matching Flutter's plugin lifecycle protocol. The previous signature did not expose the handler as the Objective-C callback Flutter dispatches.

Swift sources and the privacy manifest now live in the SwiftPM target directory. CocoaPods compiles those same files. No diagnostics or app-specific identifiers are included.

Before release, run package and example checks and verify interactive login and cancellation on real Android and iOS devices. Lower-iOS browser callbacks require an actual registered custom-scheme redirect; fallbackScheme alone does not rewrite an HTTPS redirect URI.

Android build configuration no longer applies `kotlin-android` or declares its own Kotlin Gradle Plugin classpath. JVM 17 is configured through `kotlin.compilerOptions`, while the Telegram SDK dependency and Kotlin login implementation are preserved. The package requires Flutter 3.44 / Dart 3.12 or newer. The example requires Flutter 3.47 and enables built-in Kotlin on AGP 9.1.0; legacy Kotlin mode is also build-checked on that host tooling.
