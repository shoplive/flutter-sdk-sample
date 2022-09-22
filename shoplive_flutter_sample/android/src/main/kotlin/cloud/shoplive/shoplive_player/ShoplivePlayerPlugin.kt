package cloud.shoplive.shoplive_player

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import cloud.shoplive.sdk.*
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicReference

/** ShoplivePlayerPlugin */
class ShoplivePlayerPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        private const val EVENT_HANDLE_NAVIGATION = "event_handle_navigation"
        private const val EVENT_HANDLE_DOWNLOAD_COUPON = "event_handle_download_coupon"
        private const val EVENT_CHANGE_CAMPAIGN_STATUS = "event_change_campaign_status"
        private const val EVENT_CAMPAIGN_INFO = "event_campaign_info"
        private const val EVENT_ERROR = "event_error"
        private const val EVENT_HANDLE_CUSTOM_ACTION = "event_handle_custom_action"
        private const val EVENT_CHANGED_PLAYER_STATUS = "event_changed_player_status"
        private const val EVENT_SET_USER_NAME = "event_set_user_name"
        private const val EVENT_RECEIVED_COMMAND = "event_received_command"
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    private val eventHandleNavigation = AtomicReference<EventChannel.EventSink?>(null)
    private val eventHandleDownloadCoupon = AtomicReference<EventChannel.EventSink?>(null)
    private val eventChangeCampaignStatus = AtomicReference<EventChannel.EventSink?>(null)
    private val eventCampaignInfo = AtomicReference<EventChannel.EventSink?>(null)
    private val eventError = AtomicReference<EventChannel.EventSink?>(null)
    private val eventHandleCustomAction = AtomicReference<EventChannel.EventSink?>(null)
    private val eventChangedPlayerStatus = AtomicReference<EventChannel.EventSink?>(null)
    private val eventSetUserName = AtomicReference<EventChannel.EventSink?>(null)
    private val eventReceivedCommand = AtomicReference<EventChannel.EventSink?>(null)

    private val eventPairs = listOf(
        EVENT_HANDLE_NAVIGATION to eventHandleNavigation,
        EVENT_HANDLE_DOWNLOAD_COUPON to eventHandleDownloadCoupon,
        EVENT_CHANGE_CAMPAIGN_STATUS to eventChangeCampaignStatus,
        EVENT_CAMPAIGN_INFO to eventCampaignInfo,
        EVENT_ERROR to eventError,
        EVENT_HANDLE_CUSTOM_ACTION to eventHandleCustomAction,
        EVENT_CHANGED_PLAYER_STATUS to eventChangedPlayerStatus,
        EVENT_SET_USER_NAME to eventSetUserName,
        EVENT_RECEIVED_COMMAND to eventReceivedCommand
    )

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        eventPairs.forEach { (eventName, eventSink) ->
            initializeEvent(flutterPluginBinding.binaryMessenger, eventName, eventSink)
        }
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "shoplive_player")
        channel.setMethodCallHandler(this)
    }

    private fun initializeEvent(
        binaryMessenger: BinaryMessenger,
        eventName: String,
        eventSink: AtomicReference<EventChannel.EventSink?>
    ) {
        val eventChannel = EventChannel(binaryMessenger, eventName)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink.set(events)
            }

            override fun onCancel(arguments: Any?) {
            }

        })
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setAccessKey" -> setAccessKey(
                call.argument<String>("accessKey"),
            )
            "play" -> play(
                call.argument<String>("campaignKey"),
                call.argument<Boolean>("keepWindowStateOnPlayExecuted"),
            )
            "setUser" -> setUser(
                call.argument<String>("userId"),
                call.argument<String>("userName"),
                call.argument<Int>("age"),
                call.argument<String>("gender"),
                call.argument<Int>("userScore"),
            )
            "setAuthToken" -> setAuthToken(
                call.argument<String>("authToken"),
            )
            "resetUser" -> resetUser()
            "setShareScheme" -> setShareScheme(
                call.argument<String>("shareSchemeUrl"),
            )
            "setEndpoint" -> setEndpoint(
                call.argument<String>("endpoint"),
            )
            "setNextActionOnHandleNavigation" -> setNextActionOnHandleNavigation(
                call.argument<Int>("type"),
            )
            "setEnterPipModeOnBackPressed" -> setEnterPipModeOnBackPressed(
                call.argument<Boolean>("isEnterPipMode"),
            )
            "setMuteWhenPlayStart" -> setMuteWhenPlayStart(
                call.argument<Boolean>("isMute"),
            )
            "close" -> close()
            "addParameter" -> addParameter(
                call.argument<String>("key"),
                call.argument<String>("value"),
            )
            "removeParameter" -> removeParameter(
                call.argument<String>("key"),
            )
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // region ShopLive Public class
    private fun play(campaignKey: String?, keepWindowStateOnPlayExecuted: Boolean?) {
        campaignKey ?: return

        ShopLive.setHandler(shopLiveHandler)
        setOption()
        if (keepWindowStateOnPlayExecuted == null) {
            ShopLive.play(context, campaignKey)
        } else {
            ShopLive.play(context, campaignKey, keepWindowStateOnPlayExecuted)
        }
    }

    private fun setUser(
        userId: String?,
        userName: String?,
        age: Int?,
        gender: String?,
        userScore: Int?
    ) {
        ShopLive.setUser(ShopLiveUser().apply {
            setUserId(userId)
            setUserName(userName)
            setAge(age ?: 0)
            setGender(
                when (gender) {
                    "m" -> ShopLiveUserGender.Male
                    "f" -> ShopLiveUserGender.Female
                    else -> ShopLiveUserGender.Neutral
                }
            )
            setUserScore(userScore ?: 0)
        })
    }

    private fun setAuthToken(authToken: String?) {
        ShopLive.setAuthToken(authToken ?: return)
    }

    private fun setAccessKey(accessKey: String?) {
        accessKey ?: return
        ShopLive.setAccessKey(accessKey)
    }

    private fun resetUser() {
        ShopLive.resetUser()
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
        type ?: return
        ShopLive.setNextActionOnHandleNavigation(ShopLive.ActionType.getType(type))
    }

    private fun setEnterPipModeOnBackPressed(isEnterPipMode: Boolean?) {
        isEnterPipMode ?: return
        ShopLive.setEnterPipModeOnBackPressed(isEnterPipMode)
    }

    private fun setMuteWhenPlayStart(isMute: Boolean?) {
        isMute ?: return
        ShopLive.setMuteWhenPlayStart(isMute)
    }

    private fun close() {
        ShopLive.close()
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

    private val shopLiveHandler = object : ShopLiveHandler {
        override fun handleNavigation(context: Context, url: String) {
            eventHandleNavigation.get()?.success(Gson().toJson(HandleNavigation(url)))
        }

        override fun handleDownloadCoupon(
            context: Context,
            couponId: String,
            callback: ShopLiveHandlerCallback
        ) {
            eventHandleDownloadCoupon.get()
                ?.success(Gson().toJson(HandleDownloadCoupon(couponId)))

            callback.couponResult(true, "Success", ShopLive.CouponPopupStatus.HIDE, ShopLive.CouponPopupResultAlertType.TOAST)
        }

        override fun onChangeCampaignStatus(context: Context, campaignStatus: String) {
            eventChangeCampaignStatus.get()
                ?.success(Gson().toJson(ChangeCampaignStatus(campaignStatus)))
        }

        override fun onCampaignInfo(campaignInfo: JSONObject) {
            eventCampaignInfo.get()?.success(Gson().toJson(CampaignInfo(campaignInfo)))
        }

        override fun onError(context: Context, code: String, message: String) {
            eventError.get()?.success(Gson().toJson(Error(code, message)))
        }

        override fun handleCustomAction(
            context: Context, id: String, type: String, payload: String,
            callback: ShopLiveHandlerCallback
        ) {
            eventHandleCustomAction.get()
                ?.success(Gson().toJson(HandleCustomAction(id, type, payload)))

            callback.couponResult(true, "Success", ShopLive.CouponPopupStatus.HIDE, ShopLive.CouponPopupResultAlertType.TOAST)
        }

        override fun handleShare(context: Context?, url: String?) {
            Handler(Looper.getMainLooper()).postDelayed({
                super.handleShare(context, url)
            }, 100)
        }

        override fun onChangedPlayerStatus(
            isPipMode: Boolean,
            state: ShopLive.PlayerLifecycle
        ) {
            eventChangedPlayerStatus.get()
                ?.success(Gson().toJson(ChangedPlayerStatus(isPipMode, state.getText())))
        }

        override fun onSetUserName(jsonObject: JSONObject) {
            eventSetUserName.get()?.success(Gson().toJson(UserInfo(jsonObject)))
        }

        override fun onReceivedCommand(context: Context, command: String, data: JSONObject) {
            eventReceivedCommand.get()
                ?.success(Gson().toJson(ReceivedCommand(command, data)))
        }
    }

    private data class HandleNavigation(val url: String)
    private data class HandleDownloadCoupon(val couponId: String)
    private data class ChangeCampaignStatus(val campaignStatus: String)
    private data class CampaignInfo(val campaignInfo: JSONObject)
    private data class Error(val code: String, val message: String)
    private data class HandleCustomAction(
        val id: String,
        val type: String,
        val payload: String
    )

    private data class ChangedPlayerStatus(val isPipMode: Boolean, val state: String)
    private data class UserInfo(val userInfo: JSONObject)
    private data class ReceivedCommand(
        val command: String,
        val data: JSONObject
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
