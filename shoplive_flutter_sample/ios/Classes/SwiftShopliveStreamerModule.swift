//
//  SwiftShopliveStreamerModule.swift
//  shoplive_player
//
//  Created by sangmin han on 4/21/25.
//

import Foundation
import ShopliveSDKCommon
import ShopLiveStreamerSDK





class SwiftShopLiveStreamerModule : SwiftShopliveBaseModule {
    
    
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
        guard let args = call.arguments as? Dictionary<String,Any> else { return }
        switch call.method {
        case "streamer_play":
            startStreaming()
        default:
            return
        }
    }
    
    
    private func startStreaming() {
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
        
    }
}
