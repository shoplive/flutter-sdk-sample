package cloud.shoplive.shoplive_player

import android.app.Activity
import android.content.Context
import java.util.concurrent.atomic.AtomicReference
import com.google.gson.*
import com.google.gson.reflect.TypeToken
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.lang.reflect.Type
import kotlin.math.ceil

abstract class ShopliveBaseModule {
    lateinit var context: Context
    lateinit var activity: Activity

    fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity;
    }

    open fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
    }

    abstract fun onMethodCall(call: MethodCall, result: MethodChannel.Result)

    fun initializeEvent(
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

    fun JSONObject.toMap(): Map<String, Any?> {
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
}