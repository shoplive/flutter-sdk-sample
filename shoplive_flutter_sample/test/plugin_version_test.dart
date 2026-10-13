import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shoplive_player/shoplive_player.dart';

void main() {
  test('pluginVersion matches pubspec.yaml version', () async {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec)!.group(1);

    expect(ShoplivePlayer.pluginVersion, version);
    expect(await ShoplivePlayer.instance.getPluginVersion(), version);
  });
}
