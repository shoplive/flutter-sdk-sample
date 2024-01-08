import Flutter
import UIKit
import ShopliveSDKCommon
import ShopLiveSDK


struct SwiftShoplivePlayerModuleEventName {
    static let EVENT_PLAYER_HANDLE_NAVIGATION = "event_player_handle_navigation"
    static let EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON = "event_player_handle_download_coupon"
    static let EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS = "event_player_change_campaign_status"
    static let EVENT_PLAYER_CAMPAIGN_INFO = "event_player_campaign_info"
    static let EVENT_PLAYER_ERROR = "event_player_error"
    static let EVENT_PLAYER_HANDLE_CUSTOM_ACTION = "event_player_handle_custom_action"
    static let EVENT_PLAYER_CHANGED_PLAYER_STATUS = "event_player_changed_player_status"
    static let EVENT_PLAYER_SET_USER_NAME = "event_player_set_user_name"
    static let EVENT_PLAYER_RECEIVED_COMMAND = "event_player_received_command"
    static let EVENT_PLAYER_LOG = "event_player_log"
}

class SwiftShopLivePlayerModule : SwiftShopliveBaseModule {

    typealias eventName = SwiftShoplivePlayerModuleEventName

    public static var eventHandleNavigation = ShopliveEventData(eventName: eventName.EVENT_PLAYER_HANDLE_NAVIGATION, flutterEventSink: nil)
    public static var eventHandleDownloadCoupon = ShopliveEventData(eventName: eventName.EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON, flutterEventSink: nil)
    public static var eventChangeCampaignStatus = ShopliveEventData(eventName: eventName.EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS, flutterEventSink: nil)
    public static var eventCampaignInfo = ShopliveEventData(eventName: eventName.EVENT_PLAYER_CAMPAIGN_INFO, flutterEventSink: nil)
    public static var eventError = ShopliveEventData(eventName: eventName.EVENT_PLAYER_ERROR, flutterEventSink: nil)
    public static var eventHandleCustomAction = ShopliveEventData(eventName: eventName.EVENT_PLAYER_HANDLE_CUSTOM_ACTION, flutterEventSink: nil)
    public static var eventChangedPlayerStatus = ShopliveEventData(eventName: eventName.EVENT_PLAYER_CHANGED_PLAYER_STATUS, flutterEventSink: nil)
    public static var eventSetUserName = ShopliveEventData(eventName: eventName.EVENT_PLAYER_SET_USER_NAME, flutterEventSink: nil)
    public static var eventReceivedCommand = ShopliveEventData(eventName: eventName.EVENT_PLAYER_RECEIVED_COMMAND, flutterEventSink: nil)
    public static var eventLog = ShopliveEventData(eventName: eventName.EVENT_PLAYER_LOG, flutterEventSink: nil)
    
    
    override var eventPairs: [String] {
        get {
            return [
                eventName.EVENT_PLAYER_HANDLE_NAVIGATION,
                eventName.EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON,
                eventName.EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS,
                eventName.EVENT_PLAYER_CAMPAIGN_INFO,
                eventName.EVENT_PLAYER_ERROR,
                eventName.EVENT_PLAYER_HANDLE_CUSTOM_ACTION,
                eventName.EVENT_PLAYER_CHANGED_PLAYER_STATUS,
                eventName.EVENT_PLAYER_SET_USER_NAME,
                eventName.EVENT_PLAYER_RECEIVED_COMMAND,
                eventName.EVENT_PLAYER_LOG
            ]
        }
        set {
            
        }
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
    
    
    override func handleMethodCall(call : FlutterMethodCall, result : @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else { return }
        print("[HASSAN LOG] args \(args)")
        print("[HASSAN LOG] call.method \(call.method)")
        switch(call.method) {
        case "setAccessKey" :
            setAccessKey(accessKey: args["accessKey"] as? String)
            break
        case "player_play" :
            play(
                campaignKey: args["campaignKey"] as? String,
                keepWindowStateOnPlayExecuted: args["keepWindowStateOnPlayExecuted"] as? Bool
            )
            break
        case "setUser" :
            setUser(userId: args["userId"] as? String, userName: args["userName"] as? String, age: args["age"] as? Int, gender: args["gender"] as? String, userScore: args["userScore"] as? Int, parameters: args["parameters"] as? Dictionary<String, String>)
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
        case "setMixWithOthers" :
            setMixWithOthers(isMixAudio: args["isMixAudio"] as? Bool)
            break
        case "useCloseButton" :
            useCloseButton(use: args["canUse"] as? Bool)
            break
        case "close" :
            close()
            break
        case "addParameter" :
            addParameter(key: args["key"] as? String, value: args["value"] as? String)
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
        userScore: Int?,
        parameters: Dictionary<String, String>?
    ) {
        let user = ShopLiveCommonUser(userId: userId ?? "")
        user.name = userName
        user.age = age ?? 0
        var _gender = ShopliveSDKCommon.ShopliveCommonUserGender.netural
        switch (gender) {
        case "m" :
            _gender = ShopliveSDKCommon.ShopliveCommonUserGender.male
            break
        case "f" :
            _gender = ShopliveSDKCommon.ShopliveCommonUserGender.female
            break
        default :
            _gender = ShopliveSDKCommon.ShopliveCommonUserGender.netural
            break
        }
        user.gender = _gender
        user.userScore = userScore
        
        let parameters = parameters ?? [String: String]()
        
        user.custom = parameters
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
    
    private func setMixWithOthers(isMixAudio: Bool?) {
        guard let isMixAudio = isMixAudio else {
            return
        }
        ShopLive.setMixWithOthers(isMixAudio: isMixAudio)
    }
    
    private func useCloseButton(use: Bool?) {
        guard let use = use else {
            return
        }
        ShopLive.useCloseButton(use)
    }
    
    private func close() {
        ShopLive.close()
    }
    
    private func addParameter(key: String?, value: String?) {
        guard let key = key else {
            return
        }
        guard let value = value else {
            return
        }
        ShopLive.addParameter(key: key, value: value)
    }
    
    private func removeParameter(key: String?) {
        guard let key = key else {
            return
        }
        ShopLive.removeParameter(key: key)
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
        let status: String
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
    
    private struct ShopliveLog : Codable {
        let name: String
        let feature: String
        let campaignKey: String
        let payload: [String : Any]
        
        init(name: String, feature: String, campaignKey: String, payload: [String : Any]) {
            self.name = name
            self.feature = feature
            self.campaignKey = campaignKey
            self.payload = payload
        }
        
        enum CodingKeys: String, CodingKey {
            case name, feature, campaignKey, payload
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.feature = try container.decode(String.self, forKey: .feature)
            self.campaignKey = try container.decode(String.self, forKey: .campaignKey)
            self.payload = try container.decode([String : Any].self, forKey: .payload)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(feature, forKey: .feature)
            try container.encode(campaignKey, forKey: .campaignKey)
            try container.encode(payload, forKey: .payload)
        }
    }
    
    private func setOption() {
        // tablet 화면 비율
        ShopLive.setKeepAspectOnTabletPortrait(true)
        ShopLive.setEnabledPipSwipeOut(true)
    }
}

extension SwiftShopLivePlayerModule: ShopLiveSDKDelegate {
    
    public func handleNavigation(with url: URL) {
        if let json = try? JSONEncoder().encode(HandleNavigation(url: url.absoluteString)) {
            if let eventSink = Self.eventHandleNavigation.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveSDK.ShopLiveCouponResult) -> Void) {
        if let json = try? JSONEncoder().encode(HandleDownloadCoupon(couponId: couponId)) {
            if let eventSink = Self.eventHandleDownloadCoupon.flutterEventSink {
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
            if let eventSink = Self.eventHandleCustomAction.flutterEventSink {
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
            if let eventSink = Self.eventHandleCustomAction.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void) {
        guard let payload = payload as? String else {
            return
        }
        if let json = try? JSONEncoder().encode(HandleCustomAction(id: id, type: type, payload: payload)) {
            if let eventSink = Self.eventHandleCustomAction.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleChangeCampaignStatus(status: String) {
        if let json = try? JSONEncoder().encode(ChangeCampaignStatus(campaignStatus: status)) {
            if let eventSink = Self.eventChangeCampaignStatus.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleError(code: String, message: String) {
        if let json = try? JSONEncoder().encode(Error(code: code, message: message)) {
            if let eventSink = Self.eventError.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleCampaignInfo(campaignInfo: [String : Any]) {
        if let json = try? JSONEncoder().encode(CampaignInfo(campaignInfo: campaignInfo)) {
            if let eventSink = Self.eventCampaignInfo.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleCommand(_ command: String, with payload: Any?) {
        guard let payload = (payload ?? [String: Any]()) as? Dictionary<String, Any> else {
            return
        }
        
        if let json = try? JSONEncoder().encode(ReceivedCommand(command: command, data: payload)) {
            if let eventSink = Self.eventReceivedCommand.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func onSetUserName(_ payload: [String : Any]) {
        if let json = try? JSONEncoder().encode(UserInfo(userInfo: payload)) {
            if let eventSink = Self.eventSetUserName.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleReceivedCommand(_ command: String, with payload: Any?) {
        guard let payload = (payload ?? [String: Any]()) as? Dictionary<String, Any> else {
            return
        }
        
        if let json = try? JSONEncoder().encode(ReceivedCommand(command: command, data: payload)) {
            if let eventSink = Self.eventReceivedCommand.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    public func handleChangedPlayerStatus(status: String) {
        if let json = try? JSONEncoder().encode(ChangedPlayerStatus(status: status)) {
            if let eventSink = Self.eventChangedPlayerStatus.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }

    public func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) {
        let eventLog = ShopLiveLog(name: name, feature: feature, campaign: campaign, payload: payload)

        if let json = try? JSONEncoder().encode(ShopliveLog(name: name, feature: feature.name, campaignKey: campaign, payload: payload)) {
            if let eventSink = Self.eventLog.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
}



fileprivate class StreamHandler: NSObject, FlutterStreamHandler {
    typealias eventName = SwiftShoplivePlayerModuleEventName
    typealias module = SwiftShopLivePlayerModule
    let eventname: String
    
    init(eventName: String) {
        self.eventname = eventName
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        switch (eventname) {
        case eventName.EVENT_PLAYER_HANDLE_NAVIGATION :
            module.eventHandleNavigation.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON :
            module.eventHandleDownloadCoupon.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS :
            module.eventChangeCampaignStatus.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_CAMPAIGN_INFO :
            module.eventCampaignInfo.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_ERROR :
            module.eventError.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_HANDLE_CUSTOM_ACTION :
            module.eventHandleCustomAction.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_CHANGED_PLAYER_STATUS :
            module.eventChangedPlayerStatus.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_SET_USER_NAME :
            module.eventSetUserName.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_RECEIVED_COMMAND :
            module.eventReceivedCommand.flutterEventSink = events
            break
        case eventName.EVENT_PLAYER_LOG :
            module.eventLog.flutterEventSink = events
            break
        default: return nil
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}


