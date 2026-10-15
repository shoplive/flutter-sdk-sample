import 'package:meta/meta.dart';
/// `Shoplive.initialize` 설정(design.md rev2 §2.4·§2.6). null 필드는 키를 생략해 SDK 기본값을 쓴다.
class ShopliveConfiguration {
  const ShopliveConfiguration({required this.accessKey, this.allowedWebViewDomains, this.attribution, this.appVersion});

  final String accessKey;

  /// 생략(null) 시 SDK 기본값(빈 리스트).
  final List<String>? allowedWebViewDomains;
  final ShopliveAttribution? attribution;
  final String? appVersion;

  @internal
  Map<String, Object?> toWire() => {
        'accessKey': accessKey,
        if (allowedWebViewDomains != null) 'allowedWebViewDomains': allowedWebViewDomains,
        if (attribution != null) 'attribution': attribution!.toWire(),
        if (appVersion != null) 'appVersion': appVersion,
      };
}

class ShopliveAttribution {
  const ShopliveAttribution({this.utmSource, this.utmMedium, this.utmCampaign, this.utmContent});

  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmContent;

  @internal
  Map<String, Object?> toWire() => {
        if (utmSource != null) 'utmSource': utmSource,
        if (utmMedium != null) 'utmMedium': utmMedium,
        if (utmCampaign != null) 'utmCampaign': utmCampaign,
        if (utmContent != null) 'utmContent': utmContent,
      };
}
