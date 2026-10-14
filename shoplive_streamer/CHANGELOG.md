## 3.0.2

First release of `shoplive_streamer`, built on Shoplive Android SDK 3.0.2 (`cloud.shoplive:shoplive-streamer-sdk:3.0.2`). Re-exports `shoplive_core`.

### Usage note
* Set the broadcaster token with `Shoplive.setStreamToken(token)` before `start`. Without it the server returns no ingest address and the broadcast screen shows a "failed to start" retry dialog (logcat: `stream/status failed: Token does not exist`).

### BREAKING (from shoplive_player 1.x)
* The broadcast feature moved out of `shoplive_player` into this package. The channels are `shoplive_streamer` and `shoplive_streamer/events`.
* `start(campaignKey)` returns a `Future` and throws `PlatformException` (`INVALID_ARGUMENT`, `NO_HOST_SCREEN`, `SDK_ERROR`).

### Behavior
* `ShopliveStreamerStateChanged.isRehearsal` is now `bool?`: `null` when the platform does not provide it (iOS).
* Each `start` creates a new session, and events from the previous session stop being delivered.
* `getState` returns the current session state. A session in `ended` is kept so that an in-place restart by the SDK keeps delivering events. After release, the last state is kept; with no session ever started it returns `idle`.

### Known limitations
* Calling `start` while a broadcast is running has not been verified against the SDK.
* Appearance options and the headless streamer API are not exposed.
* A kept session holds a reference to the Activity it was started from until it is released (one session at most).

### Requirements
* Flutter 3.22 / Dart 3.4 or later.
* Android: AGP 8.7, Gradle 8.9, JDK 17, minSdk 23, compileSdk 36.
* Android SDK artifacts come from `https://sdk.shoplive.cloud/maven-repo`. The `cloud.shoplive` group is restricted to that repository with `exclusiveContent`, because Maven Central hosts a conflicting `shoplive-media3:1.10.1.2`. See README.
* iOS 15.0 (Shoplive iOS SDK 3.0.2, XCFrameworks downloaded and sha256-verified during `pod install` - see README "iOS setup"). Set `platform :ios, '15.0'` in your Podfile. When you run `pod install` manually, use a UTF-8 locale.
* Upgrading from 1.x: run `flutter clean` once; stale 1.x iOS build products otherwise fail with "'ShoplivePlayerPlugin' has different definitions in different modules".
