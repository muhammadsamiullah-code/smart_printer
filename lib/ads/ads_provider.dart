
import 'package:flutter/material.dart';
import '../const/enum.dart';
import 'ads_manager.dart';

class AdsProvider extends ChangeNotifier {
  final AdsManager _adsManager = AdsManager();

  AdsManager get ads => _adsManager;
   Future<void> initAds() async {
    _adsManager.onAdUpdated = () {
      notifyListeners(); // 🔥 UI rebuild
    };

    await _adsManager.init();
    notifyListeners();
  }

  Future<void> showInterstitial() async {
    await _adsManager.showInterstitialIfNeeded();
  }

  /// 🔥 Force show
  // Future<void> showAdInterstitial() async {
  //   await _adsManager.showAdNow();
  // }
    Future<void> showAdInterstitial({
    InterstitialType type = InterstitialType.normal,
  }) async {
    await _adsManager.showAdNow(type: type);
  }

  /// ✅ App Open Separate
  Future<void> loadAppOpenAd() async {
    await _adsManager.loadAppOpen();
  }


  @override
  void dispose() {
    _adsManager.dispose();
    super.dispose();
  }
}