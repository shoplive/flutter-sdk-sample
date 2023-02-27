import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shoplive_player/shoplive_player.dart';

import 'shoplive_player_platform_interface.dart';

/// An implementation of [ShoplivePlayerPlatform] that uses method channels.
class MethodChannelShoplivePlayer extends ShoplivePlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('shoplive_player');

  @override
  void setAccessKey({
    required String accessKey,
  }) async {
    return await methodChannel
        .invokeMethod<void>('setAccessKey', <String, dynamic>{
      'accessKey': accessKey,
    });
  }

  @override
  void setMixWithOthers({
    required bool isMixAudio,
  }) async {
    return await methodChannel
        .invokeMethod<void>('setMixWithOthers', <String, dynamic>{
      'isMixAudio': isMixAudio,
    });
  }

  @override
  void useCloseButton({
    required bool canUse,
  }) async {
    return await methodChannel
        .invokeMethod<void>('useCloseButton', <String, dynamic>{
      'canUse': canUse,
    });
  }

  @override
  void play({
    required String campaignKey,
    bool? keepWindowStateOnPlayExecuted,
  }) async {
    return await methodChannel.invokeMethod<void>('play', <String, dynamic>{
      'campaignKey': campaignKey,
      'keepWindowStateOnPlayExecuted': keepWindowStateOnPlayExecuted
    });
  }

  @override
  void close() async {
    return await methodChannel.invokeMethod<void>('close');
  }

  @override
  void setUser({
    String? userId,
    String? userName,
    int? age,
    ShopLiveGender? gender,
    int? userScore,
    Map<String, String>? parameters,
  }) async {
    return await methodChannel.invokeMethod<void>('setUser', <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'age': age,
      'gender': gender?.parseText(),
      'userScore': userScore,
      'parameters': parameters,
    });
  }

  @override
  void setAuthToken({required String authToken}) async {
    return await methodChannel
        .invokeMethod<void>('setAuthToken', <String, dynamic>{
      'authToken': authToken,
    });
  }

  @override
  void resetUser() async {
    return await methodChannel.invokeMethod<void>('resetUser');
  }

  @override
  void setShareScheme({
    required String shareSchemeUrl,
  }) async {
    return await methodChannel
        .invokeMethod<void>('setShareScheme', <String, dynamic>{
      'shareSchemeUrl': shareSchemeUrl,
    });
  }

  @override
  void setEndpoint({
    required String endpoint,
  }) async {
    return await methodChannel
        .invokeMethod<void>('setEndpoint', <String, dynamic>{
      'endpoint': endpoint,
    });
  }

  @override
  void setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) async {
    return await methodChannel.invokeMethod<void>(
        'setNextActionOnHandleNavigation', <String, dynamic>{
      'type': type.parseValue(),
    });
  }

  @override
  void setEnterPipModeOnBackPressed({
    required bool isEnterPipMode,
  }) async {
    return await methodChannel
        .invokeMethod<void>('setEnterPipModeOnBackPressed', <String, dynamic>{
      'isEnterPipMode': isEnterPipMode,
    });
  }

  @override
  void setMuteWhenPlayStart({
    required bool isMute,
  }) async {
    return await methodChannel
        .invokeMethod<void>('setMuteWhenPlayStart', <String, dynamic>{
      'isMute': isMute,
    });
  }

  @override
  void addParameter({
    required String key,
    required String? value,
  }) async {
    return await methodChannel
        .invokeMethod<void>('addParameter', <String, dynamic>{
      'key': key,
      'value': value,
    });
  }

  @override
  void removeParameter({
    required String key,
  }) async {
    return await methodChannel
        .invokeMethod<void>('removeParameter', <String, dynamic>{
      'key': key,
    });
  }
}
