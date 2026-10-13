package cloud.shoplive.shoplive_player

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

/**
 * pair #27: player·streamer BridgeSupport.kt 본문 동일성(package 줄 제외). 형제 플러그인 파일이 없으면 실패(skip 아님).
 * 테스트 작업 디렉토리 = 이 플러그인의 android 프로젝트 디렉토리(shoplive_flutter_sample/android).
 */
class BridgeSupportSyncTest {

    private fun body(file: File): List<String> = file.readLines().filterNot { it.startsWith("package ") }

    @Test // case: U-07
    fun streamerCopy_isIdenticalExceptPackage() {
        val base = File(System.getProperty("user.dir"))
        val mine = File(base, "src/main/kotlin/cloud/shoplive/shoplive_player/BridgeSupport.kt")
        val sibling = File(base, "../../shoplive_streamer/android/src/main/kotlin/cloud/shoplive/shoplive_streamer/BridgeSupport.kt")
        assertTrue("missing ${mine.canonicalPath}", mine.isFile)
        assertTrue("missing sibling ${sibling.canonicalPath}", sibling.isFile)
        assertEquals(body(mine), body(sibling))
    }
}
