import 'dart:convert';

import 'package:flutter/services.dart';

import 'shoplive_streamer_platform_interface.dart';

const String EVENT_STREAMER_ERROR = "event_streamer_error";

class ShopLiveStreamer {
  late final Stream<ShopLiveStreamerError> error =
      const EventChannel(EVENT_STREAMER_ERROR)
          .receiveBroadcastStream()
          .map((jsonString) => const JsonDecoder().convert(jsonString))
          .map((json) => ShopLiveStreamerError.fromJson(json));

  void play() {
    return ShopliveStreamerPlatform.instance.play();
  }
}

class ShopLiveStreamerError {
  final String code;
  String? message;

  ShopLiveStreamerError({required this.code, required this.message});

  factory ShopLiveStreamerError.fromJson(Map<String, dynamic> json) {
    return ShopLiveStreamerError(
      code: json['code'],
      message: json['message'],
    );
  }
}