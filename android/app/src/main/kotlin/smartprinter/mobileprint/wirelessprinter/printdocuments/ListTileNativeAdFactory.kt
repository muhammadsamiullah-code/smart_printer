package smartprinter.mobileprint.wirelessprinter.printdocuments

import android.view.LayoutInflater
import android.content.Context
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.MediaView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        val headline = adView.findViewById<android.widget.TextView>(R.id.ad_headline)
        val body = adView.findViewById<android.widget.TextView>(R.id.ad_body)
        val icon = adView.findViewById<android.widget.ImageView>(R.id.ad_icon)
        val cta = adView.findViewById<android.widget.Button>(R.id.ad_call_to_action)
        val media = adView.findViewById<MediaView>(R.id.ad_media)

        // Headline
        headline.text = nativeAd.headline
        adView.headlineView = headline

        // Body
        body.text = nativeAd.body
        adView.bodyView = body

        // Icon
        nativeAd.icon?.let { icon.setImageDrawable(it.drawable) }
        adView.iconView = icon

        // Call to action
        cta.text = nativeAd.callToAction
        adView.callToActionView = cta

        // Media (image/video)
        adView.mediaView = media
        media.setMediaContent(nativeAd.mediaContent)

        adView.setNativeAd(nativeAd)
        return adView
    }
}