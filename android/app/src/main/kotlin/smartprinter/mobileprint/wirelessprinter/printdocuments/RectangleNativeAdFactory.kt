package smartprinter.mobileprint.wirelessprinter.printdocuments

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView

import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

import io.flutter.plugins.googlemobileads.NativeAdFactory

class RectangleNativeAdFactory(
    private val context: Context
) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val adView = LayoutInflater.from(context)
            .inflate(R.layout.list_rectangle_native_ad, null) as NativeAdView

        val headline =
            adView.findViewById<TextView>(R.id.ad_headline)

        val body =
            adView.findViewById<TextView>(R.id.ad_body)

        val icon =
            adView.findViewById<ImageView>(R.id.ad_icon)

        val cta =
            adView.findViewById<Button>(R.id.ad_call_to_action)

        val media =
            adView.findViewById<MediaView>(R.id.ad_media)

        // -------------------------
        // Headline
        // -------------------------
        headline.text = nativeAd.headline
        adView.headlineView = headline

        // -------------------------
        // Body
        // -------------------------
        body.text = nativeAd.body
        adView.bodyView = body

        // -------------------------
        // Icon
        // -------------------------
        nativeAd.icon?.let {
            icon.setImageDrawable(it.drawable)
        }

        adView.iconView = icon

        // -------------------------
        // Call To Action
        // -------------------------
        cta.text = nativeAd.callToAction
        adView.callToActionView = cta

        // -------------------------
        // Media
        // -------------------------
        adView.mediaView = media

        // -------------------------
        // Register Native Ad
        // -------------------------
        adView.setNativeAd(nativeAd)

        return adView
    }
}