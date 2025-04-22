//
//  SwiftShopliveStreamerModule.swift
//  shoplive_player
//
//  Created by sangmin han on 4/21/25.
//

import Foundation
import ShopliveSDKCommon
import ShopLiveStreamerSDK


struct SwiftShopliveStreamerModuleEventName {
    static let EVENT_STREAMER_ERROR = "event_streamer_error"
}


class SwiftShopLiveStreamerModule : SwiftShopliveBaseModule {
    
    typealias eventName = SwiftShopliveStreamerModuleEventName
    
    
    public static var eventStreamerError = ShopliveEventData(eventName: eventName.EVENT_STREAMER_ERROR, flutterEventSink: nil)
    
    
    override init() {
        ShopLiveStreamer.request( .setEnvironmentStage(.prod) )
        ShopLiveStreamer.request( .initialize )
    }
    
    
    override func initializeEvent(
        binaryMessenger: FlutterBinaryMessenger,
        eventName: String
    )
    {
        let eventChannel = FlutterEventChannel(name: eventName, binaryMessenger: binaryMessenger)
        let streamHandler = StreamHandler(eventName: eventName)
        eventChannel.setStreamHandler(streamHandler)
    }
    
    
    override func handleMethodCall(call : FlutterMethodCall, result : @escaping FlutterResult ) {
        switch call.method {
        case "streamer_play":
            let ck = ((call.arguments as? [String:Any])?["campaignKey"] as? String) ?? ""
            startStreaming(campaignKey: ck)
        default:
            return
        }
    }
    
    
    private func startStreaming(campaignKey : String) {
        let vc = ShopLiveStreamer.Builder(data: .init(
            campaignKey: campaignKey,
            type: .type1,
            isRehearsal: false,
            useLiveStartButtonCallback: false,
            useLiveStopButtonCallback: false,
            useCloseButtonCallback: false
        ),
                                          delegate: self)
            .build()
        //need to pushViewControler
        
        guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        
        vc.modalPresentationStyle = .overFullScreen
        rootVC.present(vc, animated: true, completion: nil)
    }
    
    
}
extension SwiftShopLiveStreamerModule : ShopLiveStreamerDelegate {
    
    func onLiveStreamStartButtonTapped(view ShopLiveStreamerViewController : UIViewController?, campaignStatus : String, completion : @escaping(ShopLiveStreamerLiveStartButtonAction) -> ()) {
        
    }
    
    func onLiveStreamStopButtonTapped(view ShopLiveStreamerViewController: UIViewController?, completion: @escaping (ShopLiveStreamerSDK.ShopLiveStreamerLiveStopButtonAction) -> ()) {
        
    }
    
    func onCloseButtonTapped(view ShopLiveSteamerViewController: UIViewController?, completion: @escaping (ShopLiveStreamerSDK.ShopLiveStreamerCloseButtonAction) -> ()) {
        
    }
    
    func onError(error : Error) {
        if let error = error as? ShopLiveCommonError {
            if let eventSink = Self.eventStreamerError.flutterEventSink {
                let dict : [String : Any] = ["code" : error.codes, "message" : error.message ?? ""]
                eventSink(dict)
            }
        }
        else {
            if let error = error as? NSError {
                if let eventSink = Self.eventStreamerError.flutterEventSink {
                    let dict : [String : Any] = ["code" : error.code, "message" : error.localizedDescription]
                    eventSink(dict)
                }
            }
        }
    }
}

fileprivate class StreamHandler: NSObject, FlutterStreamHandler {
    typealias eventName = SwiftShopliveStreamerModuleEventName
    typealias module = SwiftShopLiveStreamerModule
    let eventname: String
    
    init(eventName: String) {
        self.eventname = eventName
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        switch (eventname) {
        case eventName.EVENT_STREAMER_ERROR :
            module.eventStreamerError.flutterEventSink = events
            break
        default: return nil
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

