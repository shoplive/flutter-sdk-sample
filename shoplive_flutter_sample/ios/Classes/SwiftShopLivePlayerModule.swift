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
    
    // callback 객체를 임시 저장하는 Dictionary (id를 key로 사용)
    private var pendingCallbacks: [String: Any] = [:]
    
    // 타임아웃 관리를 위한 타이머들
    private var timeoutTimers: [String: Timer] = [:]
    
    // 타임아웃 시간 (5초)
    private let callbackTimeoutSeconds: TimeInterval = 5.0

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
        let args = call.arguments as? [String: Any]
        print("[HASSAN LOG] args \(args)")
        print("[HASSAN LOG] call.method \(call.method)")
        switch(call.method) {
    
        case "player_play" :
            play(
                campaignKey: args?["campaignKey"] as? String,
                keepWindowStateOnPlayExecuted: args?["keepWindowStateOnPlayExecuted"] as? Bool
            )
            break
        case "player_setPreviewOption" :
            setPreviewOption(args: args)
            result(nil)
            break

        case "player_showPreview" :
            showPreview(campaignKey: args?["campaignKey"] as? String)
            break
        case "player_hidePreview" :
            hidePreview()
            break
        case "player_setShareScheme" :
            setShareScheme(shareSchemeUrl: args?["shareSchemeUrl"] as? String)
            break
        case "player_setEndpoint" :
            setEndpoint(endpoint: args?["endpoint"] as? String)
            break
        case "player_setNextActionOnHandleNavigation" :
            setNextActionOnHandleNavigation(type: args?["type"] as? Int)
            break
        case "player_setEnterPipModeOnBackPressed" :
            setEnterPipModeOnBackPressed(isEnterPipMode: args?["isEnterPipMode"] as? Bool)
            break
        case "player_setMuteWhenPlayStart" :
            setMuteWhenPlayStart(isMute: args?["isMute"] as? Bool)
            break
        case "player_setMixWithOthers" :
            setMixWithOthers(isMixAudio: args?["isMixAudio"] as? Bool)
            break
        case "player_useCloseButton" :
            useCloseButton(use: args?["canUse"] as? Bool)
            break
        case "player_close" :
            close()
            break
        case "player_startPictureInPicture" :
            startPictureInPicture()
            break
        case "player_stopPictureInPicture" :
            stopPictureInPicture()
            break
        case "player_sendCommandMessage" :
            sendCommandMessage(command: args?["command"] as? String, payload: args?["payload"] as? [String:Any])
            break
        case "player_addParameter" :
            addParameter(key: args?["key"] as? String, value: args?["value"] as? String)
            break
        case "player_removeParameter" :
            removeParameter(key: args?["key"] as? String)
            break
        case "player_downloadCouponResult" :
            let couponId = args?["couponId"] as? String ?? ""
            let success = args?["success"] as? Bool ?? true
            let message = args?["message"] as? String ?? "Success"
            let popupStatus = args?["popupStatus"] as? String ?? "HIDE"
            let alertType = args?["alertType"] as? String ?? "TOAST"
            
            // 저장된 callback 가져오기
            if let callback = pendingCallbacks.removeValue(forKey: couponId) as? (ShopLiveCouponResult) -> Void {
                // 타임아웃 타이머 취소
                timeoutTimers[couponId]?.invalidate()
                timeoutTimers.removeValue(forKey: couponId)
                
                // Flutter에서 받은 값으로 callback 호출
                let couponResult = ShopLiveCouponResult(
                    couponId: couponId,
                    success: success,
                    message: message,
                    status: popupStatus == "SHOW" ? ShopLiveResultStatus.SHOW :
                        popupStatus == "HIDE" ? ShopLiveResultStatus.HIDE :
                        popupStatus == "KEEP" ? ShopLiveResultStatus.KEEP : ShopLiveResultStatus.HIDE,
                    alertType: alertType == "TOAST" ? ShopLiveResultAlertType.TOAST :
                        alertType == "ALERT" ? ShopLiveResultAlertType.ALERT : ShopLiveResultAlertType.TOAST
                )
                callback(couponResult)
            }
            
            result(nil)
            break
        case "player_customActionResult" :
            let id = args?["id"] as? String ?? ""
            let success = args?["success"] as? Bool ?? true
            let message = args?["message"] as? String ?? "Success"
            let popupStatus = args?["popupStatus"] as? String ?? "HIDE"
            let alertType = args?["alertType"] as? String ?? "TOAST"

            // 저장된 callback 가져오기
            if let callback = pendingCallbacks.removeValue(forKey: id) as? (ShopLiveCustomActionResult) -> Void {
                // 타임아웃 타이머 취소
                timeoutTimers[id]?.invalidate()
                timeoutTimers.removeValue(forKey: id)
                
                // Flutter에서 받은 값으로 callback 호출
                let customActionResult = ShopLiveCustomActionResult(
                    id: id,
                    success: success,
                    message: message,
                    status: popupStatus == "SHOW" ? ShopLiveResultStatus.SHOW :
                        popupStatus == "HIDE" ? ShopLiveResultStatus.HIDE :
                        popupStatus == "KEEP" ? ShopLiveResultStatus.KEEP : ShopLiveResultStatus.HIDE,
                    alertType: alertType == "TOAST" ? ShopLiveResultAlertType.TOAST :
                        alertType == "ALERT" ? ShopLiveResultAlertType.ALERT : ShopLiveResultAlertType.TOAST
                )
                callback(customActionResult)
            }
            
            result(nil)
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

    private func setPreviewOption(args: [String: Any]?) {
        let positionString = args?["position"] as? String ?? "topLeft"
        

        let marginTop = args?["marginTop"] as? CGFloat ?? 0
        let marginBottom = args?["marginBottom"] as? CGFloat ?? 0
        let marginLeft = args?["marginLeft"] as? CGFloat ?? 0
        let marginRight = args?["marginRight"] as? CGFloat ?? 0
        
        let closeButtonConfigMap = (args?["closeButtonConfig"] as? [String: Any]) ?? [:]
        let closeButtonPositionString = closeButtonConfigMap["position"] as? String ?? "TOP_LEFT"
        let closeButtonPosition: ShopLive.PreviewCloseButtonPositionConfig = {
            switch closeButtonPositionString {
            case "TOP_LEFT": return .topLeft
            case "TOP_RIGHT": return .topRight
            default: return .topLeft
            }
        }()
        
        let width = closeButtonConfigMap["width"] as? CGFloat
        let height = closeButtonConfigMap["height"] as? CGFloat
        let offsetX = closeButtonConfigMap["offsetX"] as? CGFloat ?? 0
        let offsetY = closeButtonConfigMap["offsetY"] as? CGFloat ?? 0
        
        let colorString = closeButtonConfigMap["color"] as? String
        let color: UIColor? = colorString != nil ? UIColor(hexString: colorString!) : .white
        
        let shadowOffsetX = closeButtonConfigMap["shadowOffsetX"] as? CGFloat ?? 0
        let shadowOffsetY = closeButtonConfigMap["shadowOffsetY"] as? CGFloat ?? 0
        let shadowBlur = closeButtonConfigMap["shadowBlur"] as? CGFloat ?? 0
        
        let shadowBlurStyle: ShopLiveBlurMaskStyle? = {
            if let styleInt = closeButtonConfigMap["shadowBlurStyle"] as? Int {
                return ShopLiveBlurMaskStyle(rawValue: styleInt)
            }
            if let styleNumber = closeButtonConfigMap["shadowBlurStyle"] as? NSNumber {
                return ShopLiveBlurMaskStyle(rawValue: styleNumber.intValue)
            }
            if let styleString = closeButtonConfigMap["shadowBlurStyle"] as? String {
                guard !styleString.isEmpty, styleString != "NORMAL" else {
                    return nil
                }
                switch styleString {
                case "SOLID": return .solid
                case "OUTER": return .outer
                case "INNER": return .inner
                default: return nil
                }
            }
            return nil
        }()
        
        let shadowColorString = closeButtonConfigMap["shadowColor"] as? String
        let shadowColor: UIColor? = shadowColorString != nil ? UIColor(hexString: shadowColorString!) : nil
        
        let imageStr = closeButtonConfigMap["imageStr"] as? String
        
        let closeButtonConfig = ShopLiveCloseButtonConfig(
            position: closeButtonPosition,
            width: width,
            height: height,
            offsetX: offsetX,
            offsetY: offsetY,
            color: color,
            shadowOffsetX: shadowOffsetX,
            shadowOffsetY: shadowOffsetY,
            shadowBlur: shadowBlur,
            shadowBlurStyle: shadowBlurStyle,
            shadowColor: shadowColor,
            imageStr: imageStr
        )
        
        let inAppPipConfig = ShopLiveInAppPipConfiguration(
            useCloseButton: args?["useCloseButton"] as? Bool ?? false,
            pipPosition: positionString == "topLeft" ? .topLeft :
                       positionString == "topRight" ? .topRight :
                       positionString == "bottomLeft" ? .bottomLeft :
                       positionString == "bottomRight" ? .bottomRight : .bottomRight,
            enableSwipeOut: args?["enableSwipeOut"] as? Bool ?? true,
            pipSize: .init(pipMaxSize: args?["pipMaxSize"] as? CGFloat ?? 300),
            pipRadius: args?["pipRadius"] as? CGFloat ?? 0,
            closeButtonConfig: closeButtonConfig
        )
        
        ShopLive.setPictureInPicturePadding(padding: .init(top: marginTop, left: marginLeft, bottom: marginBottom, right: marginRight))
        ShopLive.setInAppPipConfiguration(config: inAppPipConfig)
    }

    private func showPreview(campaignKey: String?) {
        guard campaignKey != nil else { return }

        ShopLive.delegate = self

        setOption()
        ShopLive.preview(with: campaignKey)
    }

    private func hidePreview() {
        ShopLive.close()
    }

    private func setShareScheme(shareSchemeUrl: String?) {
        guard let shareSchemeUrl = shareSchemeUrl else {
            return
        }
        ShopLive.setShareScheme(shareSchemeUrl, shareDelegate: nil)
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

    private func startPictureInPicture() {
        ShopLive.startPictureInPicture()
    }

    private func stopPictureInPicture() {
        ShopLive.stopPictureInPicture()
    }

    private func sendCommandMessage(command: String?, payload: [String:Any]?) {
        guard let command = command else {
            return
        }
        ShopLive.sendCommandMessage(command: command, payload: payload)
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
    
    public func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) {
        // callback을 임시 저장 (couponId를 key로 사용)
        pendingCallbacks[couponId] = result
        
        // 타임아웃 설정: 5초 후 자동 정리
        let timer = Timer.scheduledTimer(withTimeInterval: callbackTimeoutSeconds, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if let removedCallback = self.pendingCallbacks.removeValue(forKey: couponId) as? (ShopLiveCouponResult) -> Void {
                // 타임아웃으로 인한 실패 처리
                let timeoutResult = ShopLiveCouponResult(
                    couponId: couponId,
                    success: false,
                    message: "",
                    status: ShopLiveResultStatus.KEEP,
                    alertType: ShopLiveResultAlertType.TOAST
                )
                removedCallback(timeoutResult)
            }
            self.timeoutTimers.removeValue(forKey: couponId)
        }
        timeoutTimers[couponId] = timer
        
        // Flutter에 다운로드 쿠폰 이벤트 전송
        if let json = try? JSONEncoder().encode(HandleDownloadCoupon(couponId: couponId)) {
            if let eventSink = Self.eventHandleDownloadCoupon.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
        
        // Flutter에서 응답을 받을 때까지 대기 (callback.couponResult는 나중에 호출)
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
    }
    
    public func handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) {
        
        let payloadString: String
        if let dictPayload = payload as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: dictPayload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            payloadString = jsonString
        } else if let stringPayload = payload as? String {
            payloadString = stringPayload
        } else {
            payloadString = String(describing: payload ?? "")
        }
        
        // callback을 임시 저장 (id를 key로 사용)
        pendingCallbacks[id] = result
        
        // 타임아웃 설정: 5초 후 자동 정리
        let timer = Timer.scheduledTimer(withTimeInterval: callbackTimeoutSeconds, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            if let removedCallback = self.pendingCallbacks.removeValue(forKey: id) as? (ShopLiveCustomActionResult) -> Void {
                // 타임아웃으로 인한 실패 처리
                let timeoutResult = ShopLiveCustomActionResult(
                    id: id,
                    success: false,
                    message: "",
                    status: ShopLiveResultStatus.KEEP,
                    alertType: ShopLiveResultAlertType.TOAST
                )
                removedCallback(timeoutResult)
            }
            self.timeoutTimers.removeValue(forKey: id)
        }
        timeoutTimers[id] = timer
        
        // Flutter에 커스텀 액션 이벤트 전송
        if let json = try? JSONEncoder().encode(HandleCustomAction(id: id, type: type, payload: payloadString)) {
            if let eventSink = Self.eventHandleCustomAction.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
        
        // Flutter에서 응답을 받을 때까지 대기 (callback.customActionResult는 나중에 호출)
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

extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red, green, blue, alpha: CGFloat
        if hexSanitized.count == 8 {
            alpha = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            red = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x000000FF) / 255.0
        } else if hexSanitized.count == 6 {
            alpha = 1.0
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


