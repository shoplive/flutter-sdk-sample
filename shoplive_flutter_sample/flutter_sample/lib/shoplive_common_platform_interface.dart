import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shoplive_player_example/shoplive_common_method_channel.dart';

import 'shoplive_common.dart';
import 'shoplive_player_method_channel.dart';

abstract class ShopliveCommonPlatform extends PlatformInterface {
  /// Constructs a ShoplivePlayerPlatform.
  ShopliveCommonPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShopliveCommonPlatform _instance = MethodChannelShopliveCommon() as ShopliveCommonPlatform;

  /// The default instance of [ShoplivePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelShoplivePlayer].
  static ShopliveCommonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShoplivePlayerPlatform] when
  /// they register themselves.
  static set instance(ShopliveCommonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void setAuth({
    required ShopLiveCommonAuth data,
  }) {
    throw UnimplementedError('setAuth() has not been implemented.');
  }

  void setAuthToken({
    required String? userJWT,
  }) {
    throw UnimplementedError('setAuthToken() has not been implemented.');
  }

  void setUser({
    required String accessKey,
    required ShopLiveCommonUser user,
  }) {
    throw UnimplementedError('setUser() has not been implemented.');
  }

  void setUtmSource({
    required String? utmSource,
  }) {
    throw UnimplementedError('setUtmSource() has not been implemented.');
  }

  void setUtmMedium({
    required String? utmMedium,
  }) {
    throw UnimplementedError('setUtmMedium() has not been implemented.');
  }

  void setUtmCampaign({
    required String? utmCampaign,
  }) {
    throw UnimplementedError('setUtmCampaign() has not been implemented.');
  }

  void setUtmContent({
    required String? utmContent,
  }) {
    throw UnimplementedError('setUtmContent() has not been implemented.');
  }

  void setAccessKey({
    required String? accessKey,
  }) {
    throw UnimplementedError('setAccessKey() has not been implemented.');
  }

  void clearAuth() {
    throw UnimplementedError('clearAuth() has not been implemented.');
  }
}
