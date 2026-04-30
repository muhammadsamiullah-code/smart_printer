import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;
  static Future init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(minutes: 30),
        ),
      );

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print("RemoteConfig offline fallback");
    }
  }
  // static Future init() async {
  //   await _remoteConfig.setConfigSettings(
  //     RemoteConfigSettings(
  //       fetchTimeout: const Duration(seconds: 10),
  //       minimumFetchInterval: const Duration(minutes: 30), // dev mode
  //     ),
  //   );

  //   await _remoteConfig.fetchAndActivate();
  // }

  static bool get bannerEnabled => _remoteConfig.getBool('ads_banner_enabled');

  static String get bannerAdId => _remoteConfig.getString('ads_banner_id');

  static bool get interstitialEnabled =>
      _remoteConfig.getBool('ads_interstitial_enabled');
  static String get interstitialAdId =>
      _remoteConfig.getString('ads_interstitial_id');
  static int get clickGap => _remoteConfig.getInt('ads_interstitial_click_gap');

  static bool get appOpenEnabled =>
      _remoteConfig.getBool('ads_app_open_enabled');

  static String get appOpenAdId => _remoteConfig.getString('ads_app_open_id');
  static int get appOpenDelay =>
      _remoteConfig.getInt('ads_app_open_delay_seconds');
  static bool get nativeEnabled => _remoteConfig.getBool('ads_native_enabled');

  static String get nativeAdId => _remoteConfig.getString('ads_native_ad_id');
}
