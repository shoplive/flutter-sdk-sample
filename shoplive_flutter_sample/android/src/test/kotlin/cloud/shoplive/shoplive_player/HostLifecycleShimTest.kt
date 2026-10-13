package cloud.shoplive.shoplive_player

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

// case: PIP-HOST — FlutterActivity 호스트에서 in-app PIP 전환 시 플레이어가 새 호스트 생명주기로 재바인딩되도록 보정.
class HostLifecycleShimTest {
    private class FakeOwner : LifecycleOwner {
        override val lifecycle: Lifecycle get() = throw UnsupportedOperationException("not used")
    }

    @Test
    fun registersCandidate_whenDecorHasNoOwner() {
        val candidate = FakeOwner()
        val registered = mutableListOf<LifecycleOwner>()

        val changed = HostLifecycleShim.ensure(current = null, candidate = candidate) { registered += it }

        assertTrue(changed)
        assertEquals(1, registered.size)
        assertSame(candidate, registered.single())
    }

    @Test
    fun keepsExistingOwner_whenAlreadyRegistered() {
        val existing = FakeOwner()
        val registered = mutableListOf<LifecycleOwner>()

        val changed = HostLifecycleShim.ensure(current = existing, candidate = FakeOwner()) { registered += it }

        assertFalse(changed)
        assertTrue(registered.isEmpty())
    }
}
