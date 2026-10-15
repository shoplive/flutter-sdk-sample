import Foundation
import UIKit
import ShoplivePlayerSDK

/// Thin subclass to observe dismissal (I-R-02). ShoplivePlayerViewController is an open class.
final class BridgedPlayerViewController: ShoplivePlayerViewController {
    var onDismissed: (() -> Void)?

    override init(campaignKey: String, options: ShoplivePlayOptions, configuration: ShoplivePlayerConfiguration) {
        super.init(campaignKey: campaignKey, options: options, configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || presentingViewController == nil { onDismissed?() }
    }
}

/// Channel `shoplive_player` methods (Android design section 2.4, iOS design section 2.2).
/// The iOS SDK has no off-screen player: `start` creates a ShoplivePlayerViewController and presents it (I1).
/// Instances are created only by `start`; without one, queries return defaults/saved settings and setters only store.
/// Main thread only (MethodChannel).
final class PlayerMethodHandler {
    private static let tag = "ShoplivePlayer"

    private let registry: PendingRequests<PendingRequest>
    private let hostScreen: HostScreenProviding
    private let makeDelegate: (PlayerMethodHandler) -> ShoplivePlayerDelegate

    private var controller: BridgedPlayerViewController?
    /// The SDK holds the delegate weakly (Player:305/347) - keep it alive here (I-L-01).
    private var liveDelegate: ShoplivePlayerDelegate?

    // Last confirmed settings, carried to every new controller (R2-N1).
    private var savedConfiguration: ShoplivePlayerConfiguration?
    private var savedType = PlayerMapper.defaultType
    private var savedResizeMode: ShopliveResizeMode?
    private var savedOverlayUI: ShopliveOverlayUIMode?

    init(registry: PendingRequests<PendingRequest>, hostScreen: HostScreenProviding,
         makeDelegate: @escaping (PlayerMethodHandler) -> ShoplivePlayerDelegate) {
        self.registry = registry
        self.hostScreen = hostScreen
        self.makeDelegate = makeDelegate
    }

    func handle(_ method: String, _ args: Args) throws -> Any? {
        switch method {
        case "start": return try start(args)
        case "play":
            let key = try args.requireString("campaignKey")
            let options = try PlayerMapper.toPlayOptions(try args.optArgs("playOptions"))
            try running().play(campaignKey: key, options: options)
        case "stop": try running().stop()
        case "close": controller?.close() // no instance -> idempotent no-op
        case "reload": try running().reload()
        case "send":
            let command = try args.requireString("command")
            let payload = try args.optStringKeyMap("payload") ?? [:]
            try running().send(command: command, payload: payload)
        case "setMuted":
            let muted = try args.requireBool("muted")
            let c = try running()
            c.isMuted = muted
        case "isMuted": return controller?.isMuted ?? false
        case "setResizeMode":
            let mode = try args.requireWireEnum("mode", PlayerMapper.resizeMode)
            controller?.resizeMode = mode
            savedResizeMode = mode
        case "getResizeMode":
            return wireOf(controller?.resizeMode ?? savedResizeMode ?? currentConfiguration().appearance.resizeMode, PlayerMapper.resizeMode)
        case "setOverlayUI":
            let mode = try args.requireWireEnum("mode", PlayerMapper.overlayUI)
            controller?.overlayUI = mode
            savedOverlayUI = mode
        case "getOverlayUI":
            return wireOf(controller?.overlayUI ?? savedOverlayUI ?? currentConfiguration().overlay.ui, PlayerMapper.overlayUI)
        case "enterPictureInPicture": try running().enterPictureInPicture()
        case "exitPictureInPicture": try running().exitPictureInPicture()
        case "isInPictureInPicture": return controller?.isInPictureInPicture ?? false
        case "getState": return wireOf(controller?.state ?? .idle, PlayerMapper.playerState)
        case "getCurrentCampaign": return PlayerMapper.campaignToWire(controller?.currentCampaign)
        case "isRunning": return isRunning
        case "setConfiguration":
            let (merged, type) = try PlayerMapper.mergeConfiguration(currentConfiguration(), currentType: savedType,
                                                                      partial: try args.requireArgs("configuration"))
            controller?.configuration = merged
            savedConfiguration = merged
            savedType = type
        case "getConfiguration":
            return PlayerMapper.configurationToWire(controller?.configuration ?? currentConfiguration(), type: savedType)
        case "setRequestTimeout":
            guard let ms = try args.optInt("timeoutMs") else {
                throw BridgeArgumentError(key: "timeoutMs", expected: "Int", actual: "missing")
            }
            try registry.setTimeoutMs(ms)
        case "respondCoupon": return try respondCoupon(args)
        case "respondCustomAction": return try respondCustomAction(args)
        case "respondFallback":
            guard let pending = registry.take(try args.requireString("requestId")) else { return false }
            pending.respondFallback()
            return true
        default:
            throw BridgeNotImplemented()
        }
        return nil
    }

    // MARK: start (pre-validation order as on Android; IOS-M1 reuse)

    private func start(_ args: Args) throws -> Any? {
        let campaignKey = try args.requireString("campaignKey")
        let options = try PlayerMapper.toPlayOptions(try args.optArgs("playOptions"))
        let partial = try args.optArgs("configuration")
        var effective = currentConfiguration()
        var type = savedType
        if let partial = partial {
            (effective, type) = try PlayerMapper.mergeConfiguration(effective, currentType: savedType, partial: partial)
        }
        if options.presentationStyle == .pip && !effective.pip.isInAppPipEnabled {
            // B-09: reject before creating anything.
            throw BridgeArgumentError(key: "playOptions.presentationStyle", expected: "fullscreen unless pip.isInAppPipEnabled", actual: "pip")
        }
        if let current = controller, current.state != .closed, !current.isBeingDismissed {
            // IOS-M1: an existing session (fullscreen or in-app PIP) switches campaigns instead of stacking a second player.
            // TODO(SDP-VERIFY): 요확인 - 실행 중 configuration 변경이 즉시 반영되는 범위 · 근거 DRAFT-flutter-sdk-302-ios/I-S-01 · 자동 통과 금지(실측)
            if partial != nil {
                current.configuration = effective
                savedConfiguration = effective
                savedType = type
            }
            current.play(campaignKey: campaignKey, options: options)
            return nil
        }
        if let previous = controller {
            // IM-m2: a closed or dismissing controller is closed and detached before the next one is presented.
            if previous.state != .closed { previous.close() }
            release(previous)
            controller = nil
        }
        var configuration = effective
        if let mode = savedResizeMode { configuration.appearance.resizeMode = mode }
        if let ui = savedOverlayUI { configuration.overlay.ui = ui }
        let next = BridgedPlayerViewController(campaignKey: campaignKey, options: options, configuration: configuration)
        let delegate = makeDelegate(self)
        next.delegate = delegate
        next.onDismissed = { [weak self, weak next] in
            guard let self = self, let next = next else { return }
            self.controllerDidDismiss(next)
        }
        // D-9: overFullScreen keeps the Flutter screen underneath (in-app PIP).
        // TODO(SDP-VERIFY): 요확인 - PIP 중 아래 Flutter 화면 터치 가능 여부, .overFullScreen 적합성 · 근거 DRAFT-flutter-sdk-302-ios/D-9 · 자동 통과 금지(실측)
        guard presentOnHostScreen(next, host: hostScreen, style: .overFullScreen) else {
            next.delegate = DetachedPlayerDelegate.shared
            throw BridgeStateError(code: BridgeErrorCode.noHostScreen, message: "no host screen (view controller) to present the player")
        }
        controller = next
        liveDelegate = delegate
        if partial != nil {
            savedConfiguration = effective
            savedType = type
        }
        return nil
    }

    // MARK: lifecycle

    /// D-7: no SDK isRunning - a held controller whose state is not closed.
    private var isRunning: Bool {
        guard let c = controller else { return false }
        // TODO(SDP-VERIFY): 요확인 - closed 이후 VC가 스스로 dismiss 되는지, in-app PIP 중 VC 상태 · 근거 DRAFT-flutter-sdk-302-ios/D-7 · 자동 통과 금지(실측)
        return c.state != .closed
    }

    private func running() throws -> BridgedPlayerViewController {
        guard let c = controller, isRunning else {
            throw BridgeStateError(code: BridgeErrorCode.notRunning, message: "player is not running")
        }
        return c
    }

    /// stateChanged(.closed) from the SDK: release the controller, dismissing it if it is still on screen.
    func playerDidClose(_ player: any ShoplivePlayerControlling) {
        guard let c = controller, c === player as AnyObject else { return }
        if c.presentingViewController != nil, !c.isBeingDismissed { c.dismiss(animated: true) }
        release(c)
        controller = nil
    }

    private func controllerDidDismiss(_ dismissed: BridgedPlayerViewController) {
        // Dismissed without a closed state may be the SDK moving to in-app PIP - keep it then (I-R-02).
        guard dismissed === controller, dismissed.state == .closed else { return }
        release(dismissed)
        controller = nil
    }

    private func release(_ c: BridgedPlayerViewController?) {
        guard let c = c else { return }
        c.onDismissed = nil
        c.delegate = DetachedPlayerDelegate.shared
        if c === controller { liveDelegate = nil }
    }

    /// Engine detach (X-01): the session stays; requests are answered by DetachedPlayerDelegate.
    func onEngineDetached() {
        // TODO(SDP-VERIFY): 요확인 - 엔진 재attach 후 이전 엔진 세션 제어 불가(새 핸들러가 VC를 모름) · 근거 DRAFT-flutter-sdk-302-ios/U-04 · 자동 통과 금지(실측)
        controller?.onDismissed = nil
        controller?.delegate = DetachedPlayerDelegate.shared
        controller = nil
        liveDelegate = nil
        savedConfiguration = nil
        savedType = PlayerMapper.defaultType
        savedResizeMode = nil
        savedOverlayUI = nil
    }

    /// Merge base: saved -> held controller -> SDK default instance.
    private func currentConfiguration() -> ShoplivePlayerConfiguration {
        savedConfiguration ?? controller?.configuration ?? ShoplivePlayerConfiguration()
    }

    // MARK: respond (C-4)

    private func respondCoupon(_ args: Args) throws -> Bool {
        let id = try args.requireString("requestId")
        guard let pending = registry.peek(id) else { return false }
        guard case .coupon(let couponId, let respond) = pending else { throw kindMismatch() }
        let result = try PlayerMapper.toCouponResult(couponId: couponId, args) // invalid args keep the entry
        guard registry.take(id) != nil else { return false }
        respond(result)
        return true
    }

    private func respondCustomAction(_ args: Args) throws -> Bool {
        let id = try args.requireString("requestId")
        guard let pending = registry.peek(id) else { return false }
        guard case .customAction(let actionId, let respond) = pending else { throw kindMismatch() }
        let result = try PlayerMapper.toCustomActionResult(id: actionId, args)
        guard registry.take(id) != nil else { return false }
        respond(result)
        return true
    }

    private func kindMismatch() -> BridgeArgumentError {
        BridgeArgumentError(key: "requestId", expected: "request id of matching kind", actual: "other kind")
    }
}
