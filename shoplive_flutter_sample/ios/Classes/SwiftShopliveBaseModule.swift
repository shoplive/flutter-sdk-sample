import Flutter
import UIKit


class SwiftShopliveBaseModule : NSObject {
    
    var eventPairs : [String] = []
    
    
    func register(registrar : FlutterPluginRegistrar) {
        eventPairs.forEach{ (data) in
            print("[HASSAN LOG] data \(data)")
            initializeEvent(binaryMessenger: registrar.messenger(), eventName: data)
        }
    }
    
    
    func initializeEvent(
        binaryMessenger: FlutterBinaryMessenger,
        eventName: String
    ) {

    }

    func handleMethodCall(call : FlutterMethodCall, result : @escaping FlutterResult ) {

    }
}
