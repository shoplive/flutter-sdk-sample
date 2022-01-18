import UIKit
import Flutter
import ShopLiveSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    let LIVE_CHANNEL = "cloud.shoplive.sdk/live"
    let MESSAGE_CHANNEL = "cloud.shoplive.sdk/message"

    var engine: FlutterEngine?
    var controller: FlutterViewController?

    private var channel: FlutterMethodChannel?
    private var messageChannel: FlutterBasicMessageChannel?

    private var channelHandler: FlutterMethodCallHandler?

    let tf = UITextField(frame: .init(origin: .init(x: 100, y: 100), size: .init(width: 1, height: 1)))

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        controller = self.window.rootViewController as? FlutterViewController
        engine = controller?.engine
        guard let controller = controller, let binaryMessenger: FlutterBinaryMessenger = controller.binaryMessenger as? FlutterBinaryMessenger else {
            return initApplication(application, launchOptions: launchOptions)
        }

        controller.view.addSubview(tf)

        shopLiveInit()

        flutterInit(binaryMessenger: binaryMessenger)
        return initApplication(application, launchOptions: launchOptions)
    }

    func initApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate {
    func shopLiveInit() {
        ShopLive.delegate = self
    }

    func flutterInit(binaryMessenger: FlutterBinaryMessenger) {
        messageChannel = FlutterBasicMessageChannel(name: MESSAGE_CHANNEL, binaryMessenger: binaryMessenger , codec: FlutterStringCodec.sharedInstance())
        channel = .init(name: LIVE_CHANNEL, binaryMessenger: binaryMessenger)
        channel?.setMethodCallHandler({ call, result in

            switch call.method {
            case "play":

                if let args = call.arguments as? String, let config = args.jsonToDict() {

                    guard let campaignInfo = config["campaignInfo"] as? [String: Any] else {
                        result("ShopLive SDK 연결 실패!!")
                        return
                    }

                    guard let accessKey = campaignInfo["accessKey"] as? String, let campaignKey = campaignInfo["campaignKey"] as? String else {
                        result("ShopLive SDK 연결 실패!!")
                        return
                    }

                    self.setupShopliveOptions(options: config)

                    self.tf.becomeFirstResponder()
                    // Play
                    ShopLive.configure(with: accessKey)
                    ShopLive.play(with: campaignKey)
                    result("ShopLive SDK 연결 성공!!")
                } else {
                    result("ShopLive SDK 연결 실패!!")
                }
                break

            case "preview":

                if let args = call.arguments as? String, let config = args.jsonToDict() {

                    guard let campaignInfo = config["campaignInfo"] as? [String: Any] else {
                        result("ShopLive SDK 연결 실패!!")
                        return
                    }

                    guard let accessKey = campaignInfo["accessKey"] as? String, let campaignKey = campaignInfo["campaignKey"] as? String else {
                        result("ShopLive SDK 연결 실패!!")
                        return
                    }

                    self.setupShopliveOptions(options: config)

                    // Preview
                    ShopLive.configure(with: accessKey)
                    ShopLive.preview(with: campaignKey) {
                        ShopLive.play(with: campaignKey)
                    }
                    result("ShopLive SDK 연결 성공!!")
                } else {
                    result("ShopLive SDK 연결 실패!!")
                }
                break
            default:
                break
            }


        })
    }

    func setupShopliveOptions(options: [String: Any]) {

        guard let campaignInfo = options["campaignInfo"] as? [String: Any] else {
            return
        }

        var shopLiveUser: ShopLiveUser? = nil
        var token: String? = nil
        var pipPosition: ShopLive.PipPosition = .bottomRight
        var keepAspectOnTabletPortrait: Bool = true
        var keepPlayVideoOnHeadphoneUnplugged: Bool = false
        var autoResumeVideoOnCallEnded: Bool = false
        var loadingAnimation: Bool = false
        var chatViewFont: Bool = false

        // ShopLive User setting
        if let userJson = campaignInfo["user"] as? String, let user = userJson.jsonToDict() {
            let userId: String = (user["id"] as? String) ?? ""
            let userName: String = (user["name"] as? String) ?? ""
            let userAge: Int = (user["age"] as? Int) ?? -1
            let userGender: String = (user["gender"] as? String) ?? ""
            let userScore: Int? = (user["userScore"] as? Int)

            var gender: ShopLiveUser.Gender = .neutral
            switch userGender {
            case "m":
                gender = .male
                break
            case "f":
                gender = .female
                break
            default:
                break
            }

            shopLiveUser = ShopLiveUser(id: userId, name: userName, gender: gender, age: userAge)
            shopLiveUser?.add(["userScore" : userScore])
        }
        ShopLive.user = shopLiveUser

        // Authtoken ( JWT Token ) setting
        if let jwtToken = campaignInfo["token"] as? String {
            token = jwtToken
        }
        ShopLive.authToken = token

        if let progressColor = options["progressColor"] as? String {
            ShopLive.indicatorColor = UIColor(hex: progressColor) ?? .white
        }

        if let shareUrl = options["urlScheme"] as? String {

            /**
                - shareUrl
                    Url for share
                - custom
                    - Setting to use custom share action.
                    - Set to nil to use as the iOS default.
             */

            // Custom setting for share
            let customShare: (() -> Void)? = {
                self.channel?.invokeMethod("SHARE", arguments: shareUrl, result: { result in
                    if let result = result as? String, let shareResult = result.jsonToDict() {
                        let message: String = (shareResult["message"] as? String) ?? "공유하기"
                        let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        }))

                        DispatchQueue.main.async {
                            ShopLive.viewController?.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }

            ShopLive.setShareScheme(shareUrl, custom: customShare)
        }

        // Picture In Picture scale setting
        if let pipScaleString: NSString = options["pipScale"] as? NSString {
            let pipScale = CGFloat(pipScaleString.floatValue)
            ShopLive.pipScale = pipScale
        }

        // Picture In Picture Presenting Position Setting
        if let pipPositionString: String = options["pipPosition"] as? String {
            switch pipPositionString {
            case "topLeft":
                pipPosition = .topLeft
                break
            case "topRight":
                pipPosition = .topRight
                break
            case "bottomLeft":
                pipPosition = .bottomLeft
                break
            case "bottomRight":
                pipPosition = .bottomRight
                break
            default:
                break
            }

            ShopLive.pipPosition = pipPosition
        }

        // Keep aspect on Tablet Setting
        if let keepAspectOnTabletPortraitBool = options["keepAspectOnTabletPortrait"] as? Bool {
            keepAspectOnTabletPortrait = keepAspectOnTabletPortraitBool
        }
        ShopLive.setKeepAspectOnTabletPortrait(keepAspectOnTabletPortrait)

        // Keep play video on headphone unplugged setting
        if let keepPlayVideoOnHeadphoneUnpluggedBool = options["keepPlayVideoOnHeadphoneUnplugged"] as? Bool {
            keepPlayVideoOnHeadphoneUnplugged = keepPlayVideoOnHeadphoneUnpluggedBool
        }
        ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(keepPlayVideoOnHeadphoneUnplugged)

        // Auto resume video on call ended setting
        if let autoResumeVideoOnCallEndedBool = options["autoResumeVideoOnCallEnded"] as? Bool {
            autoResumeVideoOnCallEnded = autoResumeVideoOnCallEndedBool
        }
        ShopLive.setAutoResumeVideoOnCallEnded(autoResumeVideoOnCallEnded)

        // Loading animation setting
        if let loadingAnimationBool = options["loadingAnimation"] as? Bool {
            loadingAnimation = loadingAnimationBool
        }
        if loadingAnimation {
            var images: [UIImage] = []

            for i in 1...11 {
                images.append(.init(named: "loading\(i)")!)
            }

            ShopLive.setLoadingAnimation(images: images)
        }

        // ChatView font setting
        if let chatViewTypefaceBool = options["chatViewTypeface"] as? Bool {
            chatViewFont = chatViewTypefaceBool
        }
        if chatViewFont {
            let inputDefaultFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let sendButtonDefaultFont = UIFont.systemFont(ofSize: 14, weight: .medium)
            if let nanumBrushFont = UIFont(name: "NanumBrush", size: 16) {
                ShopLive.setChatViewFont(inputBoxFont: nanumBrushFont, sendButtonFont: nanumBrushFont)
            } else {
                ShopLive.setChatViewFont(inputBoxFont: inputDefaultFont, sendButtonFont: sendButtonDefaultFont)
            }
        }

    }
}

/// shoplive delegate
extension AppDelegate: ShopLiveSDKDelegate {
    func makeCallbackJson(command: String, payload: Dictionary<String, Any>?) -> String {
        var jsonDict = Dictionary<String, Any>()
        var value = Dictionary<String, Any>()

        jsonDict["command"] = command
        if let payload = payload {
            payload.forEach { (key: String, val: Any) in
                value[key] = val
            }

            jsonDict["value"] = value
        }

        return jsonDict.toJsonString()
    }

    func handleNavigation(with url: URL) {
        var value = Dictionary<String, Any>()
        value["url"] = url.absoluteString

        let callback = makeCallbackJson(command: "NAVIGATION", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func handleChangeCampaignStatus(status: String) {
        var value = Dictionary<String, Any>()
        value["campaignStatus"] = status

        let callback = makeCallbackJson(command: "CHANGE_CAMPAIGN_STATUS", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func handleError(code: String, message: String) {
        var value = Dictionary<String, Any>()
        value["code"] = code
        value["message"] = message

        let callback = makeCallbackJson(command: "ERROR", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func handleCampaignInfo(campaignInfo: [String : Any]) {
        var value = Dictionary<String, Any>()
        value["campaignInfo"] = campaignInfo

        let callback = makeCallbackJson(command: "CAMPAIGN_INFO", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func handleCommand(_ command: String, with payload: Any?) {
        var value = Dictionary<String, Any>()
        value["command"] = command
        value["payload"] = payload

        let callback = makeCallbackJson(command: "COMMAND", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func onSetUserName(_ payload: [String : Any]) {
        var value = Dictionary<String, Any>()
        value["payload"] = payload

        let callback = makeCallbackJson(command: "CHANGED_PLAYER_STATUS", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func handleReceivedCommand(_ command: String, with payload: Any?) {

        var value = Dictionary<String, Any>()
        value["payload"] = payload

        let callback = makeCallbackJson(command: "ON_SUCCESS_CAMPAIGN_JOIN", payload: value)

        messageChannel?.sendMessage(callback)
    }

    func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void) {
        channel?.invokeMethod("DOWNLOAD_COUPON", arguments: nil, result: { result in
            if let result = result as? String, let couponResult = result.jsonToDict() {
                let isSuccess: Bool = (couponResult["isDownloadSuccess"] as? Bool) ?? true
                let message: String = (couponResult["message"] as? String) ?? "다운로드 쿠폰"
                let statusResult = (couponResult["popupStatus"] as? String) ?? "HIDE"
                let alertResult = (couponResult["alertType"] as? String) ?? "TOAST"
                let status: ResultStatus = (statusResult == "SHOW") ? .SHOW : .HIDE
                let alertType: ResultAlertType = (alertResult == "ALERT") ? .ALERT : .TOAST
                DispatchQueue.main.async {
                    let result = CouponResult(couponId: couponId, success: isSuccess, message: message, status: status, alertType: alertType)
                    completion(result)
                }
            }
        })
    }

    func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void) {
        channel?.invokeMethod("CUSTOM_ACTION", arguments: nil, result: { result in
            if let result = result as? String, let couponResult = result.jsonToDict() {
                let isSuccess: Bool = (couponResult["isSuccess"] as? Bool) ?? true
                let message: String = (couponResult["message"] as? String) ?? "커스텀 액션"
                let statusResult = (couponResult["popupStatus"] as? String) ?? "SHOW"
                let alertResult = (couponResult["alertType"] as? String) ?? "ALERT"
                let status: ResultStatus = (statusResult == "SHOW") ? .SHOW : .HIDE
                let alertType: ResultAlertType = (alertResult == "ALERT") ? .ALERT : .TOAST
                DispatchQueue.main.async {
                    let result = CustomActionResult(id: id, success: isSuccess, message: message, status: status, alertType: alertType)
                    completion(result)
                }
            }
        })
    }
}

extension Dictionary {
    func toJson() -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return data
        } catch {
            return nil
        }
    }

    func toJsonString() -> String {
        guard let data = toJson() else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    
}

extension String {
    func jsonToDict() -> [String:Any]? {
        if let data = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                return json
            } catch {
            }
        }
        return nil
    }
}

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
    }

    // let's suppose alpha is the first component (ARGB)
    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }

    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if cString.count != 6 {
            self.init(hex: "ffffff") // return red color for wrong hex input
          return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
      }
}
