import 'dart:async';
import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_scanner/subscription/purchase_manager.dart';
import '../const/enum.dart';
import '../services/remote_config_service.dart';

class AdsManager {
  static final AdsManager _instance = AdsManager._internal();
  factory AdsManager() => _instance;
  bool get isPremiumUser => PurchaseManager().isPremium;
  AdsManager._internal();
  VoidCallback? onAdUpdated;
  BannerAd? bannerAd;
  bool isBannerLoaded = false; // 👈 ADD THIS
  InterstitialAd? interstitialAd;
  NativeAd? nativeAd;
  AppOpenAd? appOpenAd;

  int clickCount = 0;
  bool isInterstitialShowing = false;

  /// 🔹 INIT (NO AD SHOW HERE)
  Future<void> init() async {
    if (isPremiumUser) return;
    loadBanner();
    loadInterstitial(); // ✅ only preload
    loadNative();
    // ❌ DO NOT load/show AppOpen here
    // ❌ DO NOT show interstitial here
  }

  bool _isInterstitialEnabled(InterstitialType type) {
    switch (type) {
      case InterstitialType.normal:
        return RemoteConfigService.interstitialEnabled;
      case InterstitialType.backButton:
        return RemoteConfigService.interstitialBackButtonEnabled;

      case InterstitialType.homeTools:
        return RemoteConfigService.interstitialHomeToolsEnabled;

      case InterstitialType.pdfTools:
        return RemoteConfigService.interstitialPDFToolsEnabled;
      case InterstitialType.pdfList:
        return RemoteConfigService.interstitialPDFListEnabled;
    }
  }

  /// ------------------ BANNER ------------------
  Future<void> loadBanner() async {
    if (isPremiumUser) return; // ❌ NO ADS
    if (!RemoteConfigService.bannerEnabled) return;

    bannerAd?.dispose();
    isBannerLoaded = false; // 👈 reset

    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: RemoteConfigService.bannerAdId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerLoaded = true; // ✅ ad actually visible
          onAdUpdated?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          bannerAd = null;
          isBannerLoaded = false; // ❌ no space
          onAdUpdated?.call();
        },
      ),
      // listener: BannerAdListener(
      //   onAdFailedToLoad: (ad, error) => ad.dispose(),
      // ),
    )..load();
  }

  /// ------------------ INTERSTITIAL (PRELOAD ONLY) ------------------
  Future<void> loadInterstitial({
    InterstitialType type = InterstitialType.normal,
  }) async {
    if (isPremiumUser) return;

    if (!_isInterstitialEnabled(type)) return;
    // if (isPremiumUser) return; // ❌ NO ADS

    // if (!RemoteConfigService.interstitialEnabled) return;

    InterstitialAd.load(
      adUnitId: RemoteConfigService.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          interstitialAd = null;
        },
      ),
    );
  }

  /// ------------------ INTERSTITIAL (SHOW WHEN NEEDED) ------------------
  Future<void> showInterstitialIfNeeded() async {
    if (isPremiumUser) return; // ❌ NO ADS

    clickCount++;

    if (!RemoteConfigService.interstitialEnabled) return;

    if (clickCount % RemoteConfigService.clickGap != 0) return;

    if (interstitialAd == null || isInterstitialShowing) return;

    isInterstitialShowing = true;

    final completer = Completer<void>();

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        isInterstitialShowing = false;
        interstitialAd = null;
        loadInterstitial(); // 🔁 preload next
        completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        isInterstitialShowing = false;
        interstitialAd = null;
        loadInterstitial();
        completer.complete();
      },
    );

    interstitialAd!.show();
  }

  /// ------------------ FORCE SHOW INTERSTITIAL ------------------
  // Future<void> showAdNow() async {
  //   if (isPremiumUser) return; // ❌ NO ADS

  //   if (!RemoteConfigService.interstitialEnabled) return;

  //   if (interstitialAd == null || isInterstitialShowing) {
  //     await loadInterstitial();
  //     return;
  //   }

  //   isInterstitialShowing = true;

  //   final completer = Completer<void>();

  //   interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdDismissedFullScreenContent: (ad) {
  //       ad.dispose();
  //       isInterstitialShowing = false;
  //       interstitialAd = null;
  //       loadInterstitial();
  //       completer.complete();
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       ad.dispose();
  //       isInterstitialShowing = false;
  //       interstitialAd = null;
  //       loadInterstitial();
  //       completer.complete();
  //     },
  //   );

  //   interstitialAd!.show();

  //   return completer.future;
  // }
   Future<void> showAdNow({
    InterstitialType type = InterstitialType.normal,
  }) async {
       if (isPremiumUser) return;

    // ✅ CHECK REMOTE CONFIG
    if (!_isInterstitialEnabled(type)) {
      return;
    }

    // ✅ LOAD ONLY WHEN NEEDED
    if (interstitialAd == null) {
      await loadInterstitial(type: type);

      // little wait for load
      await Future.delayed(const Duration(milliseconds: 800));

      if (interstitialAd == null) {
        return;
      }
    }

    if (isInterstitialShowing) return;

    isInterstitialShowing = true;

    final completer = Completer<void>();

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();

        isInterstitialShowing = false;
        interstitialAd = null;

        completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();

        isInterstitialShowing = false;
        interstitialAd = null;

        completer.complete();
      },
    );

    interstitialAd!.show();

    return completer.future;
  }

  /// ------------------ NATIVE ------------------
  Future<void> loadNative() async {
    if (isPremiumUser) return; // ❌ NO ADS
    if (!RemoteConfigService.nativeEnabled) return;

    nativeAd = NativeAd(
      adUnitId: RemoteConfigService.nativeAdId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(),
    )..load();
  }

  /// ------------------ APP OPEN (ONLY CALL MANUALLY) ------------------
  Future<void> loadAppOpen() async {
    if (isPremiumUser) return; // ❌ NO ADS

    if (!RemoteConfigService.appOpenEnabled) return;

    AppOpenAd.load(
      adUnitId: RemoteConfigService.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;

          Future.delayed(
            Duration(seconds: RemoteConfigService.appOpenDelay),
            () {
              if (!isInterstitialShowing) {
                appOpenAd?.show();
              }
            },
          );
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  void removeAdsForPremium() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    nativeAd?.dispose();
    appOpenAd?.dispose();

    bannerAd = null;
    interstitialAd = null;
    nativeAd = null;
    appOpenAd = null;

    isBannerLoaded = false;

    onAdUpdated?.call();
  }

  /// 🔹 DISPOSE
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    nativeAd?.dispose();
    appOpenAd?.dispose();
  }
}
