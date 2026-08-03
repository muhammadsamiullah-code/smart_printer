

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/remote_config_service.dart';
import '../subscription/purchase_manager.dart';

class SquareNativeAdWidget extends StatefulWidget {
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;

  const SquareNativeAdWidget({
    super.key,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<SquareNativeAdWidget> createState() => _SquareNativeAdWidgetState();
}

class _SquareNativeAdWidgetState extends State<SquareNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final isPremium = PurchaseManager().isPremium;
    if (isPremium) {
      // premium user ko ad nahi dikhani, parent ko turant bata do
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAdFailedToLoad?.call();
      });
      return;
    }
    if (!RemoteConfigService.nativeEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAdFailedToLoad?.call();
      });
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: RemoteConfigService.nativeAdId,
      factoryId: "listTile",
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _nativeAd = ad as NativeAd;
              _isLoaded = true;
            });
            widget.onAdLoaded?.call(); // 👈 parent ko batao
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _isLoaded = false;
            });
            widget.onAdFailedToLoad?.call(); // 👈 parent ko batao
          }
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = PurchaseManager().isPremium;
    if (isPremium) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 280,
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}

// class SquareNativeAdWidget extends StatefulWidget {
//   const SquareNativeAdWidget({super.key});

//   @override
//   State<SquareNativeAdWidget> createState() => _SquareNativeAdWidgetState();
// }

// class _SquareNativeAdWidgetState extends State<SquareNativeAdWidget> {
//   NativeAd? _nativeAd;
//   bool _isLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }

//   void _loadAd() {
//     final isPremium = PurchaseManager().isPremium;
//     if (isPremium) return;
//     if (!RemoteConfigService.nativeEnabled) return;

//     _nativeAd = NativeAd(
//       adUnitId: RemoteConfigService.nativeAdId,
//       factoryId: "listTile",
//       request: const AdRequest(),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           if (mounted) {
//             setState(() {
//               _nativeAd = ad as NativeAd;
//               _isLoaded = true;
//             });
//           }
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           if (mounted) {
//             setState(() {
//               _nativeAd = null;
//               _isLoaded = false;
//             });
//           }
//         },
//       ),
//     );

//     _nativeAd!.load();
//   }

//   @override
//   void dispose() {
//     _nativeAd?.dispose(); // 👈 zaroori: screen band hote hi apna ad dispose karo
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isPremium = PurchaseManager().isPremium;
//     if (isPremium) {
//       return const SizedBox.shrink();
//     }

//     if (!_isLoaded || _nativeAd == null) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: SizedBox(
//         height: 280,
//         child: AdWidget(ad: _nativeAd!),
//       ),
//     );
//   }
// }

class RectangleNativeAdWidget extends StatefulWidget {
  const RectangleNativeAdWidget({super.key});

  @override
  State<RectangleNativeAdWidget> createState() => _RectangleNativeAdWidgetState();
}

class _RectangleNativeAdWidgetState extends State<RectangleNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final isPremium = PurchaseManager().isPremium;
    if (isPremium) return;
    if (!RemoteConfigService.nativeEnabled) return;

    _nativeAd = NativeAd(
      adUnitId: RemoteConfigService.nativeAdId,
      factoryId: "rectangle", // 👈 rectangle design
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _nativeAd = ad as NativeAd;
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose(); // 👈 screen band hote hi apna ad dispose karo
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = PurchaseManager().isPremium;
    if (isPremium) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 200, // rectangle design ke hisaab se
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}