# shoplive_player

Fullscreen live/VOD player for Flutter, built on Shoplive Android SDK **3.0.2** (`cloud.shoplive:shoplive-player-sdk`).

Shoplive for Flutter ships as three packages:

| Package | Provides | Android dependency |
|---|---|---|
| `shoplive_core` | `Shoplive.initialize`, user, conversion events | `cloud.shoplive:shoplive-core` |
| `shoplive_player` | `ShoplivePlayer` (re-exports `shoplive_core`) | `cloud.shoplive:shoplive-player-sdk` |
| `shoplive_streamer` | `ShopliveStreamer` broadcast (re-exports `shoplive_core`) | `cloud.shoplive:shoplive-streamer-sdk` |

Apps that only play videos add `shoplive_player`, and streamer binaries stay out of the APK.

## Requirements

| | Minimum |
|---|---|
| Flutter / Dart | 3.22 / 3.4 |
| Android Gradle Plugin / Gradle | 8.7 / 8.9 |
| JDK | 17 |
| Android minSdk / compileSdk | 23 / 36 |
| iOS | Not supported in 3.0.2. Android only; iOS support will follow. |

## Installation

```yaml
dependencies:
  shoplive_player: 3.0.2   # includes shoplive_core
```

## Android: Maven repository setup

Shoplive Android SDK 3.x is served from `https://sdk.shoplive.cloud/maven-repo`.

**Why `cloud.shoplive` must come only from the Shoplive repository:** Maven Central hosts an artifact with the same coordinates but different contents (`cloud.shoplive:shoplive-media3:1.10.1.2`). The Central copy lacks `ShopLiveHlsPlayerFactory`, which `shoplive-player-sdk:3.0.2` references. If Central is searched first, release (R8) builds fail with *Missing class*, and HLS playback can crash with `NoClassDefFoundError`. The fix is to restrict the `cloud.shoplive` group to the Shoplive repository with `exclusiveContent`. This is a temporary measure until `shoplive-media3` is merged into `shoplive-player-sdk` (planned for 3.0.4).

### (a) Default: automatic

The Shoplive plugins (`shoplive_core`, `shoplive_player`, `shoplive_streamer`) add the repository to `rootProject.allprojects` for you, using `exclusiveContent` for the `cloud.shoplive` group. Gradle fails to resolve a group that is declared `exclusiveContent` more than once. To avoid that, the first Shoplive plugin sets the root-project flag `shopliveMavenRepoConfigured` to `true` and the other plugins skip the declaration. The plugins check the flag's **value** (from `ext` or `gradle.properties`); only `true` counts. You do not need to add anything.

### (b) You declare the repository yourself (mirror/proxy, custom setup)

If your project declares the Shoplive repository itself, do both of the following:

1. Tell the plugins not to add their own declaration. Add this to `android/gradle.properties` (the value must be `true`; `false` or a missing value makes the plugins declare the repository again):

   ```properties
   shopliveMavenRepoConfigured=true
   ```

2. Declare the repository with `exclusiveContent` where your project declares repositories.

Groovy (`android/build.gradle`):

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        exclusiveContent {
            forRepository { maven { url "https://sdk.shoplive.cloud/maven-repo" } }
            filter { includeGroup "cloud.shoplive" }
        }
    }
}
```

Kotlin DSL (`android/build.gradle.kts`):

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        exclusiveContent {
            forRepository { maven { url = uri("https://sdk.shoplive.cloud/maven-repo") } }
            filter { includeGroup("cloud.shoplive") }
        }
    }
}
```

If your build resolves dependencies from `settings.gradle(.kts)` `dependencyResolutionManagement` (repositories mode `PREFER_SETTINGS`), put the same `exclusiveContent` block there and still set the flag. We have not verified this mode with Flutter builds. In Flutter's default mode (`PREFER_PROJECT`), project repositories win.

## Usage

```dart
import 'package:shoplive_player/shoplive_player.dart';

// 1. Initialize once, e.g. in main()
await Shoplive.initialize(const ShopliveConfiguration(accessKey: 'YOUR_ACCESS_KEY'));
await Shoplive.setUser(const ShopliveUser.guest());

final player = ShoplivePlayer.instance;

// 2. Subscribe while the player is in use
player.events.listen((event) {
  switch (event) {
    case ShoplivePlayerStateChanged(:final state): print('state: $state');
    case ShoplivePlayerErrorEvent(:final error): print('error: ${error.code}');
    default: break;
  }
});
player.navigationRequests.listen((r) => openProductPage(r.url));
player.couponRequests.listen((r) async {
  final delivered = await r.respond(const ShopliveCouponResult(
    success: true, status: ShopliveResultStatus.hide, message: 'Coupon issued', alertType: ShopliveResultAlertType.toast));
  if (!delivered) {
    // already answered by the timeout fallback, by another listener, or after detach
  }
});

// 3. Start (configuration is merged on top of the current settings)
await player.start('CAMPAIGN_KEY',
    configuration: const ShoplivePlayerConfiguration(sound: ShopliveSoundOptions(muteOnStart: true)));
await player.setMuted(false);   // NOT_RUNNING if no session is running
await player.close();           // always succeeds
```

### Configuration

- `start(configuration:)` and `setConfiguration` **merge** the given fields on top of the current settings. Omitted fields keep their values. `getConfiguration()` returns the full current configuration.
- Settings made before the first `start`, or across a screen recreation, are kept and applied to the next player instance.
- `presentationStyle: pip` requires `pip.isInAppPipEnabled: true` in the merged configuration. Otherwise `start` fails with `INVALID_ARGUMENT`.
- `configuration.android` holds Android-only options.

### Coupon and custom-action requests

- With no listener on `couponRequests` / `customWebActionRequests`, requests are answered at once with the fallback result: `success: false, status: keep, alertType: toast`.
- With a listener, the SDK waits for `respond` up to the timeout (default 10 s; `setRequestTimeout` accepts 1–120 s). After that the fallback is sent.
- `respond` is valid once per request. It returns `false` when the request was already answered: by timeout, by another listener, or after the plugin was detached.
- Keep request listeners subscribed for the whole session. When every request listener is removed, pending requests are answered with the fallback result.

### Android: picture-in-picture

- In-app PIP works with the default `FlutterActivity` host. The plugin registers the host Activity as the `ViewTreeLifecycleOwner` so that the SDK keeps the player alive when it moves into the host screen. Nothing to change in `MainActivity`.
- For system PIP when the app goes to the background, add `android:supportsPictureInPicture="true"` to your host Activity in `AndroidManifest.xml` (the default Flutter `configChanges` already cover what the SDK checks). Without it the player reports `PIP_ACTIVITY_NOT_DECLARED` and stays in in-app PIP only.
- With a plain `FlutterActivity` host, the SDK does not register its system-PIP mode listener (it only does so for androidx `ComponentActivity` hosts). In-app PIP works, but behavior that depends on system-PIP enter/exit callbacks may be missing. Use `FlutterFragmentActivity` if you rely on system PIP.
- Add-to-app: if the PIP return host is a native Activity (not the Flutter one), make it an androidx `ComponentActivity` (e.g. `AppCompatActivity`); the plugin only patches the Activity the Flutter engine is attached to.
- `shoplive_core` declares `androidx.constraintlayout:constraintlayout:2.2.1` to override the `2.0.1` that the SDK pulls in through `material`. If your app pins an older ConstraintLayout with `force`/`strictly`, in-app PIP layout fails.

## Errors

Every API returns a `Future` and fails with `PlatformException`. The codes are:

| `code` | Meaning |
|---|---|
| `INVALID_ARGUMENT` | Missing or blank required value, wrong type, unknown enum value, out-of-range value, or a value rejected by SDK validation |
| `NO_HOST_SCREEN` | No foreground screen (Activity) to show the player or broadcast UI |
| `NOT_RUNNING` | A session command was sent while no player session is running |
| `SDK_ERROR` | The SDK call failed. `details` contains the exception class name and, when available, the SDK error code |

A method the platform does not implement fails with `MissingPluginException`. Event streams never throw on unexpected payloads. Unknown or malformed events arrive as `…UnknownEvent`, and unknown enum values map to `unknown`.

## Migrating from 1.x

3.0.2 is a rewrite. The 1.x Dart API, the Shortform API and `ShopLiveCommon` have been removed.

| 1.x | 3.0.2 |
|---|---|
| `ShopLiveCommon.setAccessKey` / `setAuth(ShopLiveCommonAuth)` | `Shoplive.initialize(ShopliveConfiguration(accessKey: …, attribution: …))` |
| `ShopLiveCommon.setUtmSource/Medium/Campaign/Content` | `ShopliveConfiguration.attribution` (`ShopliveAttribution`) |
| `ShopLiveCommon.setAuthToken(jwt)` | `Shoplive.setUser(ShopliveUser.token(jwt))` |
| `ShopLiveCommon.setUser(ShopLiveCommonUser)` | `Shoplive.setUser(ShopliveUser.profile(id: …))`. `id` is required |
| guest (`guestUid`) | `Shoplive.setUser(const ShopliveUser.guest())` |
| `ShopLiveCommon.clearAuth` | `Shoplive.logout()` |
| `ShopLivePlayer.play(ShopLivePlayerData)` | `ShoplivePlayer.instance.start(campaignKey, playOptions: …, configuration: …)`. Use `play` to switch campaigns while running |
| `showPreview(ShopLivePlayerPreviewData)` | `start(campaignKey, playOptions: ShoplivePlayOptions(presentationStyle: ShoplivePresentationStyle.pip), configuration: ShoplivePlayerConfiguration(type: ShoplivePlayerType.preview, pip: ShoplivePipOptions(isInAppPipEnabled: true)))`. Preview UI details depend on SDK 3.x; check them on a device |
| Share handling (the 1.x Android bridge overrode `handleShare` and ran the SDK default share after 100 ms) | No share handler in SDK 3.x. Set `configuration.navigation.shareScheme` |
| `setShareScheme` | `configuration.navigation.shareScheme` |
| `setNextActionOnHandleNavigation` | `configuration.navigation.actionOnNavigation` |
| `setEnterPipModeOnBackPressed` | `configuration.android.enterOSPipOnBackPressed` |
| `setMuteWhenPlayStart` | `configuration.sound.muteOnStart` |
| `setMixWithOthers` | `configuration.sound.mixWithOthers` |
| `addParameter` / `removeParameter` | `configuration.customParameters`. The map is replaced as a whole |
| `startPictureInPicture` / `stopPictureInPicture` | `enterPictureInPicture` / `exitPictureInPicture` |
| `sendCommandMessage` | `send(command, payload)` |
| `useCloseButton`, `setEndpoint`, tablet aspect ratio, transparent status bar | No equivalent in SDK 3.0.2 |
| 10 event streams (`handleNavigation`, `handleDownloadCoupon`, `changeCampaignStatus`, `campaignInfo`, `handleCustomAction`, `changedPlayerStatus`, `userInfo`, `error`, `receivedCommand`, `log`) | `events` (sealed `ShoplivePlayerEvent`) plus `navigationRequests`, `couponRequests` and `customWebActionRequests` |
| `log` stream | No confirmed equivalent. `webCommandReceived` / `analytics` may cover some uses (unverified) |
| `ShopLive*` class names | `Shoplive*` |
| Methods returning `void` (errors were swallowed) | Methods return a `Future` and throw `PlatformException` |
| Shortform (`shoplive_shortform.dart`) | Removed |

## Known limitations

- **Nullable settings cannot be reset from Dart.** `navigation.shareScheme` and `android.isVolumeKeyEnabled` cannot be set back to `null`: an omitted field keeps its current value.
- **Sessions do not survive an engine restart.** After the Flutter engine is detached and attached again (add-to-app, multiple engines), the new plugin instance cannot control or observe a session that the previous engine left open (for example with `closeWhenAppDestroyed: false`). Requests from that session are answered with the fallback result.
- **Only synchronous listener errors are handled.** If a request listener throws synchronously, that request is answered with the fallback result immediately. Errors thrown after an `await` in an async listener are not caught. If you never respond, the request falls back when the timeout expires.
- **Silent SDK rejections cannot be detected.** If the launch Activity is gone or is not a `LifecycleOwner`, the SDK rejects `start` with a log message only. `start` still completes successfully.
- **iOS** is not supported in 3.0.2.
- Calling `Shoplive.initialize` more than once (hot restart, multiple engines) behaves however the SDK does. The bridge does not guard it.

## Links

- Android release notes: https://docs.shoplive.cloud/docs/en/android-changelog
- Contact: ask@shoplive.cloud
