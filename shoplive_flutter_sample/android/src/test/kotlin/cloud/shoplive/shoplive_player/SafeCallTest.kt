package cloud.shoplive.shoplive_player

import io.flutter.plugin.common.MethodChannel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

internal class RecordingResult : MethodChannel.Result {
    val calls = mutableListOf<String>()
    var value: Any? = null
    var errorCode: String? = null
    var errorMessage: String? = null
    var errorDetails: Any? = null
    override fun success(result: Any?) { calls += "success"; value = result }
    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        calls += "error"; this.errorCode = errorCode; this.errorMessage = errorMessage; this.errorDetails = errorDetails
    }
    override fun notImplemented() { calls += "notImplemented" }
}

class SafeCallTest {

    private fun run(block: () -> Any?): RecordingResult = RecordingResult().also { Bridge.safeCall("t", "m", it, block) }

    // case: U-01
    @Test fun success_once() {
        val r = run { 1 }
        assertEquals(listOf("success"), r.calls); assertEquals(1, r.value)
    }

    // case: F-05
    @Test fun notImplemented_once() = assertEquals(listOf("notImplemented"), run { throw MethodNotImplemented }.calls)

    // case: F-04
    @Test fun bridgeArgument_isInvalidArgument_withKey() {
        val r = run { throw BridgeArgumentException("k", "String", "Int") }
        assertEquals(BridgeErrorCode.INVALID_ARGUMENT, r.errorCode)
        assertEquals("k", (r.errorDetails as Map<*, *>)["key"])
    }

    // case: F-03
    @Test fun sdkIllegalArgument_outsideConstructing_isSdkError_withoutMessageLeak() {
        val r = run { throw IllegalArgumentException("secret-token-abc") }
        assertEquals(BridgeErrorCode.SDK_ERROR, r.errorCode)
        assertTrue(!r.errorMessage!!.contains("secret"))
        assertTrue(!r.errorDetails.toString().contains("secret"))
    }

    // case: NR-01
    @Test fun state_isItsCode() {
        val r = run { throw BridgeStateException(BridgeErrorCode.NOT_RUNNING, "x") }
        assertEquals(listOf("error"), r.calls); assertEquals("NOT_RUNNING", r.errorCode)
    }

    // case: F-03
    @Test fun runtime_isSdkError_withoutMessageLeak() {
        val r = run { throw IllegalStateException("secret-token-abc") }
        assertEquals(BridgeErrorCode.SDK_ERROR, r.errorCode)
        assertTrue(!r.errorMessage!!.contains("secret"))
        assertEquals(IllegalStateException::class.java.name, (r.errorDetails as Map<*, *>)["exception"])
    }

    // case: F-03
    @Test fun linkage_isSdkError() = assertEquals("SDK_ERROR", run { throw UnsatisfiedLinkError("x") }.errorCode)

    @Test(expected = OutOfMemoryError::class) // case: F-03
    fun vmError_propagates() { run { throw OutOfMemoryError() } }

    // case: F-03
    @Test fun guardCallback_swallowsException_butNotVmError() {
        Bridge.guardCallback("t", "cb") { throw IllegalStateException("x") }
        assertThrows(StackOverflowError::class.java) { Bridge.guardCallback("t", "cb") { throw StackOverflowError() } }
    }

    // case: F-04
    @Test fun constructing_mapsSdkIae_toKeyedArgumentError() {
        val e = assertThrows(BridgeArgumentException::class.java) {
            Bridge.constructing("campaignKey") { require(false) { "blank" } }
        }
        assertEquals("campaignKey", e.key)
    }

    // case: F-04
    @Test fun args_requireString_rejectsBlank() {
        val e = assertThrows(BridgeArgumentException::class.java) { Args.of(mapOf("k" to "  ")).requireString("k") }
        assertEquals("blank", e.actual)
    }

    // case: F-04
    @Test fun args_nonStringKey_rejected_atAnyLevel() {
        assertThrows(BridgeArgumentException::class.java) { Args.of(mapOf(1 to "a")) }
        assertThrows(BridgeArgumentException::class.java) { Args.of(mapOf("p" to mapOf(2 to "b"))).optArgs("p") }
    }

    // case: B-01
    @Test fun args_wireEnumError_doesNotEchoValue() {
        val e = assertThrows(BridgeArgumentException::class.java) {
            Args.of(mapOf("mode" to "secretValue")).optWireEnum("mode", mapOf("fill" to 1))
        }
        assertTrue(!e.message!!.contains("secretValue"))
    }

    // case: R-03
    @Test fun attachGeneration() {
        val g = AttachGeneration()
        val first = g.next()
        assertTrue(g.isCurrent(first))
        g.next()
        assertTrue(!g.isCurrent(first))
    }

    // case: B-02
    @Test fun wireOf_unknownConstant() {
        assertEquals("fill", wireOf(1, mapOf("fill" to 1)))
        assertEquals(WIRE_UNKNOWN, wireOf(2, mapOf("fill" to 1)))
        assertEquals(null, wireOf(null, mapOf("fill" to 1)))
    }
}
