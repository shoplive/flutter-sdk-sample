import Flutter
import UIKit
import ShopLiveCorePlayerSDK
import ShopLiveHLSPlayerSDK
import ShopLiveWebRTCPlayerSDK
import ShopliveSDKCommon

public struct ShopliveEventData {
    let eventName: String
    var flutterEventSink: FlutterEventSink? = nil
    
    init(eventName: String, flutterEventSink: FlutterEventSink?) {
        self.eventName = eventName
        self.flutterEventSink = flutterEventSink
    }
}

class SwiftShopLiveNotification {
    static let shared = SwiftShopLiveNotification()
    
    
    var registerCallback: ((FlutterPluginRegistrar) -> ())?
    
    
    init() {
        registerObserver()
    }
    
    func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification: )), name: Notification.Name("swiftshopliveplayerpluginnotification"), object: nil)
    }
    
    @objc func handleNotification(notification : Notification) {
        guard let registrar = notification.object as? FlutterPluginRegistrar else { return }
        registerCallback?(registrar)
    }
    
}

public class SwiftShoplivePlayerPlugin: NSObject {
    
    private static var playerModule = SwiftShopLivePlayerModule()
    private static var commonModule = SwiftShopliveCommonModule()
    private static var shortformModule = SwiftShopliveShortformModule()
    private static var streamerModule = SwiftShopLiveStreamerModule()
    
    
}
extension SwiftShoplivePlayerPlugin : FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftShopLiveNotification.shared.registerObserver()
        SwiftShopLiveNotification.shared.registerCallback = {  registrar in
            self.playerModule.register(registrar : registrar)
            self.commonModule.register(registrar : registrar)
            self.shortformModule.register(registrar: registrar)
            let channel = FlutterMethodChannel(name: "shoplive_player", binaryMessenger: registrar.messenger())
            registrar.addMethodCallDelegate(SwiftShoplivePlayerPlugin(), channel: channel)
        }
        NotificationCenter.default.post(name: Notification.Name("swiftshopliveplayerpluginnotification"), object: registrar)
    }
    
    public func handle(_ call : FlutterMethodCall, result: @escaping FlutterResult ) {
        Self.playerModule.handleMethodCall(call: call , result : result)
        Self.commonModule.handleMethodCall(call: call , result : result)
        Self.shortformModule.handleMethodCall(call: call, result: result)
    }
    
}





