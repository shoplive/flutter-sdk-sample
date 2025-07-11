package cloud.shoplive.shoplive_player

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.Keep
import cloud.shoplive.sdk.*
import com.google.gson.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicReference

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
                        useCloseButton =
                            call.argument<Boolean?>("useCloseButton") ?: false
                        referrer = call.argument<String?>("referrer")
                    },
                )
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
            eventHandleDownloadCoupon.get()
                ?.success(Gson().toJson(HandleDownloadCoupon(couponId)))
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
            eventHandleCustomAction.get()
                ?.success(Gson().toJson(HandleCustomAction(id, type, payload)))

            callback.couponResult(
                true,
                "Success",
                ShopLive.CouponPopupStatus.HIDE,
                ShopLive.CouponPopupResultAlertType.TOAST
            )
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