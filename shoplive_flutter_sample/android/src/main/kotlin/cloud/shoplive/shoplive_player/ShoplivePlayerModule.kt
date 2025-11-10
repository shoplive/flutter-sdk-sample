package cloud.shoplive.shoplive_player

import android.content.Context
import android.util.TypedValue
import android.os.Handler
import android.os.Looper
import androidx.annotation.Keep
import cloud.shoplive.sdk.*
import cloud.shoplive.sdk.common.ShopLivePreviewPositionConfig
import com.google.gson.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicReference
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

fun Float.dpToPx(context: Context): Float = TypedValue.applyDimension(
    TypedValue.COMPLEX_UNIT_DIP,
    this,
    context.resources.displayMetrics
)

class ShoplivePlayerModule : ShopliveBaseModule() {
    companion object {
        private const val EVENT_PLAYER_HANDLE_NAVIGATION = "event_player_handle_navigation"
        private const val EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON =
            "event_player_handle_download_coupon"
        private const val EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS =
            "event_player_change_campaign_status"
        private const val EVENT_PLAYER_CAMPAIGN_INFO = "event_player_campaign_info"
        private const val EVENT_PLAYER_ERROR = "event_player_error"
        private const val EVENT_PLAYER_HANDLE_CUSTOM_ACTION = "event_player_handle_custom_action"
        private const val EVENT_PLAYER_CHANGED_PLAYER_STATUS = "event_player_changed_player_status"
        private const val EVENT_PLAYER_SET_USER_NAME = "event_player_set_user_name"
        private const val EVENT_PLAYER_RECEIVED_COMMAND = "event_player_received_command"
        private const val EVENT_PLAYER_LOG = "event_player_log"
    }
    
    // callback 객체를 임시 저장하는 Map (id를 key로 사용)
    private val pendingCallbacks = ConcurrentHashMap<String, ShopLiveHandlerCallback>()
    
    // 타임아웃 관리를 위한 스케줄러
    private val timeoutScheduler: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()
    
    // 타임아웃 시간 (5초)
    private val callbackTimeoutSeconds = 5L

    private val eventHandleNavigation = AtomicReference<EventChannel.EventSink?>(null)
    private val eventHandleDownloadCoupon = AtomicReference<EventChannel.EventSink?>(null)
    private val eventChangeCampaignStatus = AtomicReference<EventChannel.EventSink?>(null)
    private val eventCampaignInfo = AtomicReference<EventChannel.EventSink?>(null)
    private val eventError = AtomicReference<EventChannel.EventSink?>(null)
    private val eventHandleCustomAction = AtomicReference<EventChannel.EventSink?>(null)
    private val eventChangedPlayerStatus = AtomicReference<EventChannel.EventSink?>(null)
    private val eventSetUserName = AtomicReference<EventChannel.EventSink?>(null)
    private val eventReceivedCommand = AtomicReference<EventChannel.EventSink?>(null)
    private val eventLog = AtomicReference<EventChannel.EventSink?>(null)

    private val eventPairs = listOf(
        EVENT_PLAYER_HANDLE_NAVIGATION to eventHandleNavigation,
        EVENT_PLAYER_HANDLE_DOWNLOAD_COUPON to eventHandleDownloadCoupon,
        EVENT_PLAYER_CHANGE_CAMPAIGN_STATUS to eventChangeCampaignStatus,
        EVENT_PLAYER_CAMPAIGN_INFO to eventCampaignInfo,
        EVENT_PLAYER_ERROR to eventError,
        EVENT_PLAYER_HANDLE_CUSTOM_ACTION to eventHandleCustomAction,
        EVENT_PLAYER_CHANGED_PLAYER_STATUS to eventChangedPlayerStatus,
        EVENT_PLAYER_SET_USER_NAME to eventSetUserName,
        EVENT_PLAYER_RECEIVED_COMMAND to eventReceivedCommand,
        EVENT_PLAYER_LOG to eventLog
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        eventPairs.forEach { (eventName, eventSink) ->
            initializeEvent(flutterPluginBinding.binaryMessenger, eventName, eventSink)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "player_play" -> {
                val campaignKey: String = call.argument<String?>("campaignKey") ?: return
                play(
                    ShopLivePlayerData(campaignKey).apply {
                        keepWindowStateOnPlayExecuted =
                            call.argument<Boolean?>("keepWindowStateOnPlayExecuted") ?: false
                        referrer = call.argument<String?>("referrer")
                    },
                )
            }

            "player_showPreview" -> {
                val campaignKey: String = call.argument<String?>("campaignKey") ?: return
                showPreview(
                    ShopLivePreviewData(campaignKey).apply {
                        useCloseButton = call.argument<Boolean?>("useCloseButton") ?: false
                        referrer = call.argument<String?>("referrer")
                        enabledSwipeOut = call.argument<Boolean?>("enableSwipeOut") ?: false
                        radius = (call.argument<Double?>("pipRadius") ?: 0.0).toFloat().dpToPx(activity)
                        width = (call.argument<Double?>("pipMaxSize") ?: 0).toFloat().dpToPx(activity).toInt()
                        height = (call.argument<Double?>("pipMaxSize") ?: 0).toFloat().dpToPx(activity).toInt()
                        marginTop = (call.argument<Double?>("marginTop") ?: 0).toFloat().dpToPx(activity).toInt()
                        marginBottom = (call.argument<Double?>("marginBottom") ?: 0).toFloat().dpToPx(activity).toInt()
                        marginLeft = (call.argument<Double?>("marginLeft") ?: 0).toFloat().dpToPx(activity).toInt()
                        marginRight = (call.argument<Double?>("marginRight") ?: 0).toFloat().dpToPx(activity).toInt()
                        position = when (call.argument<String?>("position")) {
                            "TOP_LEFT" -> ShopLivePreviewPositionConfig.TOP_LEFT
                            "TOP_RIGHT" -> ShopLivePreviewPositionConfig.TOP_RIGHT
                            "BOTTOM_LEFT" -> ShopLivePreviewPositionConfig.BOTTOM_LEFT
                            "BOTTOM_RIGHT" -> ShopLivePreviewPositionConfig.BOTTOM_RIGHT
                            else -> ShopLivePreviewPositionConfig.BOTTOM_RIGHT
                        }
                    }
                )
            }

            "player_hidePreview" -> {
                hidePreview()
                result.success(null)
                return
            }

            "player_setShareScheme" -> setShareScheme(
                call.argument<String>("shareSchemeUrl"),
            )

            "player_setEndpoint" -> setEndpoint(
                call.argument<String?>("endpoint"),
            )

            "player_setNextActionOnHandleNavigation" -> setNextActionOnHandleNavigation(
                call.argument<Int>("type"),
            )

            "player_setEnterPipModeOnBackPressed" -> setEnterPipModeOnBackPressed(
                call.argument<Boolean>("isEnterPipMode"),
            )

            "player_setMuteWhenPlayStart" -> setMuteWhenPlayStart(
                call.argument<Boolean>("isMute"),
            )

            "player_setMixWithOthers" -> setMixWithOthers(
                call.argument<Boolean>("isMixAudio"),
            )

            "player_useCloseButton" -> useCloseButton(
                call.argument<Boolean>("canUse"),
            )

            "player_close" -> close()
            "player_startPictureInPicture" -> startPictureInPicture()
            "player_stopPictureInPicture" -> stopPictureInPicture()
            "player_sendCommandMessage" -> sendCommandMessage(
                call.argument<String>("command"),
                call.argument<Map<String, Any?>>("payload"),
            )

            "player_addParameter" -> addParameter(
                call.argument<String>("key"),
                call.argument<String>("value"),
            )

            "player_removeParameter" -> removeParameter(
                call.argument<String>("key"),
            )

            "player_getSdkVersion" -> {
                result.success(BuildConfig.SHOPLIVE_SDK_VERSION)
            }

            "player_getPluginVersion" -> {
                result.success(BuildConfig.PLUGIN_VERSION)
            }

            "player_downloadCouponResult" -> {
                val couponId: String? = call.argument<String?>("couponId")
                if (couponId == null) {
                    result.error("INVALID_ARGUMENT", "couponId is required", null)
                    return
                }
                val success: Boolean = call.argument<Boolean?>("success") ?: true
                val message: String = call.argument<String?>("message") ?: "Success"
                val popupStatus: String = call.argument<String?>("popupStatus") ?: "HIDE"
                val alertType: String = call.argument<String?>("alertType") ?: "TOAST"
                
                val callback = pendingCallbacks.remove(couponId)
                if (callback != null) {
                    // Flutter에서 받은 값으로 callback 호출
                    val couponPopupStatus = when (popupStatus) {
                        "SHOW" -> ShopLive.CouponPopupStatus.SHOW
                        "HIDE" -> ShopLive.CouponPopupStatus.HIDE
                        "KEEP" -> ShopLive.CouponPopupStatus.KEEP
                        else -> ShopLive.CouponPopupStatus.HIDE
                    }
                    
                    val alertTypeEnum = when (alertType) {
                        "TOAST" -> ShopLive.CouponPopupResultAlertType.TOAST
                        "ALERT" -> ShopLive.CouponPopupResultAlertType.ALERT
                        else -> ShopLive.CouponPopupResultAlertType.TOAST
                    }
                    
                    callback.couponResult(success, message, couponPopupStatus, alertTypeEnum)
                }
                
                result.success(null)
            }

            "player_customActionResult" -> {
                val id: String? = call.argument<String?>("id")
                if (id == null) {
                    result.error("INVALID_ARGUMENT", "id is required", null)
                    return
                }
                val success: Boolean = call.argument<Boolean?>("success") ?: true
                val message: String = call.argument<String?>("message") ?: "Success"
                val popupStatus: String = call.argument<String?>("popupStatus") ?: "HIDE"
                val alertType: String = call.argument<String?>("alertType") ?: "TOAST"

                // 저장된 callback 가져오기
                val callback = pendingCallbacks.remove(id)
                if (callback != null) {
                    // Flutter에서 받은 값으로 callback 호출
                    val couponPopupStatus = when (popupStatus) {
                        "SHOW" -> ShopLive.CouponPopupStatus.SHOW
                        "HIDE" -> ShopLive.CouponPopupStatus.HIDE
                        "KEEP" -> ShopLive.CouponPopupStatus.KEEP
                        else -> ShopLive.CouponPopupStatus.HIDE
                    }

                    val alertTypeEnum = when (alertType) {
                        "TOAST" -> ShopLive.CouponPopupResultAlertType.TOAST
                        "ALERT" -> ShopLive.CouponPopupResultAlertType.ALERT
                        else -> ShopLive.CouponPopupResultAlertType.TOAST
                    }

                    callback.customActionResult(success, message, couponPopupStatus, alertTypeEnum)
                }

                result.success(null)
            }

            else -> {
                // Do nothing
            }
        }
    }

    // region ShopLive Public class
    private fun play(data: ShopLivePlayerData) {
        ShopLive.setHandler(shopLiveHandler)
        setOption()

        ShopLive.play(context, data)
    }

    private fun showPreview(data: ShopLivePreviewData) {
        ShopLive.setHandler(shopLiveHandler)
        setOption()

        ShopLive.showPreviewPopup(activity, data)
    }

    private fun hidePreview() {
        ShopLive.hidePreviewPopup()
    }

    private fun setShareScheme(shareSchemeUrl: String?) {
        shareSchemeUrl ?: return
        ShopLive.setShareScheme(shareSchemeUrl)
    }

    private fun setEndpoint(endpoint: String?) {
        endpoint ?: return
        ShopLive.setEndpoint(endpoint)
    }

    private fun setNextActionOnHandleNavigation(type: Int?) {
        val action = when (type) {
            ShopLive.ActionType.KEEP.ordinal -> ShopLive.ActionType.KEEP
            ShopLive.ActionType.CLOSE.ordinal -> ShopLive.ActionType.CLOSE
            ShopLive.ActionType.PIP.ordinal -> ShopLive.ActionType.PIP
            else -> ShopLive.ActionType.PIP
        }
        ShopLive.setNextActionOnHandleNavigation(action)
    }

    private fun setEnterPipModeOnBackPressed(isEnterPipMode: Boolean?) {
        isEnterPipMode ?: return
        ShopLive.setEnterPipModeOnBackPressed(isEnterPipMode)
    }

    private fun setMuteWhenPlayStart(isMute: Boolean?) {
        isMute ?: return
        ShopLive.setMuteWhenPlayStart(isMute)
    }

    private fun setMixWithOthers(isMixAudio: Boolean?) {
        isMixAudio ?: return
        ShopLive.setMixWithOthers(isMixAudio)
    }

    private fun useCloseButton(use: Boolean?) {
        // Do nothing
    }

    private fun close() {
        ShopLive.close()
        ShopLive.hidePreviewPopup()
    }

    private fun startPictureInPicture() {
        ShopLive.startPictureInPicture()
    }

    private fun stopPictureInPicture() {
        ShopLive.stopPictureInPicture()
    }

    private fun sendCommandMessage(command: String?, payload: Map<String, Any?>?) {
        command ?: return
        ShopLive.sendCommandMessage(command, payload ?: emptyMap())
    }

    private fun addParameter(key: String?, value: String?) {
        key ?: return
        ShopLive.addParameter(key, value)
    }

    private fun removeParameter(key: String?) {
        key ?: return
        ShopLive.removeParameter(key)
    }
    // endregion

    private val shopLiveHandler = object : ShopLiveHandler() {
        override fun handleNavigation(context: Context, url: String) {
            eventHandleNavigation.get()?.success(Gson().toJson(HandleNavigation(url)))
        }

        override fun handleDownloadCoupon(
            context: Context,
            couponId: String,
            callback: ShopLiveHandlerCallback
        ) {
            // callback을 임시 저장 (couponId를 key로 사용)
            pendingCallbacks[couponId] = callback
            
            // 타임아웃 설정: 5초 후 자동 정리
            timeoutScheduler.schedule({
                val removedCallback = pendingCallbacks.remove(couponId)
                if (removedCallback != null) {
                    // 메인 스레드에서 callback 호출 (WebView 호출을 위해)
                    Handler(Looper.getMainLooper()).post {
                        removedCallback.couponResult(
                            false,
                            "",
                            ShopLive.CouponPopupStatus.KEEP,
                            ShopLive.CouponPopupResultAlertType.TOAST
                        )
                    }
                }
            }, callbackTimeoutSeconds, TimeUnit.SECONDS)
            
            // Flutter에 다운로드 쿠폰 이벤트 전송
            eventHandleDownloadCoupon.get()
                ?.success(Gson().toJson(HandleDownloadCoupon(couponId)))
            
            // Flutter에서 응답을 받을 때까지 대기 (callback.couponResult는 나중에 호출)
        }

        override fun onChangeCampaignStatus(context: Context, campaignStatus: String) {
            eventChangeCampaignStatus.get()
                ?.success(Gson().toJson(ChangeCampaignStatus(campaignStatus)))
        }

        override fun onCampaignInfo(campaignInfo: JSONObject) {
            eventCampaignInfo.get()?.success(Gson().toJson(CampaignInfo(campaignInfo.toMap())))
        }

        override fun onError(context: Context, code: String, message: String) {
            eventError.get()?.success(Gson().toJson(Error(code, message)))
        }

        override fun handleCustomAction(
            context: Context, id: String, type: String, payload: String,
            callback: ShopLiveHandlerCallback
        ) {
            // callback을 임시 저장 (id를 key로 사용)
            pendingCallbacks[id] = callback
            
            // 타임아웃 설정: 5초 후 자동 정리
            timeoutScheduler.schedule({
                val removedCallback = pendingCallbacks.remove(id)
                if (removedCallback != null) {
                    // 메인 스레드에서 callback 호출 (WebView 호출을 위해)
                    Handler(Looper.getMainLooper()).post {
                        removedCallback.customActionResult(
                            false,
                            "",
                            ShopLive.CouponPopupStatus.KEEP,
                            ShopLive.CouponPopupResultAlertType.TOAST
                        )
                    }
                }
            }, callbackTimeoutSeconds, TimeUnit.SECONDS)
            
            // Flutter에 커스텀 액션 이벤트 전송
            eventHandleCustomAction.get()
                ?.success(Gson().toJson(HandleCustomAction(id, type, payload)))
            
            // Flutter에서 응답을 받을 때까지 대기 (callback.customActionResult 나중에 호출)
        }

        override fun handleShare(context: Context, data: ShopLivePlayerShareData) {
            Handler(Looper.getMainLooper()).postDelayed({
                super.handleShare(context, data)
            }, 100)
        }

        override fun onChangedPlayerStatus(
            isPipMode: Boolean,
            state: ShopLive.PlayerLifecycle
        ) {
            eventChangedPlayerStatus.get()
                ?.success(Gson().toJson(ChangedPlayerStatus(state.name)))
        }

        override fun onSetUserName(jsonObject: JSONObject) {
            eventSetUserName.get()?.success(Gson().toJson(UserInfo(jsonObject.toMap())))
        }

        override fun onReceivedCommand(context: Context, command: String, data: JSONObject) {
            if (command == "EVENT_LOG") {
                eventLog.get()
                    ?.success(
                        Gson().toJson(
                            ShopliveLog(
                                if (data.has("name")) data.getString("name") else "",
                                if (data.has("feature")) data.getString("feature") else "",
                                if (data.has("campaignKey")) data.getString("campaignKey") else "",
                                if (data.has("parameter")) {
                                    data.getJSONObject("parameter").toMap()
                                } else {
                                    emptyMap()
                                }
                            )
                        )
                    )
            } else {
                eventReceivedCommand.get()
                    ?.success(Gson().toJson(ReceivedCommand(command, data.toMap())))
            }
        }
    }

    @Keep
    private data class HandleNavigation(val url: String)

    @Keep
    private data class HandleDownloadCoupon(val couponId: String)

    @Keep
    private data class ChangeCampaignStatus(val campaignStatus: String)

    @Keep
    private data class CampaignInfo(val campaignInfo: Map<String, Any?>)

    @Keep
    private data class Error(val code: String, val message: String)

    @Keep
    private data class HandleCustomAction(
        val id: String,
        val type: String,
        val payload: String
    )

    @Keep
    private data class ChangedPlayerStatus(val status: String)

    @Keep
    private data class UserInfo(val userInfo: Map<String, Any?>)

    @Keep
    private data class ReceivedCommand(
        val command: String,
        val data: Map<String, Any?>
    )

    @Keep
    private data class ShopliveLog(
        val name: String,
        val feature: String,
        val campaignKey: String,
        val payload: Map<String, Any?>?
    )


    private fun setOption() {
        // tablet 화면 비율
        ShopLive.setKeepAspectOnTabletPortrait(true)

        // 플레이어 status bar 투명  (enabled / disabled)
        ShopLive.setStatusBarTransparent(true)

        // audio focus 잃었을 시 mute 기능
        ShopLive.setSoundFocusHandling(object : OnAudioFocusListener {
            override fun onGain() {
                ShopLive.unmute()
            }

            override fun onLoss() {
                ShopLive.mute()
            }

        })
    }
}