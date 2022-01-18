package cloud.shoplive.shoplive_flutter_sample

import android.content.Intent
import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.Log
import android.widget.Toast
import android.provider.Settings
import cloud.shoplive.sdk.*
import org.json.JSONObject
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.core.content.res.ResourcesCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StringCodec

class MainActivity: FlutterActivity() {

    companion object {
        const val TAG = "shoplive"

        const val LIVE_CHANNEL = "cloud.shoplive.sdk/live"
        const val MESSAGE_CHANNEL = "cloud.shoplive.sdk/message"
    }

    private lateinit var liveChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messageChannel = BasicMessageChannel(flutterEngine.dartExecutor.binaryMessenger, MESSAGE_CHANNEL, StringCodec.INSTANCE)

        liveChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIVE_CHANNEL)
        liveChannel.setMethodCallHandler { call, result ->
            Log.d(TAG, "method >> ${call.method}, arguments >> ${call.arguments}")
            when(call.method) {
                "preview", "play" -> {
                    // java.lang.ClassCastException
                    // var loadingProgressColor = call.argument<String>("progressColor")
                    // var shareSchemeUrl = call.argument<String>("urlScheme")

                    val config = JSONObject(call.arguments.toString())
                    val campaignInfo = config.getJSONObject("campaignInfo")
                    val accessKey = campaignInfo.getString("accessKey")
                    val campaignKey = campaignInfo.getString("campaignKey")

                    var shopLiveUser: ShopLiveUser? = null
                    var token: String? = null
                    var loadingProgressColor: String? = null
                    var shareSchemeUrl: String? = null
                    var pipRatio: String? = null
                    var keepAspectOnTabletPortrait: Boolean? = null
                    var keepPlayVideoOnHeadphoneUnplugged: Boolean? = null
                    var autoResumeVideoOnCallEnded: Boolean? = null
                    var loadingAnimation: Boolean? = null
                    var chatViewTypeface: Boolean? = null
                    var enterPipModeOnBackPressed: Boolean? = null

                    try {
                        val user = campaignInfo.getJSONObject("user")
                        shopLiveUser = ShopLiveUser().apply {
                            userId = user.getString("id")
                            userName = user.getString("name")
                            age = user.getInt("age")
                            when(user.getString("gender")) {
                                "m" -> ShopLiveUserGender.Male
                                "f" -> ShopLiveUserGender.Female
                                else -> ShopLiveUserGender.Neutral
                            }
                            userScore = user.getInt("userScore")
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        token = campaignInfo.getString("token")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        loadingProgressColor = config.getString("progressColor")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        shareSchemeUrl = config.getString("urlScheme")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        pipRatio = config.getString("pipRatio")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        keepAspectOnTabletPortrait = config.getBoolean("keepAspectOnTabletPortrait")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        keepPlayVideoOnHeadphoneUnplugged = config.getBoolean("keepPlayVideoOnHeadphoneUnplugged")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        autoResumeVideoOnCallEnded = config.getBoolean("autoResumeVideoOnCallEnded")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        loadingAnimation = config.getBoolean("loadingAnimation")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        chatViewTypeface = config.getBoolean("chatViewTypeface")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    try {
                        enterPipModeOnBackPressed = config.getBoolean("enterPipModeOnBackPressed")
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    ShopLive.setAccessKey(accessKey)

                    if (shopLiveUser != null) {
                        ShopLive.setUser(shopLiveUser)
                    } else {
                        token?.let {
                            ShopLive.setAuthToken(it)
                        }
                    }

                    loadingProgressColor?.let {
                        ShopLive.setLoadingProgressColor(it)
                    }

                    shareSchemeUrl?.let {
                        ShopLive.setShareScheme(it)
                    }

                    pipRatio?.let {
                        when(it) {
                            "1x1"   -> ShopLive.setPIPRatio(ShopLivePIPRatio.RATIO_1X1)
                            "1x2"   -> ShopLive.setPIPRatio(ShopLivePIPRatio.RATIO_1X2)
                            "2x3"   -> ShopLive.setPIPRatio(ShopLivePIPRatio.RATIO_2X3)
                            "3x4"   -> ShopLive.setPIPRatio(ShopLivePIPRatio.RATIO_3X4)
                            else    -> ShopLive.setPIPRatio(ShopLivePIPRatio.RATIO_9X16)
                        }
                    }

                    keepAspectOnTabletPortrait?.let {
                        ShopLive.setKeepAspectOnTabletPortrait(it)
                    }

                    keepPlayVideoOnHeadphoneUnplugged?.let {
                        ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(it)
                    }

                    autoResumeVideoOnCallEnded?.let {
                        ShopLive.setAutoResumeVideoOnCallEnded(it)
                    }

                    loadingAnimation?.let {
                        if (it == true) {
                            ShopLive.setLoadingAnimation(R.drawable.progress_animation1)
                        }
                    }

                    chatViewTypeface?.let {
                        if (it == true) {
                            // 나눔 고딕
                            val nanumGothic = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                resources.getFont(R.font.nanumgothicbold)
                            } else {
                                ResourcesCompat.getFont(this, R.font.nanumgothicbold)
                            }
                            ShopLive.setChatViewTypeface(nanumGothic)
                        } else {
                            ShopLive.setChatViewTypeface(null)
                        }
                    }

                    enterPipModeOnBackPressed?.let {
                        ShopLive.setEnterPipModeOnBackPressed(it)
                    }

                    if (call.method.compareTo("play") == 0) {
                        ShopLive.play(campaignKey)
                    } else {
                        if (Settings.canDrawOverlays(this)) {
                            ShopLive.showPreview(campaignKey)
                        } else {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:${packageName}")
                            )
                            startActivityForResult(intent, 0)
                        }
                    }

                    result.success("ShopLive SDK 연결 성공!!")
                }
            }
        }

        // shoplive handler
        ShopLive.setHandler(object : ShopLiveHandler {
            override fun handleNavigation(url: String) {
                Log.d(TAG, "handleNavigation >> $url")

                val jsonObj = JSONObject()
                val value = JSONObject()
                value.put("url", url)

                jsonObj.put("command", "NAVIGATION")
                jsonObj.put("value", value)
                messageChannel.send(jsonObj.toString())
            }

            override fun handleDownloadCoupon(
                context: Context,
                couponId: String,
                callback: ShopLiveHandlerCallback) {

                liveChannel.invokeMethod("DOWNLOAD_COUPON", couponId, object: MethodChannel.Result{
                    override fun success(result: Any?) {
                        Log.i("DOWNLOAD_COUPON", "result: $result")

                        val jsonObj = JSONObject(result.toString())
                        val isDownloadSuccess = jsonObj.getBoolean("isDownloadSuccess")
                        val message = jsonObj.getString("message")
                        val popupStatus = jsonObj.getString("popupStatus")
                        val alertType = jsonObj.getString("alertType")

                        callback.couponResult(isDownloadSuccess, message, popupStatus, alertType)
                    }

                    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                        Log.i("DOWNLOAD_COUPON", "error: $errorCode, $errorMessage, $errorDetails")
                    }

                    override fun notImplemented() {
                        Log.i("DOWNLOAD_COUPON", "notImplemented")
                    }
                })
            }

            override fun onChangeCampaignStatus(context: Context, campaignStatus: String) {
                Log.d(TAG, "campaignStatus >> $campaignStatus")

                val jsonObj = JSONObject()
                val value = JSONObject()
                value.put("campaignStatus", campaignStatus)

                jsonObj.put("command", "CHANGE_CAMPAIGN_STATUS")
                jsonObj.put("value", value)
                messageChannel.send(jsonObj.toString())
            }

            override fun onCampaignInfo(campaignInfo: JSONObject) {
                Log.d(TAG, campaignInfo.toString())

                val jsonObj = JSONObject()
                val value = JSONObject()
                value.put("campaignInfo", campaignInfo)

                jsonObj.put("command", "CAMPAIGN_INFO")
                jsonObj.put("value", value)
                messageChannel.send(jsonObj.toString())
            }

            override fun onError(context: Context, code: String, message: String) {
                Log.d(TAG, "code:$code, message:$message")

                val jsonObj = JSONObject()
                val value = JSONObject()
                value.put("code", code)
                value.put("message", message)

                jsonObj.put("command", "ERROR")
                jsonObj.put("value", value)
                messageChannel.send(jsonObj.toString())
            }

            // preview 에서 화면 터치시 직접 제어하려면 아래 함수를 override 한다.
            /*
            override fun handlePreview(context: Context, campaignKey: String) {
                Log.d(TAG, "handlePreview >> campaignKey=$campaignKey")

                val jsonObj = JSONObject()
                val value = JSONObject()
                value.put("campaignKey", campaignKey)

                jsonObj.put("command", "PREVIEW")
                jsonObj.put("value", value)
                messageChannel.send(jsonObj.toString())
            }*/

            // 기본 shareSheet를 사용할 경우에는 override 할 필요 없음.
            override fun handleShare(context: Context, shareUrl: String) {
                //super.handleShare(context, shareUrl)
                Log.d(TAG, "handleShare >> shareUrl=$shareUrl")

                val superHandleShare = {
                    super.handleShare(context, shareUrl)
                }

                liveChannel.invokeMethod("SHARE", shareUrl, object: MethodChannel.Result{
                    override fun success(result: Any?) {
                        Log.i("SHARE", "result: $result")

                        val jsonObj = JSONObject(result.toString())
                        val message = jsonObj.getString("message")
                        val isDefaultShareSheet = jsonObj.getBoolean("isDefaultShareSheet")
                        if (isDefaultShareSheet) {
                            superHandleShare()
                        }
                    }

                    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                        Log.i("SHARE", "error: $errorCode, $errorMessage, $errorDetails")
                    }

                    override fun notImplemented() {
                        Log.i("SHARE", "notImplemented")
                    }
                })
            }

            override fun handleCustomAction(context: Context, id: String, type: String, payload: String,
                                            callback: ShopLiveHandlerCallback) {

                liveChannel.invokeMethod("CUSTOM_ACTION", id, object: MethodChannel.Result{
                    override fun success(result: Any?) {
                        Log.i("CUSTOM_ACTION", "result: $result")

                        val jsonObj = JSONObject(result.toString())
                        val isDownloadSuccess = jsonObj.getBoolean("isSuccess")
                        val message = jsonObj.getString("message")
                        val popupStatus = jsonObj.getString("popupStatus")
                        val alertType = jsonObj.getString("alertType")

                        callback.customActionResult(isDownloadSuccess, message, popupStatus, alertType)
                    }

                    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                        Log.i("CUSTOM_ACTION", "error: $errorCode, $errorMessage, $errorDetails")
                    }

                    override fun notImplemented() {
                        Log.i("CUSTOM_ACTION", "notImplemented")
                    }
                })
            }

            override fun onChangedPlayerStatus(isPipMode: Boolean, state: String) {
                super.onChangedPlayerStatus(isPipMode, state)
                Log.d(TAG, "onChangedPlayerStatus >> isPipMode=$isPipMode, state=$state")

                val jsonObj = JSONObject()
                val value = JSONObject()
                value.put("isPipMode", isPipMode)
                value.put("state", isPipMode)

                jsonObj.put("command", "CHANGED_PLAYER_STATUS")
                jsonObj.put("value", value)
                messageChannel.send(jsonObj.toString())
            }

            override fun onSetUserName(jsonObject: JSONObject) {
                super.onSetUserName(jsonObject)
                Log.d(TAG, "onSetUserName >> jsonObject=$jsonObject")

                val jsonObj = JSONObject()

                jsonObj.put("command", "SET_USER_NAME")
                jsonObj.put("value", jsonObject)
                messageChannel.send(jsonObj.toString())
            }

            override fun onReceivedCommand(context: Context, command: String, data: JSONObject) {
                if (command.compareTo("ON_SUCCESS_CAMPAIGN_JOIN") == 0) {
                    val jsonObj = JSONObject()
                    val value = JSONObject()
                    value.put("result", true)

                    jsonObj.put("command", "RECEIVED_COMMAND.ON_SUCCESS_CAMPAIGN_JOIN")
                    jsonObj.put("value", value)
                    messageChannel.send(jsonObj.toString())
                }
            }
        })
    }

}