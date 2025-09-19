import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shoplive_player_example/shoplive_player.dart';

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

  void setMixWithOthers({
    required bool isMixAudio,
  }) {
    throw UnimplementedError('setMixWithOthers() has not been implemented.');
  }

  void useCloseButton({
    required bool canUse,
  }) {
    throw UnimplementedError('useCloseButton() has not been implemented.');
  }

  void play({
    required ShopLivePlayerData data,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  void showPreview({
    required ShopLivePlayerPreviewData data,
  }) {
    throw UnimplementedError('showPreview() has not been implemented.');
  }

  void close() {
    throw UnimplementedError('close() has not been implemented.');
  }

  void startPictureInPicture() {
    throw UnimplementedError('startPictureInPicture() has not been implemented.');
  }

  void stopPictureInPicture() {
    throw UnimplementedError('stopPictureInPicture() has not been implemented.');
  }

  void sendCommandMessage({
    required String command,
    required Map<String, dynamic> payload,
  }) async {
    throw UnimplementedError('sendCommandMessage() has not been implemented.');
  }

  void setShareScheme({
    required String shareSchemeUrl,
  }) {
    throw UnimplementedError('setShareScheme() has not been implemented.');
  }

  void setEndpoint({
    required String? endpoint,
  }) {
    throw UnimplementedError('setEndpoint() has not been implemented.');
  }

  void setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) {
    throw UnimplementedError('setNextActionOnHandleNavigation() has not been implemented.');
  }

  void setEnterPipModeOnBackPressed({
    required bool isEnterPipMode,
  }) {
    throw UnimplementedError('setEnterPipModeOnBackPressed() has not been implemented.');
  }

  void setMuteWhenPlayStart({
    required bool isMute,
  }) {
    throw UnimplementedError('setMuteWhenPlayStart() has not been implemented.');
  }

  void addParameter({
    required String key,
    required String? value,
  }) {
    throw UnimplementedError('addParameter() has not been implemented.');
  }

  void removeParameter({
    required String key,
  }) {
    throw UnimplementedError('removeParameter() has not been implemented.');
  }
}
