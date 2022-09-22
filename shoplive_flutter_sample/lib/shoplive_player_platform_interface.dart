import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shoplive_player/shoplive_player.dart';

import 'shoplive_player_method_channel.dart';

abstract class ShoplivePlayerPlatform extends PlatformInterface {
  /// Constructs a ShoplivePlayerPlatform.
  ShoplivePlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShoplivePlayerPlatform _instance = MethodChannelShoplivePlayer();

  /// The default instance of [ShoplivePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelShoplivePlayer].
  static ShoplivePlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShoplivePlayerPlatform] when
  /// they register themselves.
  static set instance(ShoplivePlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> setAccessKey({
    required String accessKey,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> play({required String campaignKey, bool? keepWindowStateOnPlayExecuted}) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> close() {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setUser({
    String? userId,
    String? userName,
    int? age,
    ShopLiveGender? gender,
    int? userScore,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setAuthToken({
    required String authToken,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> resetUser() {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setShareScheme({
    required String shareSchemeUrl,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setEndpoint({
    required String endpoint,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setEnterPipModeOnBackPressed({
    required bool isEnterPipMode,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> setMuteWhenPlayStart({
    required bool isMute,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> addParameter({
    required String key,
    required String? value,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> removeParameter({
    required String key,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }
}
