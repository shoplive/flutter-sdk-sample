import Flutter
import UIKit
import ShopliveSDKCommon



class SwiftShopliveCommonModule : SwiftShopliveBaseModule {
    
    
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
        case "common_setAuth":
            ShopLiveCommon.setUserJWT(userJWT : args["userJWT"] as? String)
            ShopLiveCommon.setGuestUid(guestUid : args["guestUid"] as? String)
            ShopLiveCommon.setAccessKey(accessKey : args["accessKey"] as? String)
            ShopLiveCommon.setUtmSource(utmSource : args["utmSource"] as? String)
            ShopLiveCommon.setUtmMedium(utmMedium : args["utmMedium"] as? String)
            ShopLiveCommon.setUtmCampaign(utmCampaign : args["utmCampaign"] as? String)
            ShopLiveCommon.setUtmContent(utmContent : args["utmContent"] as? String)
        case "common_setUserJWT":
            ShopLiveCommon.setUserJWT(userJWT : args["userJWT"] as? String)
        case "common_setUser":
            setUser(args: args)
        case "common_setUtmSource":
            ShopLiveCommon.setUtmSource(utmSource : args["utmSource"] as? String)
        case "common_setUtmMedium":
            ShopLiveCommon.setUtmMedium(utmMedium : args["utmMedium"] as? String)
        case "common_setUtmCampaign":
            ShopLiveCommon.setUtmCampaign(utmCampaign : args["utmCampaign"] as? String)
        case "common_setUtmContent":
            ShopLiveCommon.setUtmContent(utmContent : args["utmContent"] as? String)
        case "common_setAccessKey":
            ShopLiveCommon.setAccessKey(accessKey : args["accessKey"] as? String)
        case "common_clearAuth":
            ShopLiveCommon.clearAuth()
        default:
            return
        }
    }
    
    
    private func setUser(args : [String : Any]) {
        guard let accesskey = args["accessKey"] as? String,
              let userId = args["userId"] as? String else { return }
        
        var gender : ShopliveCommonUserGender?
        if let genderString = args["gender"] as? String {
            switch genderString {
            case "m":
                gender = .male
            case "f":
                gender = .female
            case "n":
                gender = .netural
            default:
                break
            }
        }
        let user = ShopLiveCommonUser(userId: userId,
                           name: args["name"] as? String,
                           age: args["age"] as? Int,
                           gender: gender,
                           userScore: args["userScore"] as? Int,
                           custom: args["custom"] as? [String : Any])
        
        ShopLiveCommon.setUser(user: user)
    }
    
}


fileprivate class StreamHandler: NSObject, FlutterStreamHandler {
    let eventName: String
    
    init(eventName: String) {
        self.eventName = eventName
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        switch (eventName) {
       
            
            
            
        default: return nil
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

