import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'shoplive_player_platform_interface.dart';
import 'shoplive_shortform.dart';
import 'shoplive_shortform_platform_interface.dart';

/// An implementation of [ShoplivePlayerPlatform] that uses method channels.
class MethodChannelShopliveShortform extends ShopliveShortformPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('shoplive_player');

  @override
  void play({
    required ShopLiveShortformCollectionData data,
  }) async {
    return await methodChannel.invokeMethod<void>('shortform_play', <String, dynamic>{
      'shortsId': data.shortsId,
      'shortsCollectionId': data.shortsCollectionId,
      'tags': data.tags,
      'tagSearchOperator': data.tagSearchOperator?.text(),
      'brands': data.brands,
      'skus': data.skus,
      'shuffle': data.shuffle,
      'referrer': data.referrer,
    });
  }

  @override
  void close() async {
    return await methodChannel.invokeMethod<void>('shortform_close', <String, dynamic>{});
  }
}
