
import 'package:flutter/material.dart';
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
  // Future<void> initAds() async {
  //   await _adsManager.init();
  //   notifyListeners();
  // }

  Future<void> showInterstitial() async {
    await _adsManager.showInterstitialIfNeeded();
  }

  /// 🔥 Force show
  Future<void> showAdInterstitial() async {
    await _adsManager.showAdNow();
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