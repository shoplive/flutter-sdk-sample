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
            ShopLiveCommon.setAuthToken(authToken : args["userJWT"] as? String)
            ShopLiveCommon.setGuestUid(guestUid : args["guestUid"] as? String)
            ShopLiveCommon.setAccessKey(accessKey : args["accessKey"] as? String)
            ShopLiveCommon.setUtmSource(utmSource : args["utmSource"] as? String)
            ShopLiveCommon.setUtmMedium(utmMedium : args["utmMedium"] as? String)
            ShopLiveCommon.setUtmCampaign(utmCampaign : args["utmCampaign"] as? String)
            ShopLiveCommon.setUtmContent(utmContent : args["utmContent"] as? String)
        case "common_setAuthToken":
            ShopLiveCommon.setAuthToken(authToken : args["userJWT"] as? String)
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
                           userName: args["name"] as? String,
                           age: args["age"] as? Int,
                           gender: gender,
                           userScore: args["userScore"] as? Int,
                           custom: args["custom"] as? [String : Any])
        
        ShopLiveCommon.setUser(user: user, accessKey: accesskey)
        ShopLiveCommon.setAuthToken(authToken: JWTMaker.make(accessKey: accesskey, userData: user))
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



fileprivate class JWTMaker {
    typealias Header = [String : Any]
    typealias Payload = [String : Any]
    
    static func make(accessKey : String, userData : ShopLiveCommonUser, iat : Double? = nil) -> String? {
        var dict = userDataToDictionary(userData: userData)
        var payLoad : Payload = [ "accessKey" : accessKey ]
        if let iat = iat {
            payLoad["iat"] = iat
        }
        dict.removeValue(forKey: "custom")
        for (key,value) in dict {
            payLoad[key] = value
        }
        return make(payload: payLoad)
    }
    
    
    
    static func make(header : Header, payload : Payload ) -> String? {
        guard var header64BaseEncoded = header.toJson_SL()?.base64Encoded_SL else { return nil }
        header64BaseEncoded = header64BaseEncoded.replacingOccurrences(of: "=", with: "")
        var payLoad = payload
        if payLoad.keys.contains(where: { $0 == "iat" }) == false {
            payLoad["iat"] = Int(Date().timeIntervalSince1970)
        }
        guard var payload64BaseEncoded = payLoad.toJson()?.base64Encoded else { return nil }
        payload64BaseEncoded = payload64BaseEncoded.replacingOccurrences(of: "=", with: "")
        
        return "\(header64BaseEncoded).\(payload64BaseEncoded)."
    }
    
    
    static func make(payload : Payload) -> String? {
        return make(header: ["typ" : "JWT"], payload: payload)
    }
    
    static func userDataToDictionary(userData : ShopLiveCommonUser) -> [String : Any] {
        var dict : [String : Any] = [:]
        
        dict["userId"] = userData.userId
        
        if let name = userData.userName {
            dict["name"] = name
        }
        if let age = userData.age {
            dict["age"] = age
        }
        if let gender = userData.gender {
            dict["gender"] = gender.rawValue
        }
        if let userScore = userData.userScore {
            dict["userScore"] = userScore
        }
        if let custom = userData.custom {
            for (key,value) in custom {
                dict[key] = value
            }
        }
        return dict
    }
}


extension Dictionary {
    func toJson() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8){
            return jsonString
        }else{
            return nil
        }
    }
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
    
    func toJSONString() -> String? {
        if let jsonData = jsonData {
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        
        return nil
    }
}

extension String {
    var base64Encoded: String? {
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
}
