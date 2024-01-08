import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'shoplive_player_method_channel.dart';
import 'shoplive_shortform.dart';
import 'shoplive_shortform_method_channel.dart';

abstract class ShopliveShortformPlatform extends PlatformInterface {
  /// Constructs a ShoplivePlayerPlatform.
  ShopliveShortformPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShopliveShortformPlatform _instance = MethodChannelShopliveShortform();

  /// The default instance of [ShoplivePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelShoplivePlayer].
  static ShopliveShortformPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShoplivePlayerPlatform] when
  /// they register themselves.
  static set instance(ShopliveShortformPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void play({
    required ShopLiveShortformCollectionData data,
  }) {
    throw UnimplementedError('play() has not been implemented.');
  }

  void close() {
    throw UnimplementedError('close() has not been implemented.');
  }
}
