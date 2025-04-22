package cloud.shoplive.shoplive_player

import android.content.Context
import androidx.annotation.Keep
import cloud.shoplive.sdk.streamer.*
import cloud.shoplive.sdk.common.*
import com.google.gson.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicReference

class ShopliveStreamerModule : ShopliveBaseModule() {
    companion object {
        private const val EVENT_STREAMER_ERROR = "event_streamer_error"
    }

    private val eventError = AtomicReference<EventChannel.EventSink?>(null)

    private val eventPairs = listOf(
        EVENT_STREAMER_ERROR to eventError,
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        eventPairs.forEach { (eventName, eventSink) ->
            initializeEvent(flutterPluginBinding.binaryMessenger, eventName, eventSink)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        when (call.method) {
            "streamer_play" -> {
                val campaignKey: String = call.argument<String>("campaignKey") ?: ""
                play(campaignKey)
            }

            else -> {
                // Do nothing
            }
        }
    }

    // region ShopLive Public class
    private fun play(campaignKey: String) {
        ShopLiveStreamer.setHandler(shopLiveStreamerHandler)
        ShopLiveStreamer.play(activity,ShopLiveStreamerNormalData(campaignKey))
    }

    // endregion
    private val shopLiveStreamerHandler = object : ShopLiveStreamerHandler() {
        override fun onError(context: Context, error: ShopLiveCommonError) {
            eventError.get()?.success(Gson().toJson(ErrorData(error.code.toString(), error.message)))
        }
    }

    @Keep
    private data class ErrorData(
        val code: String,
        val message: String?,
    )
}