// Host screen lookup for presenting SDK view controllers (design section 3).
// Keep in sync: identical copies in shoplive_player and shoplive_streamer.
import UIKit

protocol HostScreenProviding: AnyObject {
    /// Top-most presentable view controller of the foreground key window, or nil (-> NO_HOST_SCREEN).
    func topViewController() -> UIViewController?
}

final class KeyWindowHostScreen: HostScreenProviding {
    func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
        for scene in scenes {
            let window = scene.windows.first { $0.isKeyWindow } ?? scene.windows.first
            guard var top = window?.rootViewController else { continue }
            while let presented = top.presentedViewController, !presented.isBeingDismissed {
                top = presented
            }
            return top
        }
        return nil
    }
}

/// Presents `controller` from the current top view controller. Synchronous verdict (D-8): true when the
/// presentation started (or is deferred behind a running transition), false when there is no host screen.
func presentOnHostScreen(_ controller: UIViewController, host: HostScreenProviding, style: UIModalPresentationStyle) -> Bool {
    guard let top = host.topViewController() else { return false }
    controller.modalPresentationStyle = style
    if let coordinator = top.transitionCoordinator {
        // A presentation/dismissal is running; present after it finishes (IOS-M1).
        // TODO(SDP-VERIFY): 요확인 - 지연 present 경로는 success를 먼저 반환하므로 이후 present 실패가 Dart에 전달되지 않음(IM-m3, 구조 유지) · 근거 DRAFT-flutter-sdk-302-ios/I-S-02 · 자동 통과 금지(실측)
        coordinator.animate(alongsideTransition: nil) { _ in
            (host.topViewController() ?? top).present(controller, animated: true)
        }
        return true
    }
    top.present(controller, animated: true)
    return controller.presentingViewController != nil
}
