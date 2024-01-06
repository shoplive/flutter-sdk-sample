import Flutter
import UIKit


class SwiftShopliveBaseModule : NSObject, FlutterPlugin {

    var eventPairs : [String] = []

    func register(registrar : FlutterPluginRegistrar) {
        eventPairs.forEach{ (data) in
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