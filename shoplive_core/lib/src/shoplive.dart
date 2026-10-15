import 'models/configuration.dart';
import 'models/conversion.dart';
import 'models/user.dart';
import 'platform/shoplive_core_platform_interface.dart';

/// Shoplive core API(design.md rev2 §2.4 shoplive_core). 모든 메서드는 실패 시 PlatformException을 던진다.
///
/// 초기화 전 호출을 브릿지가 막지 않는다 — SDK 동작에 위임(F-01).
abstract final class Shoplive {
  static ShopliveCorePlatform get _platform => ShopliveCorePlatform.instance;

  static Future<void> initialize(ShopliveConfiguration configuration) =>
      _platform.initialize(configuration.toWire());

  static Future<void> setUser(ShopliveUser user) => _platform.setUser(user.toWire());

  static Future<void> setStreamToken(String token) => _platform.setStreamToken(token);

  static Future<void> logout() => _platform.logout();

  static Future<void> sendConversionEvent(ShopliveConversionData data) =>
      _platform.sendConversionEvent(data.toWire());

  static Future<String> getSdkVersion() => _platform.getSdkVersion();
}
