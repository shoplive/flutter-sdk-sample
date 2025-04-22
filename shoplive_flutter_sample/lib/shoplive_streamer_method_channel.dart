import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'shoplive_streamer_platform_interface.dart';

/// An implementation of [ShoplivePlayerPlatform] that uses method channels.
class MethodChannelShopliveStreamer extends ShopliveStreamerPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('shoplive_player');

  @override
  void play({
    String? campaignKey
  }) async {
    return await methodChannel.invokeMethod<void>('streamer_play', <String, dynamic>{"campaignKey" : campaignKey});
  }
}
