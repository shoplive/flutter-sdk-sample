package cloud.shoplive.shoplive_player

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import cloud.shoplive.sdk.*
import com.google.gson.*
import com.google.gson.reflect.TypeToken
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.lang.reflect.Type
import java.util.concurrent.atomic.AtomicReference
import kotlin.math.ceil


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
        private const val EVENT_LOG = "event_log"
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
    private val eventLog = AtomicReference<EventChannel.EventSink?>(null)

    private val eventPairs = listOf(
        EVENT_HANDLE_NAVIGATION to eventHandleNavigation,
        EVENT_HANDLE_DOWNLOAD_COUPON to eventHandleDownloadCoupon,
        EVENT_CHANGE_CAMPAIGN_STATUS to eventChangeCampaignStatus,
        EVENT_CAMPAIGN_INFO to eventCampaignInfo,
        EVENT_ERROR to eventError,
        EVENT_HANDLE_CUSTOM_ACTION to eventHandleCustomAction,
        EVENT_CHANGED_PLAYER_STATUS to eventChangedPlayerStatus,
        EVENT_SET_USER_NAME to eventSetUserName,
        EVENT_RECEIVED_COMMAND to eventReceivedCommand,
        EVENT_LOG to eventLog
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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
                call.argument<Map<String, String>>("parameters"),
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
            "setMixWithOthers" -> setMuteWhenPlayStart(
                call.argument<Boolean>("isMixAudio"),
            )
            "useCloseButton" -> setMuteWhenPlayStart(
                call.argument<Boolean>("canUse"),
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
        userScore: Int?,
        parameters: Map<String, String>? = null
    ) {
        ShopLive.setUser(ShopLiveUser().apply {
            this.userId = userId
            this.userName = userName
            this.age = age ?: 0
            this.gender =
                when (gender) {
                    "m" -> ShopLiveUserGender.Male
                    "f" -> ShopLiveUserGender.Female
                    else -> ShopLiveUserGender.Neutral
                }
            this.userScore = userScore ?: 0
            parameters?.forEach { (key, value) ->
                addCustomParameter(key, value)
            }
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

    private fun setMixWithOthers(isMixAudio: Boolean?) {
        isMixAudio ?: return
        ShopLive.setMixWithOthers(isMixAudio)
    }

    private fun useCloseButton(use: Boolean?) {
        // Do nothing
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

            callback.couponResult(
                true,
                "Success",
                ShopLive.CouponPopupStatus.HIDE,
                ShopLive.CouponPopupResultAlertType.TOAST
            )
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
                ?.success(Gson().toJson(ChangedPlayerStatus(state.getText())))
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

    private data class HandleNavigation(val url: String)
    private data class HandleDownloadCoupon(val couponId: String)
    private data class ChangeCampaignStatus(val campaignStatus: String)
    private data class CampaignInfo(val campaignInfo: Map<String, Any?>)
    private data class Error(val code: String, val message: String)
    private data class HandleCustomAction(
        val id: String,
        val type: String,
        val payload: String
    )

    private data class ChangedPlayerStatus(val status: String)
    private data class UserInfo(val userInfo: Map<String, Any?>)
    private data class ReceivedCommand(
        val command: String,
        val data: Map<String, Any?>
    )

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

private fun JSONObject.toMap(): Map<String, Any?> {
    return kotlin.runCatching {
        GsonBuilder().registerTypeAdapter(Map::class.java, MapDeserializer()).create()
            .fromJson<Map<String, Any?>>(
                this.toString(),
                object : TypeToken<Map<String, Any?>>() {}.type
            ) ?: emptyMap()
    }.getOrElse { emptyMap() }
}

private class MapDeserializer : JsonDeserializer<Map<String, Any?>> {
    @Throws(JsonParseException::class)
    override fun deserialize(
        json: JsonElement, typeOfT: Type?,
        context: JsonDeserializationContext?
    ): Map<String, Any?>? {
        return read(json) as? Map<String, Any?>
    }

    fun read(jsonElement: JsonElement): Any? {
        if (jsonElement.isJsonArray) {
            val arr = jsonElement.asJsonArray
            return arr.map { read(it) }
        } else if (jsonElement.isJsonObject) {
            val obj = jsonElement.asJsonObject
            val entitySet = obj.entrySet()
            return entitySet.associate { it.key to read(it.value) }
        } else if (jsonElement.isJsonPrimitive) {
            val prim = jsonElement.asJsonPrimitive
            if (prim.isBoolean) {
                return prim.asBoolean
            } else if (prim.isString) {
                return prim.asString
            } else if (prim.isNumber) {
                val num = prim.asNumber
                return if (ceil(num.toDouble()) == num.toLong().toDouble())
                    num.toLong() else {
                    num.toDouble()
                }
            }
        }
        return null
    }
}