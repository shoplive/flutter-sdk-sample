package cloud.shoplive.shoplive_player

import android.app.Activity
import android.util.Log
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeLifecycleOwner

/**
 * 호스트 액티비티의 decorView에 ViewTreeLifecycleOwner를 등록한다(없을 때만).
 *
 * 3.0.2 in-app PIP는 전체화면 ShoplivePlayerActivity의 플레이어 뷰를 호스트 화면으로 옮겨 붙이고,
 * ShoplivePlayerView.onAttachedToWindow에서 ViewTreeLifecycleOwner.get(view)가 null이 아닐 때만
 * 새 호스트의 생명주기로 다시 바인딩한다(SDK 바이트코드). FlutterActivity는 androidx ComponentActivity가 아니라
 * decorView에 owner를 등록하지 않으므로, 플레이어가 닫히는 ShoplivePlayerActivity 생명주기에 남아 PIP 전환 직후
 * 해제(HLS ExoPlayer release / WebRTC close)된다. FlutterActivity는 androidx LifecycleOwner를 구현하므로 그 owner를 등록한다.
 * FlutterFragmentActivity 등 이미 등록된 호스트는 건드리지 않는다.
 */
internal object HostLifecycleShim {
    private const val TAG = "ShoplivePlayerPlugin"

    fun ensure(activity: Activity) {
        val owner = activity as? LifecycleOwner
        if (owner == null) {
            Log.w(TAG, "Host activity is not a LifecycleOwner (${activity.javaClass.simpleName}); in-app PIP may stop playback.")
            return
        }
        val decor = activity.window?.decorView ?: return
        if (ensure(decor.findViewTreeLifecycleOwner(), owner) { decor.setViewTreeLifecycleOwner(it) }) {
            Log.i(TAG, "Registered ViewTreeLifecycleOwner on ${activity.javaClass.simpleName} for in-app PIP.")
        }
    }

    /** owner가 이미 있으면 그대로 두고 false, 없으면 [candidate]를 등록하고 true. */
    internal fun ensure(current: LifecycleOwner?, candidate: LifecycleOwner, register: (LifecycleOwner) -> Unit): Boolean {
        if (current != null) return false
        register(candidate)
        return true
    }
}
