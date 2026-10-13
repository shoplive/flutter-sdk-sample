# shoplive_core

Shared Shoplive API for Flutter, built on Shoplive Android SDK **3.0.2** (`cloud.shoplive:shoplive-core`): initialization, user, and conversion events.
It is re-exported by `shoplive_player` and `shoplive_streamer`. Add it directly only if you use neither.

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
  shoplive_core: 3.0.2
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
import 'package:shoplive_core/shoplive_core.dart';

await Shoplive.initialize(const ShopliveConfiguration(
  accessKey: 'YOUR_ACCESS_KEY',
  attribution: ShopliveAttribution(utmSource: 'app'),
));
await Shoplive.setUser(const ShopliveUser.profile(id: 'user-1', name: 'Jane', gender: ShopliveGender.female));
await Shoplive.sendConversionEvent(const ShopliveConversionData(
  type: 'purchase',
  orderId: 'order-1',
  products: [ShopliveConversionProduct(productId: 'p1', purchaseQuantity: 1, purchaseUnitPrice: 9900)],
));
await Shoplive.logout();
```

- Required strings (`accessKey`, profile `id`, `jwt`, stream token) must not be blank.
- The bridge does not track initialization state. Calls made before `initialize` behave however the SDK does.
- `package:shoplive_core/shoplive_core_bridge.dart` is for internal use by the Shoplive packages only. It is not a supported API.

## Errors

Every API returns a `Future` and fails with `PlatformException`. The codes are:

| `code` | Meaning |
|---|---|
| `INVALID_ARGUMENT` | Missing or blank required value, wrong type, unknown enum value, out-of-range value, or a value rejected by SDK validation |
| `NO_HOST_SCREEN` | No foreground screen (Activity) to show the player or broadcast UI |
| `NOT_RUNNING` | A session command was sent while no player session is running |
| `SDK_ERROR` | The SDK call failed. `details` contains the exception class name and, when available, the SDK error code |

A method the platform does not implement fails with `MissingPluginException`. Event streams never throw on unexpected payloads. Unknown or malformed events arrive as `…UnknownEvent`, and unknown enum values map to `unknown`.

## Migration from 1.x

`ShopLiveCommon` is replaced by `Shoplive` (`initialize` / `setUser` / `logout`). See the `shoplive_player` README for the full table.

## Known limitations

- iOS is not supported in 3.0.2.
- Calling `Shoplive.initialize` more than once (hot restart, multiple engines) behaves however the SDK does. The bridge does not guard it.
