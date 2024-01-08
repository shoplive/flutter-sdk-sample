import Flutter
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

public struct ShopliveEventData {
    let eventName: String
    var flutterEventSink: FlutterEventSink? = nil
    
    init(eventName: String, flutterEventSink: FlutterEventSink?) {
        self.eventName = eventName
        self.flutterEventSink = flutterEventSink
    }
}

public class SwiftShoplivePlayerPlugin: NSObject, FlutterPlugin {

   private var playerModule = SwiftShoplivePlayerModule()
   private var commonModule = SwiftShopliveCommonModule()


    public static func register(with registrar: FlutterPluginRegistrar) {
        playerModule.register(registrar : registrar)
        commonModule.register(registrar : registrar)

        let channel = FlutterMethodChannel(name: "shoplive_player", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: channel)
    }

    func handle(_ call : FlutterMethodCall, result: @escaping FlutterResult ) {
        playerModule.handleMethodCall(call: call , result : result)
        commonModule.handleMethodCall(call: call , result : result)
    }


}






