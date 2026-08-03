package smartprinter.mobileprint.wirelessprinter.printdocuments

import android.view.LayoutInflater
import android.content.Context
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.MediaView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class RectangleNativeAdFactory(val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.list_rectangle_native_ad, null) as NativeAdView

        val headline = adView.findViewById<android.widget.TextView>(R.id.ad_headline)
        val body = adView.findViewById<android.widget.TextView>(R.id.ad_body)
        val icon = adView.findViewById<android.widget.ImageView>(R.id.ad_icon)
        val cta = adView.findViewById<android.widget.Button>(R.id.ad_call_to_action)
        val media = adView.findViewById<MediaView>(R.id.ad_media)

        headline.text = nativeAd.headline
        adView.headlineView = headline

        body.text = nativeAd.body
        adView.bodyView = body

        // Icon bind karo
        nativeAd.icon?.let { icon.setImageDrawable(it.drawable) }
        adView.iconView = icon

        cta.text = nativeAd.callToAction
        adView.callToActionView = cta

        adView.mediaView = media
        media.setMediaContent(nativeAd.mediaContent)

        adView.setNativeAd(nativeAd)
        return adView
    }
}