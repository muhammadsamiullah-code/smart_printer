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
  bool isNativeLoaded = false;
  NativeAd? rectangleNativeAd; // rectangle design
  bool isRectangleNativeLoaded = false;
  AppOpenAd? appOpenAd;

  int clickCount = 0;
  bool isInterstitialShowing = false;
    bool isAppOpenShowing = false;
  DateTime? _appOpenLoadTime;

  bool get _isAppOpenAvailable =>
      appOpenAd != null &&
      _appOpenLoadTime != null &&
      DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 2);
  /// 🔹 INIT (NO AD SHOW HERE)
  Future<void> init() async {
    if (isPremiumUser) return;
    loadBanner();
    loadInterstitial(); // ✅ only preload
     loadNative();
    loadRectangleNative();
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
    if (isPremiumUser) return;
    if (!RemoteConfigService.nativeEnabled) return;

    nativeAd?.dispose();
    nativeAd = null;
    isNativeLoaded = false;

    nativeAd = NativeAd(
      adUnitId: RemoteConfigService.nativeAdId,
      factoryId: "listTile",
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          nativeAd = ad as NativeAd;
          isNativeLoaded = true;
          onAdUpdated?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          nativeAd = null;
          isNativeLoaded = false;
          onAdUpdated?.call();
        },
      ),
    );

    await nativeAd!.load();
  }

  /// Rectangle/landscape native ad
  Future<void> loadRectangleNative() async {
    if (isPremiumUser) return;
    if (!RemoteConfigService.nativeEnabled) return;

    rectangleNativeAd?.dispose();
    rectangleNativeAd = null;
    isRectangleNativeLoaded = false;

    rectangleNativeAd = NativeAd(
      adUnitId: RemoteConfigService.nativeAdId,
      factoryId: "rectangle",
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          rectangleNativeAd = ad as NativeAd;
          isRectangleNativeLoaded = true;
          onAdUpdated?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          rectangleNativeAd = null;
          isRectangleNativeLoaded = false;
          onAdUpdated?.call();
        },
      ),
    );

    await rectangleNativeAd!.load();
  }

  /// ------------------ APP OPEN (ONLY CALL MANUALLY) ------------------
  // Future<void> loadAppOpen() async {
  //   if (isPremiumUser) return; // ❌ NO ADS

  //   if (!RemoteConfigService.appOpenEnabled) return;

  //   AppOpenAd.load(
  //     adUnitId: RemoteConfigService.appOpenAdId,
  //     request: const AdRequest(),
  //     adLoadCallback: AppOpenAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         appOpenAd = ad;

  //         Future.delayed(
  //           Duration(seconds: RemoteConfigService.appOpenDelay),
  //           () {
  //             if (!isInterstitialShowing) {
  //               appOpenAd?.show();
  //             }
  //           },
  //         );
  //       },
  //       onAdFailedToLoad: (error) {},
  //     ),
  //   );
  // }
 Future<void> loadAppOpen() async {
    if (isPremiumUser) return;
    if (!RemoteConfigService.appOpenEnabled) return;
    if (_isAppOpenAvailable) return;

    final completer = Completer<void>();

    AppOpenAd.load(
      adUnitId: RemoteConfigService.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          appOpenAd = null;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    return completer.future;
  }

  /// Show sirf tab jab caller bole. Ad band hone tak await hota hai.
  Future<void> showAppOpenIfAvailable() async {
    if (isPremiumUser) return;
    if (!RemoteConfigService.appOpenEnabled) return;
    if (isAppOpenShowing || isInterstitialShowing) return;
    if (!_isAppOpenAvailable) return;

    final completer = Completer<void>();
    final ad = appOpenAd!;
    appOpenAd = null; // ek ad sirf ek dafa

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => isAppOpenShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        isAppOpenShowing = false;
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        isAppOpenShowing = false;
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
    );

    ad.show();
    return completer.future;
  }

  
void removeAdsForPremium() {
  bannerAd?.dispose();
  interstitialAd?.dispose();
  nativeAd?.dispose();
  appOpenAd?.dispose();
  rectangleNativeAd?.dispose();

  bannerAd = null;
  interstitialAd = null;
  nativeAd = null;
  appOpenAd = null;
  rectangleNativeAd = null;

  isBannerLoaded = false;
  isNativeLoaded = false;
  isRectangleNativeLoaded = false;
  isAppOpenShowing = false;
  _appOpenLoadTime = null;

  onAdUpdated?.call();
}

  /// 🔹 DISPOSE
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    nativeAd?.dispose();
    rectangleNativeAd?.dispose();
    appOpenAd?.dispose();
  }
}
