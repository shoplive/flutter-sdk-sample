import 'dart:convert';

import 'package:flutter/services.dart';

import 'shoplive_player_platform_interface.dart';

const String EVENT_HANDLE_NAVIGATION = "event_handle_navigation";
const String EVENT_HANDLE_DOWNLOAD_COUPON = "event_handle_download_coupon";
const String EVENT_CHANGE_CAMPAIGN_STATUS = "event_change_campaign_status";
const String EVENT_CAMPAIGN_INFO = "event_campaign_info";
const String EVENT_ERROR = "event_error";
const String EVENT_HANDLE_CUSTOM_ACTION = "event_handle_custom_action";
const String EVENT_CHANGED_PLAYER_STATUS = "event_changed_player_status";
const String EVENT_SET_USER_NAME = "event_set_user_name";
const String EVENT_RECEIVED_COMMAND = "event_received_command";
const String EVENT_LOG = "event_log";

class ShopLivePlayer {
  late final Stream<HandleNavigation> handleNavigation =
      const EventChannel(EVENT_HANDLE_NAVIGATION)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => HandleNavigation.fromJson(json));

  late final Stream<HandleDownloadCoupon> handleDownloadCoupon =
      const EventChannel(EVENT_HANDLE_DOWNLOAD_COUPON)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => HandleDownloadCoupon.fromJson(json));

  late final Stream<ChangeCampaignStatus> changeCampaignStatus =
      const EventChannel(EVENT_CHANGE_CAMPAIGN_STATUS)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ChangeCampaignStatus.fromJson(json));

  late final Stream<CampaignInfo> campaignInfo =
      const EventChannel(EVENT_CAMPAIGN_INFO)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => CampaignInfo.fromJson(json));

  late final Stream<HandleCustomAction> handleCustomAction =
      const EventChannel(EVENT_HANDLE_CUSTOM_ACTION)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => HandleCustomAction.fromJson(json));

  late final Stream<ChangedPlayerStatus> changedPlayerStatus =
      const EventChannel(EVENT_CHANGED_PLAYER_STATUS)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ChangedPlayerStatus.fromJson(json));

  late final Stream<UserInfo> userInfo = const EventChannel(EVENT_SET_USER_NAME)
      .receiveBroadcastStream()
      .map((jsonString) => const JsonDecoder().convert(jsonString))
      .map((json) => UserInfo.fromJson(json));

  late final Stream<Error> error = const EventChannel(EVENT_ERROR)
      .receiveBroadcastStream()
      .map((jsonString) => const JsonDecoder().convert(jsonString))
      .map((json) => Error.fromJson(json));

  late final Stream<ReceivedCommand> receivedCommand =
      const EventChannel(EVENT_RECEIVED_COMMAND)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ReceivedCommand.fromJson(json));

  late final Stream<ShopLiveLog> log = const EventChannel(EVENT_LOG)
      .receiveBroadcastStream()
      .map((jsonString) => const JsonDecoder().convert(jsonString))
      .map((json) => ShopLiveLog.fromJson(json));

  void setAccessKey({
    required String accessKey,
  }) {
    return ShoplivePlayerPlatform.instance.setAccessKey(accessKey: accessKey);
  }

  void setMixWithOthers({
    required bool isMixAudio,
  }) {
    return ShoplivePlayerPlatform.instance.setMixWithOthers(isMixAudio: isMixAudio);
  }

  void useCloseButton({
    required bool canUse,
  }) {
    return ShoplivePlayerPlatform.instance.useCloseButton(canUse: canUse);
  }

  void play({
    required String campaignKey,
    bool? keepWindowStateOnPlayExecuted,
  }) {
    return ShoplivePlayerPlatform.instance.play(
      campaignKey: campaignKey,
      keepWindowStateOnPlayExecuted: keepWindowStateOnPlayExecuted,
    );
  }

  void close() {
    return ShoplivePlayerPlatform.instance.close();
  }

  void setUser({
    String? userId,
    String? userName,
    int? age,
    ShopLiveGender? gender,
    int? userScore,
    Map<String, String>? parameters,
  }) {
    return ShoplivePlayerPlatform.instance.setUser(
        userId: userId,
        userName: userName,
        age: age,
        gender: gender,
        userScore: userScore,
        parameters: parameters);
  }

  void setAuthToken({required String authToken}) {
    return ShoplivePlayerPlatform.instance.setAuthToken(authToken: authToken);
  }

  void resetUser() {
    return ShoplivePlayerPlatform.instance.resetUser();
  }

  void setShareScheme({
    required String shareSchemeUrl,
  }) {
    return ShoplivePlayerPlatform.instance
        .setShareScheme(shareSchemeUrl: shareSchemeUrl);
  }

  void setEndpoint({
    required String endpoint,
  }) {
    return ShoplivePlayerPlatform.instance.setEndpoint(endpoint: endpoint);
  }

  void setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) {
    return ShoplivePlayerPlatform.instance
        .setNextActionOnHandleNavigation(type: type);
  }

  void setEnterPipModeOnBackPressed({
    required bool isEnterPipMode,
  }) {
    return ShoplivePlayerPlatform.instance
        .setEnterPipModeOnBackPressed(isEnterPipMode: isEnterPipMode);
  }

  void setMuteWhenPlayStart({
    required bool isMute,
  }) {
    return ShoplivePlayerPlatform.instance.setMuteWhenPlayStart(isMute: isMute);
  }

  void addParameter({
    required String key,
    required String? value,
  }) {
    return ShoplivePlayerPlatform.instance.addParameter(key: key, value: value);
  }

  void removeParameter({
    required String key,
  }) {
    return ShoplivePlayerPlatform.instance.removeParameter(key: key);
  }
}

enum ShopLiveGender { male, female, neutral }

extension ShopLiveGenderExtension on ShopLiveGender {
  String parseText() {
    var text = "";
    switch (this) {
      case ShopLiveGender.male:
        text = "m";
        break;
      case ShopLiveGender.female:
        text = "f";
        break;
      default:
        text = "n";
        break;
    }
    return text;
  }
}

enum ShopLiveActionType { show, hide, keep }

extension ShopLiveActionTypeExtension on ShopLiveActionType {
  int? parseValue() {
    int? value;
    switch (this) {
      case ShopLiveActionType.show:
        value = 0;
        break;
      case ShopLiveActionType.hide:
        value = 1;
        break;
      case ShopLiveActionType.keep:
        value = 2;
        break;
    }
    return value;
  }
}

class HandleNavigation {
  final String url;

  HandleNavigation({required this.url});

  factory HandleNavigation.fromJson(Map<String, dynamic> json) {
    return HandleNavigation(
      url: json['url'],
    );
  }
}

class HandleDownloadCoupon {
  final String couponId;

  HandleDownloadCoupon({required this.couponId});

  factory HandleDownloadCoupon.fromJson(Map<String, dynamic> json) {
    return HandleDownloadCoupon(
      couponId: json['couponId'],
    );
  }
}

class ChangeCampaignStatus {
  final String campaignStatus;

  ChangeCampaignStatus({required this.campaignStatus});

  factory ChangeCampaignStatus.fromJson(Map<String, dynamic> json) {
    return ChangeCampaignStatus(
      campaignStatus: json['campaignStatus'],
    );
  }
}

class CampaignInfo {
  final Map<String, dynamic> campaignInfo;

  CampaignInfo({required this.campaignInfo});

  factory CampaignInfo.fromJson(Map<String, dynamic> json) {
    return CampaignInfo(
      campaignInfo: json['campaignInfo'],
    );
  }
}

class Error {
  final String code;
  final String message;

  Error({required this.code, required this.message});

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'],
      message: json['message'],
    );
  }
}

class HandleCustomAction {
  final String id;
  final String type;
  final String payload;

  HandleCustomAction(
      {required this.id, required this.type, required this.payload});

  factory HandleCustomAction.fromJson(Map<String, dynamic> json) {
    return HandleCustomAction(
      id: json['id'],
      type: json['type'],
      payload: json['payload'],
    );
  }
}

class ChangedPlayerStatus {
  final ShopLivePlayStatus status;

  ChangedPlayerStatus({required this.status});

  factory ChangedPlayerStatus.fromJson(Map<String, dynamic> json) {
    String? stateString = json['status'];
    ShopLivePlayStatus status;
    if (stateString == 'CREATED') {
      status = ShopLivePlayStatus.created;
    } else if (stateString == 'DESTROYED') {
      status = ShopLivePlayStatus.destroyed;
    } else {
      status = ShopLivePlayStatus.destroyed;
    }

    return ChangedPlayerStatus(
      status: status,
    );
  }
}

enum ShopLivePlayStatus { created, destroyed }

class UserInfo {
  final Map<String, dynamic> userInfo;

  UserInfo({required this.userInfo});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userInfo: json['userInfo'],
    );
  }
}

class ReceivedCommand {
  final String command;
  final Map<String, dynamic> data;

  ReceivedCommand({
    required this.command,
    required this.data,
  });

  factory ReceivedCommand.fromJson(Map<String, dynamic> json) {
    return ReceivedCommand(
      command: json['command'],
      data: json['data'],
    );
  }
}

class ShopLiveLog {
  final String name;
  final String feature;
  final String campaignKey;
  final Map<String, dynamic> payload;

  ShopLiveLog({
    required this.name,
    required this.feature,
    required this.campaignKey,
    required this.payload,
  });

  factory ShopLiveLog.fromJson(Map<String, dynamic> json) {
    return ShopLiveLog(
      name: json['name'],
      feature: json['feature'],
      campaignKey: json['campaignKey'],
      payload: json['payload'],
    );
  }
}
