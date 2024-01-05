import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shoplive_player/shoplive_player.dart';

import 'shoplive_player_platform_interface.dart';
import 'shoplive_shortform_platform_interface.dart';

const String EVENT_SHORTFORM_CLICK_PRODUCT = "event_shortform_click_product";
const String EVENT_SHORTFORM_CLICK_BANNER = "event_shortform_click_banner";
const String EVENT_SHORTFORM_SHARE = "event_shortform_share";
const String EVENT_SHORTFORM_START = "event_shortform_start";
const String EVENT_SHORTFORM_CLOSE = "event_shortform_close";
const String EVENT_SHORTFORM_LOG = "event_shortform_log";

class ShopLiveShortform {
  late final Stream<ShopLiveShortformProductData> onClickProduct =
      const EventChannel(EVENT_SHORTFORM_CLICK_PRODUCT)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveShortformProductData.fromJson(json));

  late final Stream<ShopliveShortformUrlData> onClickBanner =
      const EventChannel(EVENT_SHORTFORM_CLICK_BANNER)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopliveShortformUrlData.fromJson(json));

  late final Stream<ShopLiveShortformShareData> onShare =
      const EventChannel(EVENT_SHORTFORM_SHARE)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveShortformShareData.fromJson(json));

  late final Stream<ShopLiveBaseData> onStart =
      const EventChannel(EVENT_SHORTFORM_START)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveBaseData.fromJson(json));

  late final Stream<ShopLiveBaseData> onClose =
      const EventChannel(EVENT_SHORTFORM_CLOSE)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveBaseData.fromJson(json));

  late final Stream<ShopliveShortformLogData> log =
      const EventChannel(EVENT_SHORTFORM_LOG)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopliveShortformLogData.fromJson(json));

  void play({
    required ShopLiveShortformCollectionData data,
  }) {
    return ShopliveShortformPlatform.instance.play(data: data);
  }

  void close() {
    return ShopliveShortformPlatform.instance.close();
  }
}

class ShopLiveShortformProductData {
  String? brand;
  String? currency;
  String? description;
  double? discountPrice;
  double? discountRate;
  String? imageUrl;
  String? name;
  double? originalPrice;
  int? productId;
  bool? showPrice;
  String? sku;
  String? stockStatus;
  String? url;

  ShopLiveShortformProductData({
    this.brand,
    this.currency,
    this.description,
    this.discountPrice,
    this.discountRate,
    this.imageUrl,
    this.name,
    this.originalPrice,
    this.productId,
    this.showPrice,
    this.sku,
    this.stockStatus,
    this.url,
  });

  factory ShopLiveShortformProductData.fromJson(Map<String, dynamic> json) {
    return ShopLiveShortformProductData(
      brand: json['brand'],
      currency: json['currency'],
      description: json['description'],
      discountPrice: json['discountPrice'],
      discountRate: json['discountRate'],
      imageUrl: json['imageUrl'],
      name: json['name'],
      originalPrice: json['originalPrice'],
      productId: json['productId'],
      showPrice: json['showPrice'],
      sku: json['sku'],
      stockStatus: json['stockStatus'],
      url: json['url'],
    );
  }
}

class ShopliveShortformUrlData {
  final String url;

  ShopliveShortformUrlData({required this.url});

  factory ShopliveShortformUrlData.fromJson(Map<String, dynamic> json) {
    return ShopliveShortformUrlData(
      url: json['url'],
    );
  }
}

class ShopLiveShortformShareData {
  String? shortsId;
  String? srn;
  String? title;
  String? description;
  String? thumbnail;

  ShopLiveShortformShareData({
    this.shortsId,
    this.srn,
    this.title,
    this.description,
    this.thumbnail,
  });

  factory ShopLiveShortformShareData.fromJson(Map<String, dynamic> json) {
    return ShopLiveShortformShareData(
      shortsId: json['shortsId'],
      srn: json['srn'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
    );
  }
}

class ShopliveShortformLogData {
  final String command;
  String? payload;

  ShopliveShortformLogData({
    required this.command,
    this.payload,
  });

  factory ShopliveShortformLogData.fromJson(Map<String, dynamic> json) {
    return ShopliveShortformLogData(
      command: json['command'] ?? "",
      payload: json['payload'],
    );
  }
}

class ShopLiveShortformCollectionData {
  String? shortsId;
  String? shortsSrn;
  List<String>? tags;
  ShopLiveShortformTagSearchOperator? tagSearchOperator;
  List<String>? brands;
  bool shuffle = false;
  String? referrer;

  ShopLiveShortformCollectionData({
    this.shortsId,
    this.shortsSrn,
    this.tags,
    this.tagSearchOperator,
    this.brands,
    this.shuffle = false,
    this.referrer,
  });

  factory ShopLiveShortformCollectionData.fromJson(Map<String, dynamic> json) {
    return ShopLiveShortformCollectionData(
      shortsId: json['shortsId'],
      shortsSrn: json['shortsSrn'],
      tags: json['shortsSrn'],
      tagSearchOperator: json['shortsSrn'] == "OR"
          ? ShopLiveShortformTagSearchOperator.OR
          : ShopLiveShortformTagSearchOperator.AND,
      brands: json['brands'],
      shuffle: json['shuffle'],
      referrer: json['referrer'],
    );
  }
}

enum ShopLiveShortformTagSearchOperator { OR, AND }

extension ShopLiveShortformTagSearchOperatorExtension
    on ShopLiveShortformTagSearchOperator {
  String text() {
    var text = "";
    switch (this) {
      case ShopLiveShortformTagSearchOperator.OR:
        text = "OR";
        break;
      case ShopLiveShortformTagSearchOperator.AND:
        text = "AND";
        break;
      default:
        text = "AND";
        break;
    }
    return text;
  }
}
