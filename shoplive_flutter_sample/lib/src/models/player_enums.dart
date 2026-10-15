/// player wire enum(design.md rev2 §2.3). 네이티브에서 받는 값이 미지이면 `unknown`(B-02).
/// `unknown`을 네이티브로 보내면 INVALID_ARGUMENT가 된다.
library;

enum ShoplivePlayerState { idle, loading, playing, paused, inAppPip, closed, unknown }

enum ShopliveCampaignStatus { ready, live, ended, unknown }

enum ShopliveConnectionState { connecting, connected, reconnecting, disconnected, unknown }

enum ShopliveResizeMode { fill, fit, unknown }

enum ShopliveOverlayUIMode { builtIn, hidden, unknown }

enum ShoplivePresentationStyle { fullscreen, pip }

enum ShoplivePlayerType { live, preview, unknown }

enum ShoplivePipPosition {
  topLeft,
  topCenter,
  topRight,
  middleLeft,
  middleCenter,
  middleRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  unknown,
}

enum ShoplivePipRatio { ratio1x1, ratio1x2, ratio2x3, ratio3x4, ratio9x16, unknown }

enum ShopliveNavigationAction { pip, keep, close, unknown }

enum ShopliveResultStatus { show, hide, keep }

enum ShopliveResultAlertType { alert, toast }

enum ShoplivePlaybackEventKind {
  requested,
  started,
  audioLoaded,
  rendering,
  buffering,
  rebufferingStarted,
  rebufferingEnded,
  ended,
  failed,
  unknown,
}
