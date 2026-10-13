## 3.0.2

First release of `shoplive_streamer`, built on Shoplive Android SDK 3.0.2 (`cloud.shoplive:shoplive-streamer-sdk:3.0.2`). Re-exports `shoplive_core`.

### BREAKING (from shoplive_player 1.x)
* The broadcast feature moved out of `shoplive_player` into this package. The channels are `shoplive_streamer` and `shoplive_streamer/events`.
* `start(campaignKey)` returns a `Future` and throws `PlatformException` (`INVALID_ARGUMENT`, `NO_HOST_SCREEN`, `SDK_ERROR`).

### Behavior
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
* iOS is not supported in this version.
