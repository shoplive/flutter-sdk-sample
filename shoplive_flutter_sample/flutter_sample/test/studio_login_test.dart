import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shoplive_player_example/studio_login.dart';

class FakeTransport implements StudioTransport {
  FakeTransport(this.response);

  final StudioResponse response;
  Uri? uri;
  String? body;
  Map<String, String>? headers;
  int calls = 0;

  @override
  Future<StudioResponse> post(Uri uri, String body, Map<String, String> headers) async {
    calls++;
    this.uri = uri;
    this.body = body;
    this.headers = headers;
    return response;
  }
}

void main() {
  // case: STUDIO-LOGIN — 네이티브 데모(ShopLiveNetworkStreamerService.login)와 같은 요청·응답 계약.
  test('posts form-urlencoded credentials to the production studio login and returns accessToken', () async {
    final t = FakeTransport(const StudioResponse(200, '{"accessToken":"jwt-value"}'));
    final jwt =
        await StudioLogin(transport: t).login(id: ' user ', password: 'p&w=1', headers: {'x-sl-studio-os-type': 'a'});

    expect(jwt, 'jwt-value');
    expect(t.uri.toString(), 'https://private.shopliveapi.com/studio/v2/administrator/login');
    expect(Uri.splitQueryString(t.body!),
        {'id': 'user', 'password': 'p&w=1', 'source': 'STREAM_APP', 'duration': '10000'});
    expect(t.headers!['Content-Type'], startsWith('application/x-www-form-urlencoded'));
    expect(t.headers!['x-sl-studio-os-type'], 'a');
  });

  test('error response surfaces _e / message and the HTTP status', () async {
    final t = FakeTransport(const StudioResponse(401, '{"_s":401,"_e":"Invalid password"}'));
    expect(
      () => StudioLogin(transport: t).login(id: 'u', password: 'p'),
      throwsA(isA<StudioLoginException>()
          .having((e) => e.statusCode, 'statusCode', 401)
          .having((e) => e.message, 'message', 'Invalid password')),
    );
  });

  test('2xx without accessToken is a failure', () async {
    final t = FakeTransport(const StudioResponse(200, '{}'));
    expect(() => StudioLogin(transport: t).login(id: 'u', password: 'p'), throwsA(isA<StudioLoginException>()));
  });

  test('blank id or password fails without a request', () async {
    final t = FakeTransport(const StudioResponse(200, '{"accessToken":"x"}'));
    await expectLater(
        () => StudioLogin(transport: t).login(id: ' ', password: 'p'), throwsA(isA<StudioLoginException>()));
    await expectLater(
        () => StudioLogin(transport: t).login(id: 'u', password: ''), throwsA(isA<StudioLoginException>()));
    expect(t.calls, 0);
  });

  test('network failures and timeouts become StudioLoginException', () async {
    for (final error in <Object>[
      const SocketException('down'),
      TimeoutException('slow'),
      const HandshakeException('tls')
    ]) {
      expect(() => StudioLogin(transport: _ThrowingTransport(error)).login(id: 'u', password: 'p'),
          throwsA(isA<StudioLoginException>()));
    }
  });
}

class _ThrowingTransport implements StudioTransport {
  _ThrowingTransport(this.error);

  final Object error;

  @override
  Future<StudioResponse> post(Uri uri, String body, Map<String, String> headers) => Future.error(error);
}
