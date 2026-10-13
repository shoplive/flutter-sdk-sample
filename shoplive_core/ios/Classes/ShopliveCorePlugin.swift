import Flutter
import UIKit
import ShopliveCore

/// shoplive_core plugin - channel `shoplive_core` (Android design section 2.4, iOS design section 2.1).
/// Every call completes exactly once. No initialization guard - the SDK decides (F-01).
public final class ShopliveCorePlugin: NSObject, FlutterPlugin {
    static let methodChannelName = "shoplive_core"
    private static let tag = "ShopliveCorePlugin"

    private var channel: FlutterMethodChannel?
    private var detached = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ShopliveCorePlugin()
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        detached = true
        channel?.setMethodCallHandler(nil)
        channel = nil
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let outcome = bridgedCall { try dispatch(call) }
        if case .failure(let f) = outcome { bridgeLog(Self.tag, "\(call.method): \(f.code)") }
        outcome.deliver(result)
    }

    private func dispatch(_ call: FlutterMethodCall) throws -> Any? {
        if detached { throw bridgeDetachedError }
        let args = try Args.of(call.arguments)
        switch call.method {
        case "initialize":
            // TODO(SDP-VERIFY): 요확인 - initialize 반복 호출(핫 리스타트·다중 엔진)의 iOS SDK 동작 · 근거 DRAFT-flutter-sdk-302-ios/F-01 · 자동 통과 금지(실측)
            Shoplive.initialize(try CoreMapper.toConfiguration(args))
        case "setUser":
            Shoplive.setUser(try CoreMapper.toUser(args))
        case "setStreamToken":
            Shoplive.setStreamToken(try CoreMapper.toStreamToken(args))
        case "logout":
            Shoplive.logout()
        case "sendConversionEvent":
            Shoplive.sendConversionEvent(data: try CoreMapper.toConversionData(args))
        case "getSdkVersion":
            return Shoplive.sdkVersion
        default:
            throw BridgeNotImplemented()
        }
        return nil
    }
}
