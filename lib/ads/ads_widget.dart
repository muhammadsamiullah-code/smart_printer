import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_manager.dart';
/// 🔹 Banner Widget
class BannerAdWidget extends StatefulWidget {
  final AdsManager adsManager;

  const BannerAdWidget({super.key, required this.adsManager});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {

  @override
  void initState() {
    super.initState();
    widget.adsManager.loadBanner();
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.adsManager.bannerAd;

    /// ❌ No ad → NO SPACE
    if (banner == null) return const SizedBox.shrink();

    return Container(
      alignment: Alignment.center,
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}

class NativeAdWidget extends StatelessWidget {
  final AdsManager adsManager;

  const NativeAdWidget({super.key, required this.adsManager});

  @override
  Widget build(BuildContext context) {
    final native = adsManager.nativeAd;

    if (native == null) return const SizedBox();

    return SizedBox(
      height: 100,
      child: AdWidget(ad: native),
    );
  }
}