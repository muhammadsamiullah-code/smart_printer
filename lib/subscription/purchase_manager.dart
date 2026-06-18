
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scanner/ads/ads_manager.dart';
import 'package:smart_scanner/const/product_ids.dart';

class PurchaseManager {
  static final PurchaseManager _instance = PurchaseManager._internal();
  factory PurchaseManager() => _instance;
  PurchaseManager._internal();
  PurchaseDetails? activeSubscription;
  final InAppPurchase _iap = InAppPurchase.instance;

  List<ProductDetails> products = [];
  bool isAvailable = false;
  bool isPremium = false;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
 Future<void> _savePremium(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isPremium", value);
}

Future<void> _loadLocalPremium() async {
  final prefs = await SharedPreferences.getInstance();
  isPremium = prefs.getBool("isPremium") ?? false;
}

  /// 🔥 INIT
  Future<void> init() async {
  try {
    /// 🔥 load cached FIRST (important)
    await _loadLocalPremium();

    isAvailable = await _iap
        .isAvailable()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);

    if (!isAvailable) return;

    await _getProducts();
    _listenToPurchaseUpdates();
    await restorePurchases();

    if (isPremium) {
      AdsManager().removeAdsForPremium();
    }
  } catch (e) {
    print("IAP offline safe");
  }
}
Future<void> _getProducts() async {
  const ids = {
    monthlyId,
    yearlyId,
    weeklyId, // 👈 include
  };

  final response = await _iap.queryProductDetails(ids);

  products = response.productDetails;
}

  /// 🔥 LISTEN PURCHASE
  void _listenToPurchaseUpdates() {
    _subscription = _iap.purchaseStream.listen((purchases) {
      _handlePurchase(purchases);
    });
  }

 void _handlePurchase(List<PurchaseDetails> purchases) async {
  for (var purchase in purchases) {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {

      /// 🔥 SAVE ACTIVE SUBSCRIPTION
      activeSubscription = purchase;

      isPremium = true;
      await _savePremium(true);

      AdsManager().removeAdsForPremium();

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
}

Future<void> buy(ProductDetails product) async {
  final purchaseParam = PurchaseParam(
    productDetails: product,
  );

  await _iap.buyNonConsumable(
    purchaseParam: purchaseParam,
  );
}

  /// 🔥 RESTORE
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// 🔥 CLEAN
  void dispose() {
    _subscription?.cancel();
  }
}