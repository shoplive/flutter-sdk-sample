import Flutter
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK


struct SwiftShopliveShortformModuleEventName {
    static let EVENT_SHORTFORM_CLICK_PRODUCT = "event_shortform_click_product"
    static let EVENT_SHORTFORM_CLICK_BANNER = "event_shortform_click_banner"
    static let EVENT_SHORTFORM_SHARE = "event_shortform_share"
    static let EVENT_SHORTFORM_START = "event_shortform_start"
    static let EVENT_SHORTFORM_CLOSE = "event_shortform_close"
    static let EVENT_SHORTFORM_LOG = "event_shortform_log"
}


class SwiftShopliveShortformModule : SwiftShopliveBaseModule {
 
    
    
    typealias eventName = SwiftShopliveShortformModuleEventName
    
    public static var eventClickProduct = ShopliveEventData(eventName: eventName.EVENT_SHORTFORM_CLICK_PRODUCT, flutterEventSink: nil)
    public static var eventClickBanner = ShopliveEventData(eventName: eventName.EVENT_SHORTFORM_CLICK_BANNER, flutterEventSink: nil)
    public static var eventShare = ShopliveEventData(eventName: eventName.EVENT_SHORTFORM_SHARE, flutterEventSink: nil)
    public static var eventStart = ShopliveEventData(eventName: eventName.EVENT_SHORTFORM_START, flutterEventSink: nil)
    public static var eventClose = ShopliveEventData(eventName: eventName.EVENT_SHORTFORM_CLOSE, flutterEventSink: nil)
    public static var eventLog = ShopliveEventData(eventName: eventName.EVENT_SHORTFORM_LOG, flutterEventSink: nil)
    
    
    
    struct FlutterShopliveShortformUrlData : Codable {
        var url : String
    }
    
    
    struct FlutterShopLiveShareMetaData : Codable {
        var title : String?
        var description : String?
        var thumbnail : String?
        var shortsId : String?
        var shortsSrn : String?
    }
    
    struct FlutterShopLiveLogData : Codable {
        var command : String
        var payload : String?
    }
    
    struct FlutterShopLiveBaseData : Codable {
        
    }
    
    override var eventPairs : [String] {
        get {
            return [
                eventName.EVENT_SHORTFORM_CLICK_PRODUCT,
                eventName.EVENT_SHORTFORM_CLICK_BANNER,
                eventName.EVENT_SHORTFORM_SHARE,
                eventName.EVENT_SHORTFORM_START,
                eventName.EVENT_SHORTFORM_CLOSE,
                eventName.EVENT_SHORTFORM_LOG
            ]
        }
        set {
            
        }
    }
    
    
    override func initializeEvent(binaryMessenger: FlutterBinaryMessenger, eventName: String) {
        let eventChannel = FlutterEventChannel(name: eventName, binaryMessenger: binaryMessenger)
        let streamHandler = StreamHandler(eventName: eventName)
        eventChannel.setStreamHandler(streamHandler)
    }
    
    
    override func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any] else { return }
        switch call.method {
        case "shortform_play":
            let shortsId = args["shortsId"] as? String
            let shortsSrn = args["shortsSrn"] as? String
            let tags = args["tags"] as? [String]
            let tagOperator = args["tagSearchOperator"] as? String
            let brands = args["brands"] as? [String]
            let shuffle = args["shuffle"] as? Bool
            let referrer = args["referrer"] as? String
            self.play(reference: nil, shortsId: shortsId,
                      shortsSrn: shortsSrn,
                      tags: tags,
                      tagSearchOperator: tagOperator,
                      brands: brands,
                      shuffle: shuffle,
                      referrer: referrer)
        case "shortform_close":
            self.close()
        default:
            break
        }
    }
    
    
    
    private func play(reference : String?, shortsId : String?, shortsSrn : String?, tags : [String]?, tagSearchOperator : String?, brands : [String]?, shuffle : Bool?, referrer : String?) {
        
        var _tagSearchOperator : ShopLiveTagSearchOperator?
        if let op = tagSearchOperator {
            if op == "OR" {
                _tagSearchOperator = .OR
            }
            else {
                _tagSearchOperator = .AND
            }
        }
        
        ShopLiveShortform.ShortsReceiveInterface.setNativeHandler(self)
        ShopLiveShortform.ShortsReceiveInterface.setHandler(self)
        
        let requestData = ShopLiveShortformCollectionData(reference: reference,
                                                          shortsId: shortsId,
                                                          shortsSrn: shortsSrn,
                                                          tags: tags,
                                                          tagSearchOperator: _tagSearchOperator,
                                                          brands: brands,
                                                          shuffle: shuffle,
                                                          referrer: referrer)
        ShopLiveShortform.play(requestData: requestData)
    }
    
    private func close() {
        ShopLiveShortform.close()
    }
    

}
extension SwiftShopliveShortformModule : ShopLiveShortformNativeHandlerDelegate {
    func handleProductItem(shortsId: String, shortsSrn: String, product: ShopLiveShortformSDK.Product) {
        if let json = try? JSONEncoder().encode(product) {
            if let eventSink = Self.eventClickProduct.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String, shortsDetail: ShopLiveShortformSDK.ShortsDetail) {
        if let json = try? JSONEncoder().encode(FlutterShopliveShortformUrlData(url: scheme)) {
            if let eventSink = Self.eventClickBanner.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
}
extension SwiftShopliveShortformModule : ShopLiveShortformReceiveHandlerDelegate {
    func onDidAppear() {
        if let json = try? JSONEncoder().encode(FlutterShopLiveBaseData()) {
            if let eventSink = Self.eventStart.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    func onError(error: Error) {
        
    }
    
    func onDidDisAppear() {
        if let json = try? JSONEncoder().encode(FlutterShopLiveBaseData()) {
            if let eventSink = Self.eventClose.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    func onEvent(command: String, payload: String?) {
        let model = FlutterShopLiveLogData(command: command, payload: payload)
        if let json = try? JSONEncoder().encode(model) {
            if let eventSink = Self.eventLog.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
        }
    }
    
    func handleShare(shareMetadata: ShopLiveShareMetaData) {
        let flutterShopLiveMetaData = FlutterShopLiveShareMetaData(title: shareMetadata.title,
                                                                   description: shareMetadata.description,
                                                                   thumbnail: shareMetadata.thumbnail,
                                                                   shortsId: shareMetadata.shortsId,
                                                                   shortsSrn: shareMetadata.shortsSrn)
        
        if let json = try? JSONEncoder().encode(flutterShopLiveMetaData) {
            if let eventSink = Self.eventShare.flutterEventSink {
                eventSink(String(data: json, encoding: .utf8))
            }
            
        }
    }
    
}


fileprivate class StreamHandler: NSObject, FlutterStreamHandler {
    typealias eventName = SwiftShopliveShortformModuleEventName
    typealias module = SwiftShopliveShortformModule
    let eventname: String
    
    init(eventName: String) {
        self.eventname = eventName
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        switch (eventname) {
        case eventName.EVENT_SHORTFORM_CLICK_PRODUCT:
            module.eventClickProduct.flutterEventSink = events
        case eventName.EVENT_SHORTFORM_CLICK_BANNER:
            module.eventClickBanner.flutterEventSink = events
        case eventName.EVENT_SHORTFORM_START:
            module.eventStart.flutterEventSink = events
        case eventName.EVENT_SHORTFORM_SHARE:
            module.eventShare.flutterEventSink = events
        case eventName.EVENT_SHORTFORM_CLOSE:
            module.eventClose.flutterEventSink = events
        case eventName.EVENT_SHORTFORM_LOG:
            module.eventLog.flutterEventSink = events
        default: return nil
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

