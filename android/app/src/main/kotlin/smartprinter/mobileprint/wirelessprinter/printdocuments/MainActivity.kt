package smartprinter.mobileprint.wirelessprinter.printdocuments


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Square / vertical native ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",
            ListTileNativeAdFactory(this)
        )

        // Rectangle / landscape native ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "rectangle",
            RectangleNativeAdFactory(this)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {

        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "listTile"
        )

        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "rectangle"
        )

        super.cleanUpFlutterEngine(flutterEngine)
    }
}
