import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shoplive_player_example/main.dart';

void main() {
  // case: CS-02
  testWidgets('sample page renders quick-start buttons and advanced sections without platform',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text(ShopliveSamplePage.title), findsOneWidget);
    expect(find.text('LivePlayer PLAY'), findsOneWidget);
    expect(find.text('LivePreview PLAY'), findsOneWidget);

    // 입력칸에는 1.x 샘플 기본 키가 채워져 있다.
    expect(find.widgetWithText(TextField, 'Access key'), findsOneWidget);
    expect(find.text('2551fcb165c3'), findsOneWidget);

    // 키를 지우고 누르면 플랫폼 호출 없이 안내만 한다(1.x example과 같은 검증).
    await tester.enterText(find.widgetWithText(TextField, 'Access key'), '');
    await tester.tap(find.text('LivePlayer PLAY'));
    await tester.pump();
    expect(find.text('Required to accessKey'), findsOneWidget);

    // 스낵바가 사라진 뒤 고급 제어를 펼친다(스낵바가 하단 탭을 가리지 않도록).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    final advanced = find.byType(ExpansionTile);
    await tester.scrollUntilVisible(advanced, 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(advanced);
    await tester.pumpAndSettle();
    expect(find.text('Core'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Streamer'), 200, scrollable: scrollable);
    expect(find.text('Streamer'), findsOneWidget);

    // dispose → 요청 리스너 해제 → 지연 cancel 타이머(Timer.zero, X-10)를 소진
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  // case: CS-01 — 빠른 실행은 실패한 단계에서 멈춘다(교차검증 EQ-M1).
  testWidgets('LivePlayer PLAY stops before setUser/start when initialize fails', (WidgetTester tester) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    final coreCalls = <String>[];
    final playerCalls = <String>[];
    messenger.setMockMethodCallHandler(const MethodChannel('shoplive_core'), (call) async {
      coreCalls.add(call.method);
      if (call.method == 'initialize') throw PlatformException(code: 'INVALID_ARGUMENT');
      return null;
    });
    messenger.setMockMethodCallHandler(const MethodChannel('shoplive_player'), (call) async {
      playerCalls.add(call.method);
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(const MethodChannel('shoplive_core'), null);
      messenger.setMockMethodCallHandler(const MethodChannel('shoplive_player'), null);
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Access key'), 'bad key');
    await tester.enterText(find.widgetWithText(TextField, 'Campaign key'), 'campaign');
    await tester.tap(find.text('LivePlayer PLAY'));
    await tester.pumpAndSettle();

    expect(coreCalls, ['initialize']);
    expect(playerCalls, isNot(contains('start')));
    expect(find.text('initialize 실패: INVALID_ARGUMENT'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  // case: C-6 — 스트리머는 방송자 토큰을 설정한 뒤에만 송출을 시작한다(토큰 없으면 SDK가 송출 실패 팝업).
  testWidgets('Streamer START sets the stream token before starting, and requires it', (WidgetTester tester) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    final calls = <String>[];
    for (final ch in ['shoplive_core', 'shoplive_streamer']) {
      messenger.setMockMethodCallHandler(MethodChannel(ch), (call) async {
        calls.add('$ch.${call.method}');
        return null;
      });
    }
    addTearDown(() {
      for (final ch in ['shoplive_core', 'shoplive_streamer']) {
        messenger.setMockMethodCallHandler(MethodChannel(ch), null);
      }
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    final scrollable = find.byType(Scrollable).first;
    final start = find.text('Streamer START');
    await tester.scrollUntilVisible(start, 200, scrollable: scrollable);
    await tester.enterText(find.widgetWithText(TextField, 'Broadcast campaign key'), 'broadcast');

    await tester.ensureVisible(start);
    await tester.pumpAndSettle();
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.text('Required to stream token'), findsOneWidget);
    expect(calls, isEmpty);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Stream token (broadcaster)'), 'token');
    await tester.ensureVisible(start);
    await tester.pumpAndSettle();
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(calls, ['shoplive_core.initialize', 'shoplive_core.setStreamToken', 'shoplive_streamer.start']);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
