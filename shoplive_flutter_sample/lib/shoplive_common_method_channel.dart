import 'package:flutter/services.dart';

import 'shoplive_common.dart';
import 'shoplive_common_platform_interface.dart';
import 'shoplive_player_platform_interface.dart';

/// An implementation of [ShoplivePlayerPlatform] that uses method channels.
class MethodChannelShopliveCommon extends ShopliveCommonPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('shoplive_player');

  @override
  void setAuth({
    required ShopLiveCommonAuth data,
  }) async {
    return await methodChannel.invokeMethod<void>(
        'common_setAuth', data.toJson());
  }

  @override
  void setAuthToken({
    required String? userJWT,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setAuth', <String, dynamic>{
      "userJWT": userJWT,
    });
  }

  @override
  void setUser({
    required String accessKey,
    required ShopLiveCommonUser user,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setUser', <String, dynamic>{
      'accessKey': accessKey,
      'userId': user.userId,
      'name': user.userName,
      'age': user.age,
      'gender': user.gender?.parseText(),
      'userScore': user.userScore,
      'custom': user.custom,
    });
  }

  @override
  void setUtmSource({
    required String? utmSource,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setUtmSource', <String, dynamic>{
      'utmSource': utmSource,
    });
  }

  @override
  void setUtmMedium({
    required String? utmMedium,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setUtmMedium', <String, dynamic>{
      'utmMedium': utmMedium,
    });
  }

  @override
  void setUtmCampaign({
    required String? utmCampaign,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setUtmCampaign', <String, dynamic>{
      'utmCampaign': utmCampaign,
    });
  }

  @override
  void setUtmContent({
    required String? utmContent,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setUtmContent', <String, dynamic>{
      'utmContent': utmContent,
    });
  }

  @override
  void setAccessKey({
    required String? accessKey,
  }) async {
    return await methodChannel
        .invokeMethod<void>('common_setAccessKey', <String, dynamic>{
      'accessKey': accessKey,
    });
  }

  @override
  void clearAuth() async {
    return await methodChannel
        .invokeMethod<void>('common_clearAuth', <String, dynamic>{});
  }
}
