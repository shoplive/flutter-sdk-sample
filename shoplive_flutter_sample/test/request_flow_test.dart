import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shoplive_player/shoplive_player.dart';

class _FakePlatform extends ShoplivePlayerPlatform with MockPlatformInterfaceMixin {
  final invocations = <List<Object?>>[];
  int requestListens = 0;
  int requestCancels = 0;
  StreamController<Object?>? requestController;
  final eventController = StreamController<Object?>.broadcast();
  Object? Function(String method, Map<String, Object?>? args)? reply;

  @override
  Future<T?> invokeMethod<T>(String method, [Map<String, Object?>? arguments]) async {
    invocations.add([method, arguments]);
    return reply?.call(method, arguments) as T?;
  }

  @override
  Stream<Object?> events() => eventController.stream;

  @override
  Stream<Object?> requests() {
    final c = StreamController<Object?>(onListen: () => requestListens++, onCancel: () => requestCancels++);
    requestController = c;
    return c.stream;
  }

  void push(Object? raw) => requestController!.add(raw);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakePlatform fake;
  late ShoplivePlayer player;

  setUp(() {
    fake = _FakePlatform();
    ShoplivePlayerPlatform.instance = fake;
    player = ShoplivePlayer.createForTesting();
  });

  // case: R-01
  test('no request listener at all → native requests not subscribed', () async {
    await _settle();
    expect(fake.requestListens, 0);
  });

  // case: N-04, N-06
  test('coupon with listener is delivered; respond sends contract args and returns bool', () async {
    fake.reply = (m, a) => m == 'respondCoupon' ? true : null;
    final got = <ShopliveCouponRequest>[];
    final sub = player.couponRequests.listen(got.add);
    fake.push({'type': 'coupon', 'requestId': 'r1', 'couponId': 'c1'});
    await _settle();
    expect(got.single.couponId, 'c1');
    final ok = await got.single.respond(const ShopliveCouponResult(success: true, status: ShopliveResultStatus.hide, message: 'ok'));
    expect(ok, isTrue);
    expect(fake.invocations.last, ['respondCoupon', {'requestId': 'r1', 'success': true, 'status': 'hide', 'message': 'ok'}]);
    await sub.cancel();
  });

  // case: T-06
  test('respond returning null/false → false', () async {
    final got = <ShopliveCustomWebActionRequest>[];
    final sub = player.customWebActionRequests.listen(got.add);
    fake.push({'type': 'customWebAction', 'requestId': 'r2', 'id': 'a', 'actionType': 't', 'payload': {'k': 1}});
    await _settle();
    expect(got.single.payload, {'k': 1});
    expect(await got.single.respond(const ShopliveCustomActionResult(success: false, status: ShopliveResultStatus.keep, alertType: ShopliveResultAlertType.toast)), isFalse);
    expect(fake.invocations.last, ['respondCustomAction', {'requestId': 'r2', 'success': false, 'status': 'keep', 'alertType': 'toast'}]);
    await sub.cancel();
  });

  // case: N-04
  test('typed listener missing → respondFallback immediately (§2.7-4)', () async {
    final nav = <ShopliveNavigationRequest>[];
    final sub = player.navigationRequests.listen(nav.add);
    fake.push({'type': 'coupon', 'requestId': 'r3', 'couponId': 'c'});
    fake.push({'type': 'customWebAction', 'requestId': 'r4', 'id': 'a', 'actionType': 't'});
    fake.push({'type': 'navigation', 'url': 'u'});
    await _settle();
    expect(fake.invocations, [
      ['respondFallback', {'requestId': 'r3'}],
      ['respondFallback', {'requestId': 'r4'}],
    ]);
    expect(nav.single.url, 'u');
    await sub.cancel();
  });

  // case: N-04
  test('malformed coupon with requestId → fallback; without requestId → dropped', () async {
    final sub = player.couponRequests.listen((_) {});
    fake.push({'type': 'coupon', 'requestId': 'r5'});
    fake.push({'type': 'coupon', 'couponId': 'c'});
    fake.push('garbage');
    await _settle();
    expect(fake.invocations, [
      ['respondFallback', {'requestId': 'r5'}],
    ]);
    await sub.cancel();
  });

  // case: T-07
  test('R2-m2: cancel then re-listen before timer → native listen 1, cancel 0, no fallback', () async {
    final sub1 = player.couponRequests.listen((_) {});
    await _settle();
    expect(fake.requestListens, 1);
    await sub1.cancel();
    final sub2 = player.couponRequests.listen((_) {});
    await _settle();
    expect(fake.requestListens, 1);
    expect(fake.requestCancels, 0);
    expect(fake.invocations.where((i) => i[0] == 'respondFallback'), isEmpty);
    await sub2.cancel();
  });

  // case: T-07, R-02
  test('all listeners gone → native cancelled after Timer(Duration.zero)', () async {
    final a = player.couponRequests.listen((_) {});
    final b = player.navigationRequests.listen((_) {});
    await a.cancel();
    await _settle();
    expect(fake.requestCancels, 0);
    await b.cancel();
    expect(fake.requestCancels, 0);
    await _settle();
    expect(fake.requestCancels, 1);
  });

  // case: N-03
  test('events stream maps wire to typed events', () async {
    final got = <ShoplivePlayerEvent>[];
    final sub = player.events.listen(got.add);
    fake.eventController.add({'type': 'stateChanged', 'state': 'loading'});
    fake.eventController.add({'type': 'weird'});
    await _settle();
    expect(got[0], isA<ShoplivePlayerStateChanged>());
    expect(got[1], isA<ShoplivePlayerUnknownEvent>());
    await sub.cancel();
  });

  // case: B-08
  test('setRequestTimeout forwards ms; validation is native (INVALID_ARGUMENT, 규칙 #6)', () async {
    await player.setRequestTimeout(Duration.zero);
    expect(fake.invocations.single, ['setRequestTimeout', {'timeoutMs': 0}]);
  });

  // case: T-07 (pair #22) — 사용자 리스너가 동기 throw → 즉시 폴백 + 예외는 리스너 Zone으로
  test('listener throws synchronously → respondFallback, error goes to listener zone', () async {
    final zoneErrors = <Object>[];
    late StreamSubscription<ShopliveCouponRequest> sub;
    runZonedGuarded(() {
      sub = player.couponRequests.listen((_) => throw StateError('app bug'));
    }, (e, _) => zoneErrors.add(e));
    fake.push({'type': 'coupon', 'requestId': 'r9', 'couponId': 'c'});
    await _settle();
    expect(fake.invocations, [
      ['respondFallback', {'requestId': 'r9'}],
    ]);
    expect(zoneErrors.single, isA<StateError>());
    await sub.cancel();
  });

  // case: T-06 — 다중 리스너: 같은 요청이 각 리스너에 전달, 첫 respond만 true(네이티브 판정)
  test('multiple listeners receive the same request; only first respond is true', () async {
    var replies = 0;
    fake.reply = (m, a) => m == 'respondCoupon' ? (++replies == 1) : null;
    final got = <ShopliveCouponRequest>[];
    final a = player.couponRequests.listen(got.add);
    final b = player.couponRequests.listen(got.add);
    fake.push({'type': 'coupon', 'requestId': 'r10', 'couponId': 'c'});
    await _settle();
    expect(got.length, 2);
    const result = ShopliveCouponResult(success: true, status: ShopliveResultStatus.keep);
    expect(await got[0].respond(result), isTrue);
    expect(await got[1].respond(result), isFalse);
    await a.cancel();
    await b.cancel();
  });
}
