// shoplive_core의 패키지 내부용 브릿지 헬퍼(고객 비보장 — pair #25).
export 'package:shoplive_core/shoplive_core_bridge.dart' show toWire, parseWireEnum;

/// 네이티브 Map 읽기 헬퍼. 형식이 다르면 null(파서가 unknown으로 폴백).
Map<String, Object?>? asStringMap(Object? raw) {
  if (raw is! Map) return null;
  final out = <String, Object?>{};
  for (final e in raw.entries) {
    final k = e.key;
    if (k is! String) return null;
    out[k] = e.value;
  }
  return out;
}

T? asType<T>(Object? v) => v is T ? v : null;

/// null 필드를 키 생략으로(키 부재 = 기본값/현재 값 유지, design §2.2).
void putIfNotNull(Map<String, Object?> m, String key, Object? value) {
  if (value != null) m[key] = value;
}
