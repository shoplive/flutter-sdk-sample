// BridgeFlutter - Flutter adapters for BridgeCore (DRAFT-flutter-sdk-302-ios design section 5).
// Keep in sync: identical copies in shoplive_core, shoplive_flutter_sample (shoplive_player) and shoplive_streamer ios/Classes/.
import Flutter
import Foundation

extension BridgeOutcome {
    /// Completes the MethodCall exactly once.
    func deliver(_ result: FlutterResult) {
        switch self {
        case .success(let value):
            result(value)
        case .failure(let failure):
            result(FlutterError(code: failure.code, message: failure.message, details: failure.details))
        case .notImplemented:
            result(FlutterMethodNotImplemented)
        }
    }
}

/// EventChannel stream handler backed by an EventEmitter.
final class EmitterStreamHandler: NSObject, FlutterStreamHandler {
    let emitter: EventEmitter

    init(emitter: EventEmitter) { self.emitter = emitter }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        emitter.listen { events($0) }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        emitter.cancel()
        return nil
    }
}

/// Logs method names, error codes and type names only - never argument values (sensitive data rule).
func bridgeLog(_ tag: String, _ message: String) {
    NSLog("[%@] %@", tag, message)
}

/// Rejects calls after detachFromEngine.
let bridgeDetachedError = BridgeStateError(code: BridgeErrorCode.sdkError, message: "plugin detached")
