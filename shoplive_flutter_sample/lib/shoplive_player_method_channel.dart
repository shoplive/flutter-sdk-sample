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
  Future<void> setAccessKey({
    required String accessKey,
  }) async {
    await methodChannel.invokeMethod<void>('setAccessKey', <String, dynamic>{
      'accessKey': accessKey,
    });
  }

  @override
  Future<void> play(
      {required String campaignKey,
      bool? keepWindowStateOnPlayExecuted}) async {
    await methodChannel.invokeMethod<void>('play', <String, dynamic>{
      'campaignKey': campaignKey,
      'keepWindowStateOnPlayExecuted': keepWindowStateOnPlayExecuted
    });
  }

  @override
  Future<void> close() async {
    await methodChannel.invokeMethod<void>('close');
  }

  @override
  Future<void> setUser(
      {String? userId,
      String? userName,
      int? age,
      ShopLiveGender? gender,
      int? userScore}) async {
    await methodChannel.invokeMethod<void>('setUser', <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'age': age,
      'gender': gender?.parseText(),
      'userScore': userScore,
    });
  }

  @override
  Future<void> setAuthToken({required String authToken}) async {
    await methodChannel.invokeMethod<void>('setAuthToken', <String, dynamic>{
      'authToken': authToken,
    });
  }

  @override
  Future<void> resetUser() async {
    await methodChannel.invokeMethod<void>('resetUser');
  }

  @override
  Future<void> setShareScheme({
    required String shareSchemeUrl,
  }) async {
    await methodChannel.invokeMethod<void>('setShareScheme', <String, dynamic>{
      'shareSchemeUrl': shareSchemeUrl,
    });
  }

  @override
  Future<void> setEndpoint({
    required String endpoint,
  }) async {
    await methodChannel.invokeMethod<void>('setEndpoint', <String, dynamic>{
      'endpoint': endpoint,
    });
  }

  @override
  Future<void> setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) async {
    await methodChannel.invokeMethod<void>(
        'setNextActionOnHandleNavigation', <String, dynamic>{
      'type': type.parseValue(),
    });
  }

  @override
  Future<void> setEnterPipModeOnBackPressed({
    required bool isEnterPipMode,
  }) async {
    await methodChannel
        .invokeMethod<void>('setEnterPipModeOnBackPressed', <String, dynamic>{
      'isEnterPipMode': isEnterPipMode,
    });
  }

  @override
  Future<void> setMuteWhenPlayStart({
    required bool isMute,
  }) async {
    await methodChannel
        .invokeMethod<void>('setMuteWhenPlayStart', <String, dynamic>{
      'isMute': isMute,
    });
  }

  @override
  Future<void> addParameter({
    required String key,
    required String? value,
  }) async {
    await methodChannel.invokeMethod<void>('addParameter', <String, dynamic>{
      'key': key,
      'value': value,
    });
  }

  @override
  Future<void> removeParameter({
    required String key,
  }) async {
    await methodChannel.invokeMethod<void>('removeParameter', <String, dynamic>{
      'key': key,
    });
  }
}
