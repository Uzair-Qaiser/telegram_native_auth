## 1.0.1

* Allow Equatable 2.x and 3.x while preserving the existing model API.
* Add compatibility tests for model equality, hashing, and string representations.

## 1.0.0

* Forked `telegram_login` 1.2.1 with its Dart API and Android behavior preserved.
* Corrected the iOS universal-link delegate signature so Flutter can deliver callbacks.
* Added iOS Swift Package Manager support alongside CocoaPods, using the same Swift sources and privacy manifest.
* Added method-channel regression tests and native callback-registration tests.
* Migrated Android to the current Kotlin compiler DSL without applying legacy KGP.
* Requires Flutter 3.44 / Dart 3.12; the example uses Flutter 3.47+ with built-in Kotlin.
