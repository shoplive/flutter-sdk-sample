import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'shoplive_streamer_method_channel.dart';

abstract class ShopliveStreamerPlatform extends PlatformInterface {
  /// Constructs a ShoplivePlayerPlatform.
  ShopliveStreamerPlatform() : super(token: _token);

  static final Object _token = Object();

  static MethodChannelShopliveStreamer _instance = MethodChannelShopliveStreamer();

  /// The default instance of [ShoplivePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelShoplivePlayer].
  static MethodChannelShopliveStreamer get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShoplivePlayerPlatform] when
  /// they register themselves.
  static set instance(MethodChannelShopliveStreamer instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void play() {
    throw UnimplementedError('play() has not been implemented.');
  }
}
