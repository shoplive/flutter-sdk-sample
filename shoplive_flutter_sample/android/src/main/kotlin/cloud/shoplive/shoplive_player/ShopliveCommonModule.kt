package cloud.shoplive.shoplive_player

import cloud.shoplive.sdk.common.*
import com.google.gson.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ShopliveCommonModule : ShopliveBaseModule() {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "common_setAuth" -> setAuth(
                ShopLiveCommonAuth(
                    call.argument<String?>("userJWT"),
                    call.argument<String?>("guestUid"),
                    call.argument<String?>("accessKey"),
                    call.argument<String?>("utmSource"),
                    call.argument<String?>("utmMedium"),
                    call.argument<String?>("utmCampaign"),
                    call.argument<String?>("utmContent"),
                )
            )

            "common_setAuthToken" -> setAuthToken(
                call.argument<String?>("userJWT"),
            )

            "common_setUser" -> setUser(
                call.argument<String>("accessKey") ?: return,
                ShopLiveCommonUser(
                    call.argument<String>("userId") ?: return,
                    call.argument<String?>("name"),
                    call.argument<Int?>("age"),
                    when (call.argument<String?>("gender")) {
                        "m" -> {
                            ShopLiveCommonUserGender.MALE
                        }

                        "f" -> {
                            ShopLiveCommonUserGender.FEMALE
                        }

                        else -> {
                            ShopLiveCommonUserGender.NEUTRAL
                        }
                    },
                    call.argument<Int?>("userScore"),
                    call.argument<Map<String, Any>?>("custom"),
                )
            )

            "common_setUtmSource" -> setUtmSource(
                call.argument<String?>("utmSource"),
            )

            "common_setUtmMedium" -> setUtmMedium(
                call.argument<String?>("utmMedium"),
            )

            "common_setUtmCampaign" -> setUtmCampaign(
                call.argument<String?>("utmCampaign"),
            )

            "common_setUtmContent" -> setUtmContent(
                call.argument<String?>("utmContent"),
            )

            "common_setAccessKey" -> setAccessKey(
                call.argument<String?>("accessKey"),
            )

            "common_clearAuth" -> clearAuth()

            else -> {
                // Do nothing
            }
        }
    }


    // region ShopLive Public class
    private fun setAuth(auth: ShopLiveCommonAuth) {
        ShopLiveCommon.setAuth(auth)
    }

    private fun setAuthToken(userJWT: String?) {
        ShopLiveCommon.setAuthToken(userJWT)
    }

    private fun setUser(accessKey: String, user: ShopLiveCommonUser) {
        ShopLiveCommon.setUser(accessKey, user)
    }

    private fun setUtmSource(utmSource: String?) {
        ShopLiveCommon.setUtmSource(utmSource)
    }

    private fun setUtmMedium(utmMedium: String?) {
        ShopLiveCommon.setUtmMedium(utmMedium)
    }

    private fun setUtmCampaign(utmCampaign: String?) {
        ShopLiveCommon.setUtmCampaign(utmCampaign)
    }

    private fun setUtmContent(utmContent: String?) {
        ShopLiveCommon.setUtmContent(utmContent)
    }

    private fun setAccessKey(accessKey: String?) {
        ShopLiveCommon.setAccessKey(accessKey)
    }

    private fun clearAuth() {
        ShopLiveCommon.clearAuth()
    }
    // endregion
}