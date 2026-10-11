# Native login example

Register this example's bundle/application ID with your bot before testing login.
Use your own signing team; no developer team or credentials are embedded.

1. Run `flutter pub get` in this folder.
2. iOS: configure your signing team and Associated Domains for the iOS App URL,
   as documented in the package README. The example already declares Telegram
   query schemes and `telegram-native-auth-example` as a custom callback scheme.
3. Android: replace `YOUR_ANDROID_APP_URL_HOST` in AndroidManifest.xml with the
   host from your Android App URL, and register the signing certificate fingerprint.
4. Supply public configuration when running:

```sh
flutter run \
  --dart-define=TELEGRAM_CLIENT_ID=YOUR_PUBLIC_BOT_CLIENT_ID \
  --dart-define=TELEGRAM_IOS_REDIRECT_URI=YOUR_IOS_APP_URL \
  --dart-define=TELEGRAM_ANDROID_REDIRECT_URI=YOUR_ANDROID_APP_URL
```

The platform App URLs are separate values. Older-iOS browser flows require an
actual registered custom-scheme redirect, not only an HTTPS URL plus a fallback
listener. Override TELEGRAM_FALLBACK_SCHEME and update the plist if using another
custom scheme.

Test login success, cancellation, browser fallback, and returning from the
installed Telegram app on real devices. The example displays whether a token
arrived, without exposing it, and does not create an authenticated backend session.
