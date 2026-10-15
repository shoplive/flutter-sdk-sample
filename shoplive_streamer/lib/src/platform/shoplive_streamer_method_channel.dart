import 'package:flutter/services.dart';

import 'shoplive_streamer_platform_interface.dart';

/// 채널·메서드 이름(계약 단일 출처 — Kotlin StreamerContract와 같은 목록).
abstract final class ShopliveStreamerContract {
  static const String methodChannel = 'shoplive_streamer';
  static const String eventsChannel = 'shoplive_streamer/events';
  static const String start = 'start';
  static const String getState = 'getState';
  static const List<String> methods = [start, getState];
}

class MethodChannelShopliveStreamer extends ShopliveStreamerPlatform {
  final MethodChannel _methods = const MethodChannel(ShopliveStreamerContract.methodChannel);
  final EventChannel _events = const EventChannel(ShopliveStreamerContract.eventsChannel);

  @override
  Future<T?> invokeMethod<T>(String method, [Map<String, Object?>? arguments]) => _methods.invokeMethod<T>(method, arguments);

  @override
  Stream<Object?> events() => _events.receiveBroadcastStream();
}
