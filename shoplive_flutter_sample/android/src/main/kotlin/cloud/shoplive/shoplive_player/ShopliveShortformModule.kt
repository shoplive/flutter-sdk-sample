package cloud.shoplive.shoplive_player

import android.app.Activity
import android.content.Context
import androidx.annotation.Keep
import cloud.shoplive.sdk.shorts.*
import cloud.shoplive.sdk.network.request.ShopLiveShortformTagSearchOperator
import com.google.gson.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicReference

class ShopliveShortformModule : ShopliveBaseModule() {
    companion object {
        private const val EVENT_SHORTFORM_CLICK_PRODUCT = "event_shortform_click_product"
        private const val EVENT_SHORTFORM_CLICK_BANNER = "event_shortform_click_banner"
        private const val EVENT_SHORTFORM_SHARE = "event_shortform_share"
        private const val EVENT_SHORTFORM_START = "event_shortform_start"
        private const val EVENT_SHORTFORM_CLOSE = "event_shortform_close"
        private const val EVENT_SHORTFORM_LOG = "event_shortform_log"
    }

    private val eventClickProduct = AtomicReference<EventChannel.EventSink?>(null)
    private val eventClickBanner = AtomicReference<EventChannel.EventSink?>(null)
    private val eventShare = AtomicReference<EventChannel.EventSink?>(null)
    private val eventStart = AtomicReference<EventChannel.EventSink?>(null)
    private val eventClose = AtomicReference<EventChannel.EventSink?>(null)
    private val eventLog = AtomicReference<EventChannel.EventSink?>(null)

    private val eventPairs = listOf(
        EVENT_SHORTFORM_CLICK_PRODUCT to eventClickProduct,
        EVENT_SHORTFORM_CLICK_BANNER to eventClickBanner,
        EVENT_SHORTFORM_SHARE to eventShare,
        EVENT_SHORTFORM_START to eventStart,
        EVENT_SHORTFORM_CLOSE to eventClose,
        EVENT_SHORTFORM_LOG to eventLog,
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        eventPairs.forEach { (eventName, eventSink) ->
            initializeEvent(flutterPluginBinding.binaryMessenger, eventName, eventSink)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "shortform_play" -> play(
                call.argument<String?>("shortsId"),
                call.argument<String?>("shortsCollectionId"),
                call.argument<List<String>?>("tags"),
                call.argument<String?>("tagSearchOperator"),
                call.argument<List<String>?>("brands"),
                call.argument<List<String>?>("skus"),
                call.argument<Boolean?>("shuffle"),
                call.argument<String?>("referrer"),
            )

            "shortform_close" -> close()
            else -> {
                // Do nothing
            }
        }
    }
    // region ShopLive Public class
    private fun play(
        shortsId: String?,
        shortsCollectionId: String?,
        tags: List<String>?,
        tagSearchOperator: String?,
        brands: List<String>?,
        skus: List<String>?,
        shuffle: Boolean?,
        referrer: String?
    ) {
        ShopLiveShortform.play(
            context,
            ShopLiveShortformCollectionData(
                shortsId,
                shortsCollectionId,
                tags,
                if (tagSearchOperator == "OR") {
                    ShopLiveShortformTagSearchOperator.OR
                } else {
                    ShopLiveShortformTagSearchOperator.AND
                },
                brands,
                skus,
                shuffle ?: false,
                referrer
            ).apply {
                handler = shopLiveShortformHandler
            }
        )
    }

    private fun close() {
        ShopLiveShortform.close()
    }
    // endregion
    private val shopLiveShortformHandler = object : ShopLiveShortformHandler() {
        override fun getOnClickProductListener(): ShopLiveShortformProductListener {
            return ShopLiveShortformProductListener { _, _, product ->
                eventClickProduct.get()?.success(Gson().toJson(product))
            }
        }

        override fun getOnClickBannerListener(): ShopLiveShortformUrlListener {
            return ShopLiveShortformUrlListener { _, _, url ->
                eventClickBanner.get()?.success(Gson().toJson(ShopliveShortformUrlData(url)))
            }
        }

        override fun onEvent(context: Context, messenger: ShopLiveShortformMessageListener?, command: String, payload: Map<String, Any?>) {
            eventLog.get()?.success(Gson().toJson(ShopliveShortformLogData(command, JSONObject(payload).toString())))
        }

        override fun onShare(context: Context, data: ShopLiveShortformShareData) {
            eventShare.get()?.success(Gson().toJson(data))
        }

        override fun onCreate() {
            eventStart.get()?.success(Gson().toJson(ShopliveShortformBaseData()))
        }

        override fun onDestroy() {
            eventClose.get()?.success(Gson().toJson(ShopliveShortformBaseData()))
        }
    }

    @Keep
    private data class ShopliveShortformUrlData(
        val url: String,
    )

    @Keep
    private data class ShopliveShortformLogData(
        val command: String,
        val payload: String?,
    )

    @Keep
    private class ShopliveShortformBaseData()
}