import 'package:flutter/services.dart';
import 'package:shoplive_player/shoplive_player.dart';

import 'shoplive_player_platform_interface.dart';

/// An implementation of [ShoplivePlayerPlatform] that uses method channels.
class MethodChannelShoplivePlayer extends ShoplivePlayerPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('shoplive_player');

  @override
  void setMixWithOthers({
    required bool isMixAudio,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_setMixWithOthers', <String, dynamic>{
      'isMixAudio': isMixAudio,
    });
  }

  @override
  void useCloseButton({
    required bool canUse,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_useCloseButton', <String, dynamic>{
      'canUse': canUse,
    });
  }

  @override
  void play({
    required ShopLivePlayerData data,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_play', <String, dynamic>{
      'campaignKey': data.campaignKey,
      'keepWindowStateOnPlayExecuted': data.keepWindowStateOnPlayExecuted,
      'referrer': data.referrer
    });
  }

  @override
  void showPreview({
    required ShopLivePlayerPreviewData data,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_showPreview', <String, dynamic>{
      'campaignKey': data.campaignKey,
      'useCloseButton': data.useCloseButton,
      'enableSwipeOut': data.enableSwipeOut,
      'pipRadius': data.pipRadius,
      'referrer': data.referrer,
      'pipMaxSize': data.pipMaxSize,
      'marginTop': data.marginTop,
      'marginBottom': data.marginBottom,
      'marginLeft': data.marginLeft,
      'marginRight': data.marginRight,
      'position': data.position,
    });
  }

  @override
  void close() async {
    return await methodChannel.invokeMethod<void>('player_close');
  }

  @override
  void startPictureInPicture() async {
    return await methodChannel
        .invokeMethod<void>('player_startPictureInPicture');
  }

  @override
  void stopPictureInPicture() async {
    return await methodChannel
        .invokeMethod<void>('player_stopPictureInPicture');
  }

  @override
  void sendCommandMessage({
    required String command,
    required Map<String, dynamic> payload,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_sendCommandMessage', <String, dynamic>{
      'command': command,
      'payload': payload,
    });
  }

  @override
  void setShareScheme({
    required String shareSchemeUrl,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_setShareScheme', <String, dynamic>{
      'shareSchemeUrl': shareSchemeUrl,
    });
  }

  @override
  void setEndpoint({
    required String? endpoint,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_setEndpoint', <String, dynamic>{
      'endpoint': endpoint,
    });
  }

  @override
  void setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) async {
    return await methodChannel.invokeMethod<void>(
        'player_setNextActionOnHandleNavigation', <String, dynamic>{
      'type': type.parseValue(),
    });
  }

  @override
  void setEnterPipModeOnBackPressed({
    required bool isEnterPipMode,
  }) async {
    return await methodChannel.invokeMethod<void>(
        'player_setEnterPipModeOnBackPressed', <String, dynamic>{
      'isEnterPipMode': isEnterPipMode,
    });
  }

  @override
  void setMuteWhenPlayStart({
    required bool isMute,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_setMuteWhenPlayStart', <String, dynamic>{
      'isMute': isMute,
    });
  }

  @override
  void addParameter({
    required String key,
    required String? value,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_addParameter', <String, dynamic>{
      'key': key,
      'value': value,
    });
  }

  @override
  void removeParameter({
    required String key,
  }) async {
    return await methodChannel
        .invokeMethod<void>('player_removeParameter', <String, dynamic>{
      'key': key,
    });
  }

  @override
  Future<String> getSdkVersion() async {
    return await methodChannel.invokeMethod<String>('player_getSdkVersion') ?? '';
  }

  @override
  Future<String> getPluginVersion() async {
    return await methodChannel.invokeMethod<String>('player_getPluginVersion') ?? '';
  }
}
