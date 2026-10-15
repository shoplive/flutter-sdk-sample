import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'shoplive_core_method_channel.dart';

/// shoplive_core 플랫폼 인터페이스. 인자는 이미 wire Map으로 변환된 값이다.
abstract class ShopliveCorePlatform extends PlatformInterface {
  ShopliveCorePlatform() : super(token: _token);

  static final Object _token = Object();

  static ShopliveCorePlatform _instance = MethodChannelShopliveCore();

  static ShopliveCorePlatform get instance => _instance;

  static set instance(ShopliveCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(Map<String, Object?> configuration);
  Future<void> setUser(Map<String, Object?> user);
  Future<void> setStreamToken(String token);
  Future<void> logout();
  Future<void> sendConversionEvent(Map<String, Object?> data);
  Future<String> getSdkVersion();
}
