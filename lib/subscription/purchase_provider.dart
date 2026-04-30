
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:smart_scanner/subscription/purchase_manager.dart';

class PurchaseProvider extends ChangeNotifier {
  final PurchaseManager _manager = PurchaseManager();

  PurchaseManager get manager => _manager;

  Future<void> init() async {
    await _manager.init();
    notifyListeners();
  }

  bool get isPremium => _manager.isPremium;

  Future<void> buy(ProductDetails product) async {
    await _manager.buy(product);
  }

  Future<void> restore() async {
    await _manager.restorePurchases();
  }
}