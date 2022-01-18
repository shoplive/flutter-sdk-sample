package cloud.shoplive.shoplive_flutter_sample

import android.app.Application
import android.content.Context
import cloud.shoplive.sdk.*

class App: Application() {

    override fun onCreate() {
        super.onCreate()

        ShopLive.init(this)
        //ShopLive.setAccessKey("9M2FwM5BmJf9RVeesKeg")
    }
}