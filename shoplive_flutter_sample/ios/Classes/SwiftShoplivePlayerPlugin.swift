import Flutter
import UIKit
import ShopLiveSDK

public struct ShopliveEventData {
    let eventName: String
    var flutterEventSink: FlutterEventSink? = nil
    
    init(eventName: String, flutterEventSink: FlutterEventSink?) {
        self.eventName = eventName
        self.flutterEventSink = flutterEventSink
    }
}

public class SwiftShoplivePlayerPlugin: NSObject, FlutterPlugin {
    private static let EVENT_HANDLE_NAVIGATION = "event_handle_navigation"
    private static let EVENT_HANDLE_DOWNLOAD_COUPON = "event_handle_download_coupon"
    private static let EVENT_CHANGE_CAMPAIGN_STATUS = "event_change_campaign_status"
    private static let EVENT_CAMPAIGN_INFO = "event_campaign_info"
    private static let EVENT_ERROR = "event_error"
    private static let EVENT_HANDLE_CUSTOM_ACTION = "event_handle_custom_action"
    private static let EVENT_CHANGED_PLAYER_STATUS = "event_changed_player_status"
    private static let EVENT_SET_USER_NAME = "event_set_user_name"
    private static let EVENT_RECEIVED_COMMAND = "event_received_command"
    
    public static var eventHandleNavigation = ShopliveEventData(eventName: EVENT_HANDLE_NAVIGATION, flutterEventSink: nil)
    public static var eventHandleDownloadCoupon = ShopliveEventData(eventName: EVENT_HANDLE_DOWNLOAD_COUPON, flutterEventSink: nil)
    public static var eventChangeCampaignStatus = ShopliveEventData(eventName: EVENT_CHANGE_CAMPAIGN_STATUS, flutterEventSink: nil)
    public static var eventCampaignInfo = ShopliveEventData(eventName: EVENT_CAMPAIGN_INFO, flutterEventSink: nil)
    public static var eventError = ShopliveEventData(eventName: EVENT_ERROR, flutterEventSink: nil)
    public static var eventHandleCustomAction = ShopliveEventData(eventName: EVENT_HANDLE_CUSTOM_ACTION, flutterEventSink: nil)
    public static var eventChangedPlayerStatus = ShopliveEventData(eventName: EVENT_CHANGED_PLAYER_STATUS, flutterEventSink: nil)
    public static var eventSetUserName = ShopliveEventData(eventName: EVENT_SET_USER_NAME, flutterEventSink: nil)
    public static var eventReceivedCommand = ShopliveEventData(eventName: EVENT_RECEIVED_COMMAND, flutterEventSink: nil)
    
    
    private static let eventPairs = [
        EVENT_HANDLE_NAVIGATION,
        EVENT_HANDLE_DOWNLOAD_COUPON,
        EVENT_CHANGE_CAMPAIGN_STATUS,
        EVENT_CAMPAIGN_INFO,
        EVENT_ERROR,
        EVENT_HANDLE_CUSTOM_ACTION,
        EVENT_CHANGED_PLAYER_STATUS,
        EVENT_SET_USER_NAME,
        EVENT_RECEIVED_COMMAND
    ]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        eventPairs.forEach{(data) in
            initializeEvent(binaryMessenger: registrar.messenger(), eventName: data)
        }
        print(eventPairs)
        
        let channel = FlutterMethodChannel(name: "shoplive_player", binaryMessenger: registrar.messenger())
        let instance = SwiftShoplivePlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    private static func initializeEvent(
        binaryMessenger: FlutterBinaryMessenger,
        eventName: String
    ) {
        let eventChannel = FlutterEventChannel(name: eventName, binaryMessenger: binaryMessenger)
        let streamHandler = StreamHandler(eventName: eventName)
        eventChannel.setStreamHandler(streamHandler)
    }
    
    
    private class StreamHandler: NSObject, FlutterStreamHandler {
        let eventName: String
        
        init(eventName: String) {
            self.eventName = eventName
        }
        
        public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            switch (eventName) {
            case EVENT_HANDLE_NAVIGATION :
                eventHandleNavigation.flutterEventSink = events
                break
            case EVENT_HANDLE_DOWNLOAD_COUPON :
                eventHandleDownloadCoupon.flutterEventSink = events
                break
            case EVENT_CHANGE_CAMPAIGN_STATUS :
                eventChangeCampaignStatus.flutterEventSink = events
                break
            case EVENT_CAMPAIGN_INFO :
                eventCampaignInfo.flutterEventSink = events
                break
            case EVENT_ERROR :
                eventError.flutterEventSink = events
                break
            case EVENT_HANDLE_CUSTOM_ACTION :
                eventHandleCustomAction.flutterEventSink = events
                break
            case EVENT_CHANGED_PLAYER_STATUS :
                eventChangedPlayerStatus.flutterEventSink = events
                break
            case EVENT_SET_USER_NAME :
                eventSetUserName.flutterEventSink = events
                break
            case EVENT_RECEIVED_COMMAND :
                eventReceivedCommand.flutterEventSink = events
                break
            default: return nil
            }
            return nil
        }
        
        public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            return nil
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else { return }
        switch(call.method) {
        case "setAccessKey" :
            setAccessKey(accessKey: args["accessKey"] as? String)
            break
        case "play" :
            play(
                campaignKey: args["campaignKey"] as? String,
                keepWindowStateOnPlayExecuted: args["keepWindowStateOnPlayExecuted"] as? Bool
            )
            break
        case "setUser" :
            setUser(userId: args["userId"] as? String, userName: args["userName"] as? String, age: args["age"] as? Int, gender: args["gender"] as? String, userScore: args["userScore"] as? Int)
            break
        case "setAuthToken" :
            setAuthToken(authToken: args["authToken"] as? String)
            break
        case "resetUser" :
            resetUser()
            break
        case "setShareScheme" :
            setShareScheme(shareSchemeUrl: args["shareSchemeUrl"] as? String)
            break
        case "setEndpoint" :
            setEndpoint(endpoint: args["endpoint"] as? String)
            break
        case "setNextActionOnHandleNavigation" :
            setNextActionOnHandleNavigation(type: args["type"] as? Int)
            break
        case "setEnterPipModeOnBackPressed" :
            setEnterPipModeOnBackPressed(isEnterPipMode: args["isEnterPipMode"] as? Bool)
            break
        case "setMuteWhenPlayStart" :
            setMuteWhenPlayStart(isMute: args["isMute"] as? Bool)
            break
        case "close" :
            close()
            break
        case "addParameter" :
            addParameter(key: args["key"] as? String, letue: args["letue"] as? String)
            break
        case "removeParameter" :
            removeParameter(key: args["key"] as? String)
            break
        default : break
        }
    }
    
    // region ShopLive Public class
    private func play(campaignKey: String?, keepWindowStateOnPlayExecuted: Bool?) {
        guard campaignKey != nil else { return }
        
        ShopLive.delegate = self
        
        setOption()
        guard let keepWindowStateOnPlayExecuted = keepWindowStateOnPlayExecuted else {
            ShopLive.play(with: campaignKey)
            return
        }
        ShopLive.play(with: campaignKey, keepWindowStateOnPlayExecuted: keepWindowStateOnPlayExecuted)
    }
    
    private func setUser(
        userId: String?,
        userName: String?,
        age: Int?,
        gender: String?,
        userScore: Int?
    ) {
        let user = ShopLiveSDK.ShopLiveUser()
        user.id = userId
        user.name = userName
        user.age = age ?? 0
        var _gender = ShopLiveSDK.ShopLiveUser.Gender.unknown
        switch (gender) {
        case "m" :
            _gender = ShopLiveSDK.ShopLiveUser.Gender.male
            break
        case "f" :
            _gender = ShopLiveSDK.ShopLiveUser.Gender.female
            break
        default :
            _gender = ShopLiveSDK.ShopLiveUser.Gender.neutral
            break
        }
        user.gender = _gender
        user.add(["userScore": userScore])
        ShopLive.user = user
    }
    
    private func setAuthToken(authToken: String?) {
        ShopLive.authToken = authToken
    }
    
    private func setAccessKey(accessKey: String?) {
        guard let accessKey = accessKey else {
            return
        }
        
        ShopLive.configure(with: accessKey)
    }
    
    private func resetUser() {
        ShopLive.user = nil
    }
    
    private func setShareScheme(shareSchemeUrl: String?) {
        guard let shareSchemeUrl = shareSchemeUrl else {
            return
        }
        ShopLive.setShareScheme(shareSchemeUrl, custom: nil)
    }
    
    private func setEndpoint(endpoint: String?) {
        guard let endpoint = endpoint else {
            return
        }
        ShopLive.setEndpoint(endpoint)
    }
    
    private func setNextActionOnHandleNavigation(type: Int?) {
        guard let type = type else {
            return
        }
        guard let actionType = ShopLiveSDK.ActionType(rawValue: type) else {
            return
        }
        
        ShopLive.setNextActionOnHandleNavigation(actionType: actionType)
    }
    
    private func setEnterPipModeOnBackPressed(isEnterPipMode: Bool?) {
        // Do nothing
    }
    
    private func setMuteWhenPlayStart(isMute: Bool?) {
        guard let isMute = isMute else {
            return
        }
        ShopLive.setMuteWhenPlayStart(isMute)
    }
    
    private func close() {
        ShopLive.close()
    }
    
    private func addParameter(key: String?, letue: String?) {
        guard let key = key else {
            return
        }
        let user = ShopLive.user
        user?.add([key : letue])
        ShopLive.user = user
    }
    
    private func removeParameter(key: String?) {
        guard let key = key else {
            return
        }
        let user = ShopLive.user
        user?.remove(key: key)
        ShopLive.user = user
    }
    // endregion
    
    
    
    private struct HandleNavigation: Codable {
        let url: String
    }
    private struct HandleDownloadCoupon: Codable {
        let couponId: String
    }
    private struct ChangeCampaignStatus: Codable {
        let campaignStatus: String
    }
    private struct CampaignInfo: Codable {
        let campaignInfo: [String : Any]
        
        init(campaignInfo: [String : Any]) {
            self.campaignInfo = campaignInfo
        }
        
        enum CodingKeys: String, CodingKey {
            case campaignInfo
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.campaignInfo = try container.decode([String: Any].self, forKey: .campaignInfo)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(campaignInfo, forKey: .campaignInfo)
        }
    }
    private struct Error: Codable {
        let code: String
        let message: String
    }
    private struct HandleCustomAction: Codable {
        let id: String
        let type: String
        let payload: String
    }
    
    private struct ChangedPlayerStatus: Codable {
        let isPipMode: Bool
        let state: String
        
    }
    private struct UserInfo : Codable {
        var userInfo: [String : Any]
        
        init(userInfo: [String : Any]) {
            self.userInfo = userInfo
        }
        
        enum CodingKeys: String, CodingKey {
            case userInfo
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.userInfo = try container.decode([String: Any].self, forKey: .userInfo)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userInfo, forKey: .userInfo)
        }
    }
    
    private struct ReceivedCommand : Codable {
        let command: String
        let data: [String : Any]
        
        init(command: String, data: [String : Any]) {
            self.command = command
            self.data = data
        }
        
        enum CodingKeys: String, CodingKey {
            case command, data
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.command = try container.decode(String.self, forKey: .command)
            self.data = try container.decode([String : Any].self, forKey: .data)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(command, forKey: .command)
            try container.encode(data, forKey: .data)
        }
    }
    
    private func setOption() {
        // tablet 화면 비율
        ShopLive.setKeepAspectOnTabletPortrait(true)
    }
}

private struct JSONCodingKeys: CodingKey {
    public var stringValue: String
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int?
    
    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}


private extension KeyedDecodingContainer {
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

private extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}


private extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    mutating func encode(_ value: Dictionary<String, Any>) throws {
        try value.forEach({ (key, value) in
            let key = JSONCodingKeys(stringValue: key)
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as CGFloat:
                try encode(value, forKey: key)
            case let value as Dictionary<String, Any>:
                try encode(value, forKey: key)
            case let value as Array<Any>:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        })
    }
}

private extension KeyedEncodingContainerProtocol {
    mutating func encode(_ value: Dictionary<String, Any>?, forKey key: Key) throws {
        if value != nil {
            var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
            try container.encode(value!)
        }
    }
    
    mutating func encode(_ value: Array<Any>?, forKey key: Key) throws {
        if value != nil {
            var container = self.nestedUnkeyedContainer(forKey: key)
            try container.encode(value!)
        }
    }
}

private extension UnkeyedEncodingContainer {
    mutating func encode(_ value: Array<Any>) throws {
        try value.enumerated().forEach({ (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as CGFloat:
                try encode(value)
            case let value as Dictionary<String, Any>:
                try encode(value)
            case let value as Array<Any>:
                try encode(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        })
    }
    
    mutating func encode(_ value: Dictionary<String, Any>) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encode(value)
    }
}

extension SwiftShoplivePlayerPlugin: ShopLiveSDKDelegate {
    
    public func handleNavigation(with url: URL) {
        if let json = try? JSONEncoder().encode(HandleNavigation(url: url.path)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventHandleNavigation.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveSDK.ShopLiveCouponResult) -> Void) {
        if let json = try? JSONEncoder().encode(HandleDownloadCoupon(couponId: couponId)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventHandleDownloadCoupon.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
        
        DispatchQueue.main.async {
            let couponResult = ShopLiveCouponResult(couponId: couponId, success: true, message: "Success", status: ShopLiveSDK.ShopLiveResultStatus.HIDE, alertType: ShopLiveSDK.ShopLiveResultAlertType.TOAST)
            result(couponResult)
        }
    }
    
    public func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (ShopLiveSDK.CustomActionResult) -> Void) {
        guard let payload = payload as? String else {
            return
        }
        if let json = try? JSONEncoder().encode(HandleCustomAction(id: id, type: type, payload: payload)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventHandleCustomAction.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
        
        DispatchQueue.main.async {
            let customActionResult = CustomActionResult(id: id, success: true,  message: "Success", status: ShopLiveSDK.ResultStatus.HIDE, alertType: ShopLiveSDK.ResultAlertType.TOAST)
            completion(customActionResult)
        }
    }
    
    public func handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveSDK.ShopLiveCustomActionResult) -> Void) {
        guard let payload = payload as? String else {
            return
        }
        if let json = try? JSONEncoder().encode(HandleCustomAction(id: id, type: type, payload: payload)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventHandleCustomAction.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void) {
        guard let payload = payload as? String else {
            return
        }
        if let json = try? JSONEncoder().encode(HandleCustomAction(id: id, type: type, payload: payload)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventHandleCustomAction.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleChangeCampaignStatus(status: String) {
        if let json = try? JSONEncoder().encode(ChangeCampaignStatus(campaignStatus: status)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventChangeCampaignStatus.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleError(code: String, message: String) {
        if let json = try? JSONEncoder().encode(Error(code: code, message: message)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventError.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleCampaignInfo(campaignInfo: [String : Any]) {
        if let json = try? JSONEncoder().encode(CampaignInfo(campaignInfo: campaignInfo)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventCampaignInfo.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleCommand(_ command: String, with payload: Any?) {
        guard let payload = (payload ?? [String: Any]()) as? Dictionary<String, Any> else {
            return
        }
        var changedPlayerStatus: ChangedPlayerStatus?
        switch(command) {
        case "willShopLiveOn" :
            changedPlayerStatus = ChangedPlayerStatus(isPipMode: false, state: "CREATE")
            break
        case "willShopLiveOff" :
            changedPlayerStatus = ChangedPlayerStatus(isPipMode: (payload["accessKey"] as? Int == 2) ? true : false, state: "DESTROY")
            break
        default:
            changedPlayerStatus = nil
            break
        }
        
        if let status = changedPlayerStatus {
            if let json = try? JSONEncoder().encode(status) {
                if let eventSink = SwiftShoplivePlayerPlugin.eventChangedPlayerStatus.flutterEventSink {
                    eventSink(String(data: json, encoding: .utf8))
                }
            }
        }
        
        if let json = try? JSONEncoder().encode(ReceivedCommand(command: command, data: payload)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventReceivedCommand.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func onSetUserName(_ payload: [String : Any]) {
        if let json = try? JSONEncoder().encode(UserInfo(userInfo: payload)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventSetUserName.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleReceivedCommand(_ command: String, with payload: Any?) {
        guard let payload = (payload ?? [String: Any]()) as? Dictionary<String, Any> else {
            return
        }
        
        if let json = try? JSONEncoder().encode(ReceivedCommand(command: command, data: payload)) {
            if let eventSink = SwiftShoplivePlayerPlugin.eventReceivedCommand.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
}
