package cloud.shoplive.shoplive_player

import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ShoplivePlayerPlugin */
class ShoplivePlayerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val shopliveCommonModule = ShopliveCommonModule()
    private val shoplivePlayerModule = ShoplivePlayerModule()
    private val shopliveShortformModule = ShopliveShortformModule()

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private lateinit var channel: MethodChannel

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        shopliveCommonModule.onAttachedToActivity(binding)
        shoplivePlayerModule.onAttachedToActivity(binding)
        shopliveShortformModule.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // the Activity your plugin was attached to was destroyed to change configuration.
        // This call will be followed by onReattachedToActivityForConfigChanges().
    }

    override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
        // your plugin is now attached to a new Activity after a configuration change.
    }

    override fun onDetachedFromActivity() {
        // your plugin is no longer associated with an Activity. Clean up references.
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        shopliveCommonModule.onAttachedToEngine(flutterPluginBinding)
        shoplivePlayerModule.onAttachedToEngine(flutterPluginBinding)
        shopliveShortformModule.onAttachedToEngine(flutterPluginBinding)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "shoplive_player")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        shopliveCommonModule.onMethodCall(call, result)
        shoplivePlayerModule.onMethodCall(call, result)
        shopliveShortformModule.onMethodCall(call, result)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}