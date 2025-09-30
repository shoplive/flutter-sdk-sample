import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shoplive_player/shoplive_player.dart' as shoplive_player;

import 'shoplive_player_platform_interface.dart';

const String _EVENT_PLAYER_HANDLE_NAVIGATION = "event_player_handle_navigation";
const String _EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON =
    "event_player_handle_download_coupon";
const String _EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS =
    "event_player_change_campaign_status";
const String _EVENT_PLAYER_CAMPAIGN_INFO = "event_player_campaign_info";
const String _EVENT_PLAYER_ERROR = "event_player_error";
const String _EVENT_PLAYER_HANDLE_CUSTOM_ACTION =
    "event_player_handle_custom_action";
const String _EVENT_PLAYER_CHANGED_PLAYER_STATUS =
    "event_player_changed_player_status";
const String _EVENT_PLAYER_SET_USER_NAME = "event_player_set_user_name";
const String _EVENT_PLAYER_RECEIVED_COMMAND = "event_player_received_command";
const String _EVENT_PLAYER_LOG = "event_player_log";

class ShopLivePlayer {
  late final Stream<ShopLiveHandleNavigation> handleNavigation =
      const EventChannel(_EVENT_PLAYER_HANDLE_NAVIGATION)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveHandleNavigation.fromJson(json));

  late final Stream<ShopLiveHandleDownloadCoupon> handleDownloadCoupon =
      const EventChannel(_EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveHandleDownloadCoupon.fromJson(json));

  late final Stream<ShopLiveChangeCampaignStatus> changeCampaignStatus =
      const EventChannel(_EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveChangeCampaignStatus.fromJson(json));

  late final Stream<ShopLiveCampaignInfo> campaignInfo =
      const EventChannel(_EVENT_PLAYER_CAMPAIGN_INFO)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveCampaignInfo.fromJson(json));

  late final Stream<ShopLiveHandleCustomAction> handleCustomAction =
      const EventChannel(_EVENT_PLAYER_HANDLE_CUSTOM_ACTION)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveHandleCustomAction.fromJson(json));

  late final Stream<ShopLiveChangedPlayerStatus> changedPlayerStatus =
      const EventChannel(_EVENT_PLAYER_CHANGED_PLAYER_STATUS)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveChangedPlayerStatus.fromJson(json));

  late final Stream<ShopLiveUserInfo> userInfo =
      const EventChannel(_EVENT_PLAYER_SET_USER_NAME)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveUserInfo.fromJson(json));

  late final Stream<ShopLivePlayerError> error =
      const EventChannel(_EVENT_PLAYER_ERROR)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLivePlayerError.fromJson(json));

  late final Stream<ShopLiveReceivedCommand> receivedCommand =
      const EventChannel(_EVENT_PLAYER_RECEIVED_COMMAND)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveReceivedCommand.fromJson(json));

  late final Stream<ShopLivePlayerLog> log =
      const EventChannel(_EVENT_PLAYER_LOG)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLivePlayerLog.fromJson(json));

  void setMixWithOthers({
    required bool isMixAudio,
  }) {
    return ShoplivePlayerPlatform.instance
        .setMixWithOthers(isMixAudio: isMixAudio);
  }

  void useCloseButton({
    required bool canUse,
  }) {
    return ShoplivePlayerPlatform.instance.useCloseButton(canUse: canUse);
  }

  void play({
    required ShopLivePlayerData data,
  }) {
    return ShoplivePlayerPlatform.instance.play(data: data.toPackageType());
  }

  void showPreview({
    required ShopLivePlayerPreviewData data,
  }) {
    return ShoplivePlayerPlatform.instance.showPreview(data: data.toPackageType());
  }

  void close() {
    return ShoplivePlayerPlatform.instance.close();
  }

  void startPictureInPicture() {
    return ShoplivePlayerPlatform.instance.startPictureInPicture();
  }

  void stopPictureInPicture() {
    return ShoplivePlayerPlatform.instance.stopPictureInPicture();
  }

  void sendCommandMessage({
    required String command,
    required Map<String, dynamic> payload,
  }) async {
    return ShoplivePlayerPlatform.instance
        .sendCommandMessage(command: command, payload: payload);
  }

  void setShareScheme({
    required String shareSchemeUrl,
  }) {
    return ShoplivePlayerPlatform.instance
        .setShareScheme(shareSchemeUrl: shareSchemeUrl);
  }

  void setEndpoint({
    required String? endpoint,
  }) {
    return ShoplivePlayerPlatform.instance.setEndpoint(endpoint: endpoint);
  }

  void setNextActionOnHandleNavigation({
    required ShopLiveActionType type,
  }) {
    return ShoplivePlayerPlatform.instance
        .setNextActionOnHandleNavigation(type: type.toPackageType());
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

  Future<String?> getSdkVersion() {
    return ShoplivePlayerPlatform.instance.getSdkVersion();
  }

  Future<String?> getPluginVersion() {
    return ShoplivePlayerPlatform.instance.getPluginVersion();
  }
}


class ShopLivePlayerData {
  final String campaignKey;
  bool keepWindowStateOnPlayExecuted;
  String? referrer;

  ShopLivePlayerData({
    required this.campaignKey,
    this.keepWindowStateOnPlayExecuted = false,
    this.referrer,
  });

  shoplive_player.ShopLivePlayerData toPackageType() {
    return shoplive_player.ShopLivePlayerData(
      campaignKey: campaignKey,
      keepWindowStateOnPlayExecuted: keepWindowStateOnPlayExecuted,
      referrer: referrer,
    );
  }
}

class ShopLivePlayerPreviewData {
  final String campaignKey;
  bool useCloseButton;
  String? referrer;

  ShopLivePlayerPreviewData({
    required this.campaignKey,
    this.useCloseButton = false,
    this.referrer,
  });

  shoplive_player.ShopLivePlayerPreviewData toPackageType() {
    return shoplive_player.ShopLivePlayerPreviewData(
      campaignKey: campaignKey,
      useCloseButton: useCloseButton,
      referrer: referrer,
    );
  }
}

enum ShopLiveActionType { show, hide, keep }

extension ShopLiveActionTypeExtension on ShopLiveActionType {
  shoplive_player.ShopLiveActionType toPackageType() {
    switch (this) {
      case ShopLiveActionType.show:
        return shoplive_player.ShopLiveActionType.show;
      case ShopLiveActionType.hide:
        return shoplive_player.ShopLiveActionType.hide;
      case ShopLiveActionType.keep:
        return shoplive_player.ShopLiveActionType.keep;
    }
  }
  String parseValue() {
    switch (this) {
      case ShopLiveActionType.show:
        return 'show';
      case ShopLiveActionType.hide:
        return 'hide';
      case ShopLiveActionType.keep:
        return 'keep';
    }
  }
}

class ShopLiveHandleNavigation {
  final String url;

  ShopLiveHandleNavigation({required this.url});

  factory ShopLiveHandleNavigation.fromJson(Map<String, dynamic> json) {
    return ShopLiveHandleNavigation(
      url: json['url'],
    );
  }
}

class ShopLiveHandleDownloadCoupon {
  final String couponId;

  ShopLiveHandleDownloadCoupon({required this.couponId});

  factory ShopLiveHandleDownloadCoupon.fromJson(Map<String, dynamic> json) {
    return ShopLiveHandleDownloadCoupon(
      couponId: json['couponId'],
    );
  }
}

class ShopLiveChangeCampaignStatus {
  final String campaignStatus;

  ShopLiveChangeCampaignStatus({required this.campaignStatus});

  factory ShopLiveChangeCampaignStatus.fromJson(Map<String, dynamic> json) {
    return ShopLiveChangeCampaignStatus(
      campaignStatus: json['campaignStatus'],
    );
  }
}

class ShopLiveCampaignInfo {
  final Map<String, dynamic> campaignInfo;

  ShopLiveCampaignInfo({required this.campaignInfo});

  factory ShopLiveCampaignInfo.fromJson(Map<String, dynamic> json) {
    return ShopLiveCampaignInfo(
      campaignInfo: json['campaignInfo'],
    );
  }
}

class ShopLivePlayerError {
  final String code;
  final String message;

  ShopLivePlayerError({required this.code, required this.message});

  factory ShopLivePlayerError.fromJson(Map<String, dynamic> json) {
    return ShopLivePlayerError(
      code: json['code'],
      message: json['message'],
    );
  }
}

class ShopLiveHandleCustomAction {
  final String id;
  final String type;
  final String payload;

  ShopLiveHandleCustomAction(
      {required this.id, required this.type, required this.payload});

  factory ShopLiveHandleCustomAction.fromJson(Map<String, dynamic> json) {
    return ShopLiveHandleCustomAction(
      id: json['id'],
      type: json['type'],
      payload: json['payload'],
    );
  }
}

class ShopLiveChangedPlayerStatus {
  final ShopLivePlayStatus status;

  ShopLiveChangedPlayerStatus({required this.status});

  factory ShopLiveChangedPlayerStatus.fromJson(Map<String, dynamic> json) {
    String? stateString = json['status'];
    ShopLivePlayStatus status;
    if (stateString == 'CREATED') {
      status = ShopLivePlayStatus.created;
    } else if (stateString == 'DESTROYED') {
      status = ShopLivePlayStatus.destroyed;
    } else {
      status = ShopLivePlayStatus.destroyed;
    }

    return ShopLiveChangedPlayerStatus(
      status: status,
    );
  }
}

enum ShopLivePlayStatus { created, destroyed }

class ShopLiveUserInfo {
  final Map<String, dynamic> userInfo;

  ShopLiveUserInfo({required this.userInfo});

  factory ShopLiveUserInfo.fromJson(Map<String, dynamic> json) {
    return ShopLiveUserInfo(
      userInfo: json['userInfo'],
    );
  }
}

class ShopLiveReceivedCommand {
  final String command;
  final Map<String, dynamic> data;

  ShopLiveReceivedCommand({
    required this.command,
    required this.data,
  });

  factory ShopLiveReceivedCommand.fromJson(Map<String, dynamic> json) {
    return ShopLiveReceivedCommand(
      command: json['command'],
      data: json['data'],
    );
  }
}

class ShopLivePlayerLog {
  final String name;
  final String feature;
  final String campaignKey;
  final Map<String, dynamic> payload;

  ShopLivePlayerLog({
    required this.name,
    required this.feature,
    required this.campaignKey,
    required this.payload,
  });

  factory ShopLivePlayerLog.fromJson(Map<String, dynamic> json) {
    return ShopLivePlayerLog(
      name: json['name'],
      feature: json['feature'],
      campaignKey: json['campaignKey'],
      payload: json['payload'],
    );
  }
}

class ShopLiveBaseData {
  ShopLiveBaseData();

  factory ShopLiveBaseData.fromJson(Map<String, dynamic> json) {
    return ShopLiveBaseData();
  }
}

