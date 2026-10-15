package cloud.shoplive.shoplive_player

import io.flutter.plugin.common.MethodCall
import org.junit.Assert.assertEquals
import org.junit.Test

class ShoplivePlayerPluginTest {

    @Test // case: U-07
    fun methodChannelName_matchesContract() {
        assertEquals("shoplive_player", ShoplivePlayerPlugin.METHOD_CHANNEL)
    }

    @Test // case: R-03
    fun beforeAttach_callCompletesOnce_withSdkErrorPluginDetached() {
        val result = RecordingResult()
        ShoplivePlayerPlugin().onMethodCall(MethodCall("getState", null), result)
        assertEquals(listOf("error"), result.calls)
        assertEquals(BridgeErrorCode.SDK_ERROR, result.errorCode)
        assertEquals("plugin detached", result.errorMessage)
    }
}
