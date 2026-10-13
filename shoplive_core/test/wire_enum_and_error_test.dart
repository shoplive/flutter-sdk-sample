import 'package:flutter_test/flutter_test.dart';
import 'package:shoplive_core/shoplive_core.dart';
import 'package:shoplive_core/src/wire_enum.dart';

enum _Sample { alpha, betaGamma, unknown }

void main() {
  group('wire enum 헬퍼 (design §2.3, B-02)', () {
    // case: B-01
    test('toWire uses Dart camelCase name', () {
      expect(toWire(_Sample.betaGamma), 'betaGamma');
      expect(toWire(ShopliveGender.undefined), 'undefined');
    });

    // case: B-02
    test('known value parses', () {
      expect(parseWireEnum(_Sample.values, 'alpha', unknown: _Sample.unknown), _Sample.alpha);
    });

    // case: B-02
    test('unknown / wrong-case / non-string / null fall back to unknown', () {
      for (final raw in <Object?>['ALPHA', 'delta', 3, null]) {
        expect(parseWireEnum(_Sample.values, raw, unknown: _Sample.unknown), _Sample.unknown, reason: '$raw');
      }
    });

    // case: B-01
    test('gender wire values match native table', () {
      expect(ShopliveGender.values.map(toWire), ['male', 'female', 'neutral', 'undefined']);
    });
  });

  group('ShopliveError.tryParse (design §2.5 error payload)', () {
    // case: N-03
    test('player-style error (rawCode nullable, message non-null)', () {
      final e = ShopliveError.tryParse({'code': 'CONNECTION_ISSUE', 'message': 'm', 'rawCode': null, 'recoverable': true})!;
      expect(e.code, 'CONNECTION_ISSUE');
      expect(e.message, 'm');
      expect(e.rawCode, isNull);
      expect(e.recoverable, isTrue);
    });

    // case: N-05
    test('streamer-style error (message nullable, rawCode int)', () {
      final e = ShopliveError.tryParse({'code': 'UNKNOWN', 'message': null, 'rawCode': 9, 'recoverable': false})!;
      expect(e.message, isNull);
      expect(e.rawCode, 9);
      expect(e.recoverable, isFalse);
    });

    // case: B-02
    test('malformed payload returns null (no throw)', () {
      expect(ShopliveError.tryParse({'recoverable': true}), isNull);
      expect(ShopliveError.tryParse({'code': 'X'}), isNull);
      expect(ShopliveError.tryParse('x'), isNull);
      expect(ShopliveError.tryParse(null), isNull);
    });
  });
}
