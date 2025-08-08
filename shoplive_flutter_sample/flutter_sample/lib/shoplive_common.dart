import 'shoplive_common_platform_interface.dart';

class ShopLiveCommon {
  void setAuth({
    required ShopLiveCommonAuth data,
  }) {
    return ShopliveCommonPlatform.instance.setAuth(data: data);
  }

  void setAuthToken({
    required String? userJWT,
  }) {
    return ShopliveCommonPlatform.instance.setAuthToken(userJWT: userJWT);
  }

  void setUser({
    required String accessKey,
    required ShopLiveCommonUser user,
  }) {
    return ShopliveCommonPlatform.instance
        .setUser(accessKey: accessKey, user: user);
  }

  void setUtmSource({
    required String? utmSource,
  }) {
    return ShopliveCommonPlatform.instance.setUtmSource(utmSource: utmSource);
  }

  void setUtmMedium({
    required String? utmMedium,
  }) {
    return ShopliveCommonPlatform.instance.setUtmMedium(utmMedium: utmMedium);
  }

  void setUtmCampaign({
    required String? utmCampaign,
  }) {
    return ShopliveCommonPlatform.instance
        .setUtmCampaign(utmCampaign: utmCampaign);
  }

  void setUtmContent({
    required String? utmContent,
  }) async {
    return ShopliveCommonPlatform.instance
        .setUtmContent(utmContent: utmContent);
  }

  void setAccessKey({
    required String? accessKey,
  }) async {
    return ShopliveCommonPlatform.instance.setAccessKey(accessKey: accessKey);
  }

  void clearAuth() async {
    return ShopliveCommonPlatform.instance.clearAuth();
  }
}

class ShopLiveCommonAuth {
  String? userJWT;
  String? guestUid;
  String? accessKey;
  String? utmSource;
  String? utmMedium;
  String? utmCampaign;
  String? utmContent;

  ShopLiveCommonAuth({
    this.userJWT,
    this.guestUid,
    this.accessKey,
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'userJWT': userJWT,
      'guestUid': guestUid,
      'accessKey': accessKey,
      'utmSource': utmSource,
      'utmMedium': utmMedium,
      'utmCampaign': utmCampaign,
      'utmContent': utmContent,
    };
  }
}

class ShopLiveCommonUser {
  final String userId;
  String? userName;
  int? age;
  ShopLiveCommonUserGender? gender;
  int? userScore;
  Map<String, dynamic>? custom; // Dart uses dynamic for Any type

  ShopLiveCommonUser({
    required this.userId,
    this.userName,
    this.age,
    this.gender,
    this.userScore,
    this.custom,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'age': age,
      'gender': gender?.parseText(),
      'userScore': userScore,
      'custom': custom,
    };
  }
}

enum ShopLiveCommonUserGender { MALE, FEMALE, NEUTRAL }

extension ShopLiveCommonUserGenderExtension on ShopLiveCommonUserGender {
  String parseText() {
    var text = "";
    switch (this) {
      case ShopLiveCommonUserGender.MALE:
        text = "m";
        break;
      case ShopLiveCommonUserGender.FEMALE:
        text = "f";
        break;
      default:
        text = "n";
        break;
    }
    return text;
  }
}
