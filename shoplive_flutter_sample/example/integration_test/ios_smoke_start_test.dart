// Smoke: launch the sample app and tap "LivePlayer PLAY" (example default keys); the player view controller should
// appear and the app must not crash. A host script takes the simulator screenshot after "SMOKE_STARTED" is printed.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shoplive_player/shoplive_player.dart';
import 'package:shoplive_player_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LivePlayer PLAY presents the player without crashing', (tester) async {
    final events = <ShoplivePlayerEvent>[];
    final sub = ShoplivePlayer.instance.events.listen(events.add);
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text('LivePlayer PLAY'));
    await tester.pump(const Duration(seconds: 2));
    debugPrint('SMOKE_STARTED');
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    final running = await ShoplivePlayer.instance.isRunning();
    final state = await ShoplivePlayer.instance.getState();
    debugPrint('SMOKE_RESULT running=$running state=${state.name} events=${events.map((e) => e.runtimeType).toSet()}');
    expect(running, isTrue);
    await ShoplivePlayer.instance.close();
    await tester.pump(const Duration(seconds: 2));
    await sub.cancel();
  });
}
