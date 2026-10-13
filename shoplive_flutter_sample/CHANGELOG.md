## 3.0.2

Rewrite on Shoplive Android SDK 3.0.2 (`cloud.shoplive:shoplive-player-sdk:3.0.2`).

### BREAKING
* Removed the whole 1.x Dart API: `ShopLivePlayer`, `ShopLiveCommon`, their data and event classes, and all `ShopLive*` names.
* Removed Shortform (`shoplive_shortform.dart`); it does not exist in SDK 3.x.
* Split into three packages: `shoplive_core` (initialize/user/conversion), `shoplive_player` (this package, re-exports core) and `shoplive_streamer` (broadcast).
* New channel contract. The method channel is `shoplive_player`, and events come on `shoplive_player/events` and `shoplive_player/requests` as typed maps. The 10 per-event channels of 1.x are gone.
* Every method now returns a `Future` and throws `PlatformException` (`INVALID_ARGUMENT`, `NO_HOST_SCREEN`, `NOT_RUNNING`, `SDK_ERROR`). Previously `void` methods swallowed errors.
* Class names changed from `ShopLive*` to `Shoplive*`. See the migration table in README.
* 1.8.x APIs without an SDK 3.0.2 equivalent are removed: `closeButtonConfig` (`ShopLiveCloseButtonConfig`), `hidePreview`, the `previewClose` stream and its close reasons, and the preview options `pipRadius`, `enableSwipeOut`, `pipMaxSize`. `setResizeMode` keeps only `fill` / `fit` (no `auto` / `centerCrop`). See the migration table in README.
* `getPluginVersion()` is kept as `ShoplivePlayer.instance.getPluginVersion()`; `getSdkVersion()` moved to `Shoplive.getSdkVersion()`. `sendDownloadCouponResult` / `sendCustomActionResult` are replaced by `respond` on the request objects.

### Behavior changes
* Custom web actions are no longer answered with success automatically. Without a listener, or without a `respond` before the timeout (default 10 s, configurable 1–120 s), the SDK receives `success: false, status: keep, alertType: toast`.
* Coupon requests now have a response protocol: `couponRequests` + `respond`. In 1.x, coupon requests were never answered.
* Share handling changed: the 1.x Android bridge overrode `handleShare` and ran the SDK default share after a 100 ms delay. SDK 3.x has no share handler, so configure sharing with `configuration.navigation.shareScheme`.
* Removed the hard-coded transparent status bar, tablet aspect ratio and audio-focus mute. Use `ShoplivePlayerConfiguration` (`android.isStatusBarVisible`, `sound.*`); there is no equivalent for the tablet aspect ratio or the transparent status bar.
* The 1.x `log` event has no confirmed 3.x replacement. `webCommandReceived` / `analytics` may cover some uses (unverified).
* Event payload numbers are no longer converted from integral doubles to integers. Integers arrive as `int`, other numbers as `double`.
* `showPreview` is replaced by `start` with `presentationStyle: pip` and `configuration.type: preview` (see README).
* Configuration given to `start` / `setConfiguration` is merged on top of the current settings, and `getConfiguration` is new.
* `close` always succeeds. Session commands (`play`, `stop`, `reload`, `send`, `setMuted`, `enter/exitPictureInPicture`) throw `NOT_RUNNING` when no session is running.

### In-app PIP on Flutter hosts
* Fixed: playback stopped (HLS) or the WebRTC session closed, sometimes with a native crash, right after switching from fullscreen to in-app PIP when the host is the default `FlutterActivity`. SDK 3.0.2 moves the player view into the host screen and re-binds it to the host lifecycle only when the host's decor view has a `ViewTreeLifecycleOwner`. `FlutterActivity` does not register one, so the player stayed bound to the closing fullscreen Activity. The plugin now registers the host Activity as the `ViewTreeLifecycleOwner` when none is set. No change is needed in your `MainActivity`; hosts that already register one (for example `FlutterFragmentActivity`) are left untouched.
* Fixed: `ClassCastException` in the ConstraintLayout solver during the PIP transition. The SDK pulls `constraintlayout:2.0.1` through `material:1.9.0`; `shoplive_core` now declares `constraintlayout:2.2.1`, so Gradle resolves the fixed version (unless your app pins an older one).
* To let in-app PIP continue as system PIP when the app goes to the background, declare `android:supportsPictureInPicture="true"` on your host Activity. Otherwise the player reports `PIP_ACTIVITY_NOT_DECLARED`.

### Known limitations
* Nullable settings (`navigation.shareScheme`, `android.isVolumeKeyEnabled`) cannot be reset to `null` from Dart.
* After the Flutter engine is detached and attached again, a session left open by the previous engine cannot be controlled. Its requests are answered with the fallback result.
* Only synchronous request-listener exceptions trigger an immediate fallback. Errors after an `await` are not caught.
* If the SDK silently rejects `start` (launch Activity gone or not a `LifecycleOwner`), it only logs; `start` still completes.

### Requirements
* Flutter 3.22 / Dart 3.4 or later.
* Android: AGP 8.7, Gradle 8.9, JDK 17, minSdk 23, compileSdk 36.
* Android SDK artifacts come from `https://sdk.shoplive.cloud/maven-repo`. The `cloud.shoplive` group is restricted to that repository with `exclusiveContent`, because Maven Central hosts a conflicting `shoplive-media3:1.10.1.2`. See README.
* iOS is not supported in this version.

## 1.9.0
* Update Shoplive iOS/Android SDK to 1.9.0. Android artifacts resolve from `https://sdk.shoplive.cloud/maven-repo`, with ExoPlayer `2.19.1.20`. Minimum iOS is 15.0
* Remove the shortform API and the Shoplive shortform SDK dependency

## 1.8.14
* Add `ShopLivePlayer.setResizeMode()` — passes through the native `setResizeMode` API for the live player (`ShopLiveResizeMode.auto` / `centerCrop` / `fit`)
* Update Shoplive iOS/Android SDK to 1.8.13

## 1.8.13
* Update Shoplive iOS/Android SDK to 1.8.11

## 1.8.12
* Bump version to v1.8.12

## 1.8.11
* Bump version to v1.8.11

## 1.8.10
* Bump version to v1.8.10

## 1.8.9
* Bump version to v1.8.9

## 1.8.8
* Bump version to v1.8.8

## 1.8.4
* Bump version to v1.8.4

## 1.8.2
* Bump version to v1.8.2

## 1.8.0
* Bump version to v1.8.0

## 1.7.9
* Bump version to v1.7.9

## 1.7.5
* Bump version to v1.7.5

## 1.7.4
* Bump version to v1.7.4

## 1.7.3
* Bump version to v1.7.3

## 1.7.2
* Bump version to v1.7.2

## 1.7.1
* Bump version to v1.7.1

## 1.7.0+2
* Bump version to v1.7.0+2

## 1.7.0+1
* Revert a streamer feature
* Bump version to v1.7.0+1

## 1.7.0
* Add a streamer feature
* Bump version to v1.7.0

## 1.6.6
* Bump version to v1.6.6

## 1.6.5+1
* Bump version to v1.6.5+1

## 1.6.5
* Bump version to v1.6.5

## 1.6.2
* Bump version to v1.6.2

## 1.5.15+1
* Bump version to v1.5.15+1

## 1.5.15
* Bump version to v1.5.15

## 1.5.14+3
* Add a startPictureInPicture
* Add a stopPictureInPicture

## 1.5.14+2
* Add a showPreview

## 1.5.14+1
* Remove a jfrog

## 1.5.14
* Bump version to v1.5.14

## 1.5.13
* Bump version to v1.5.13

## 1.5.12
* Bump version to v1.5.12

## 1.5.11+3
* Bump version to v1.5.11+3

## 1.5.11+2
* Bump version to v1.5.11+2

## 1.5.11+1
* Bump version to v1.5.11+1

## 1.5.11
* Bump version to v1.5.11

## 1.5.7
* Bump version to v1.5.7
* Add a iOS Privacy manifest

## 1.5.6+1
* Bump version to v1.5.6+1

## 1.5.6
* Bump version to v1.5.6

## 1.5.4
* Bump version to v1.5.4

## 1.5.3
* Bump version to v1.5.3

## 1.5.2+1
* Add a shortform
* Migration player api

## 1.5.2
* Bump version to v1.5.2

## 1.5.1
* Bump version to v1.5.1

## 1.5.0+1
* Add a keep annotation

## 1.5.0
* Bump version to v1.5.0

## 1.4.9
* Bump version to v1.4.9

## 1.4.8
* Bump version to v1.4.8

## 1.4.7
* Bump version to v1.4.7

## 1.4.6
* Bump version to v1.4.6

## 1.4.5
* Bump version to v1.4.5

## 1.4.4
* Bump version to v1.4.4

## 1.4.3
* Bump version to v1.4.3

## 1.4.2
* Bump version to v1.4.2
* Fix to crash ios 13.x 

## 1.4.1
* Bump version to v1.4.1

## 1.4.0
* Bump version to v1.4.0

## 1.3.3
* Add to feature setMixWithOthers, feature useCloseButton
* Fix a player status

## 1.3.1+4
* Fix a android parsing issue

## 1.3.1+3
* Fix a android parsing issue

## 1.3.1+2
* Fix a parsing issue

## 1.3.1+1
* Fix a parsing issue

## 1.3.1
* Updated so that even if the PIP conversion interface (startPictureInPicture, stopPictureInPicture) is called simultaneously several times, it only works once.
* When the share button is clicked and there is no set URL, an error code will be delivered to the onError Handler.
* Fixed an issue that could affect the lifecycle of customer's app when switching to PIP after launching Shoplive Player with a deep link.
* Applied an animation to make the chat input window appear more natural.
* Fixed the issue where the chat input window covered the chat message.
* Animation images are now available for broadcasting. (gif, apng, webp, etc.)

## 1.3.0+6
* Fix ios user parameter.

## 1.3.0+5
* Fix a user parameter.
* Change Future<void> to void function.

## 1.3.0+4
* Change PlayerStatus to enum status. 

## 1.3.0+3
* Change CREATE to CREATED. Change CREATE to CREATED.

## 1.3.0+2
* Fix a minor update.

## 1.3.0+1
* Fix a ios player status listener.

## 1.3.0
* Initial release.
