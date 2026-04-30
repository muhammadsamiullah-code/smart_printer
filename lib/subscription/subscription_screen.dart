import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'purchase_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();

    /// delay so products load ho jayein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PurchaseProvider>();
      final products = provider.manager.products;

      if (products.isEmpty) return;

      /// find yearly products
      final yearlyProducts = products
          .where((p) => p.id.contains("yearly"))
          .toList();

      if (yearlyProducts.isNotEmpty) {
        /// pick lowest price (discounted)
        yearlyProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

        setState(() {
          selectedProduct = yearlyProducts.first;
        });
      }
    });
  }

  ProductDetails? selectedProduct;

  Widget _buildPlan({
    required String title,
    required ProductDetails product,
    ProductDetails? originalProduct,
    bool showBestValue = false,
  }) {
    bool isSelected = selectedProduct?.id == product.id;

    /// 🔥 SAVE %
    int? savePercent;
    if (originalProduct != null) {
      savePercent =
          (((originalProduct.rawPrice - product.rawPrice) /
                      originalProduct.rawPrice) *
                  100)
              .round();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProduct = product;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color.fromRGBO(255, 255, 255, 1)
                  : Color.fromRGBO(232, 232, 232, 1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Color.fromRGBO(23, 70, 162, 1)
                    : Color.fromRGBO(208, 208, 208, 1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                const SizedBox(height: 4),

                /// PRICE ROW
                Column(
                  children: [
                    /// DISCOUNT / NORMAL PRICE
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// ORIGINAL STRIKE (if exists)
                    if (originalProduct != null)
                      Text(
                        originalProduct.price,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Color.fromRGBO(109, 109, 109, 1),
                        ),
                      ),

                    const SizedBox(width: 6),

                    /// SAVE %
                    // if (savePercent != null)
                    //   Text(
                    //     "OFF $savePercent%",
                    //     style: const TextStyle(
                    //       color: Colors.green,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                  ],
                ),
                // if (showBestValue)
                //   Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 8,
                //       vertical: 4,
                //     ),
                //     decoration: BoxDecoration(
                //       color: Colors.green,
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: const Text(
                //       "BEST VALUE",
                //       style: TextStyle(color: Colors.white, fontSize: 10),
                //     ),
                //   ),
              ],
            ),
          ),
          if (savePercent != null)
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 44,
                  width: 44,
                  alignment: Alignment.center, // 🔥 important
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(23, 70, 162, 1)
                        : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$savePercent%\nOFF",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11, // 👈 thoda adjust
                      fontWeight: FontWeight.bold,
                      height: 1.1, // 🔥 line spacing fix
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/imageIcons/checkBoxforSub.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseProvider>();
    final products = provider.manager.products;

    /// sort (yearly last → highlight)
    products.sort((a, b) => a.price.compareTo(b.price));
    Map<String, List<ProductDetails>> grouped = {};

    for (var p in products) {
      if (p.id.contains("monthly")) {
        grouped.putIfAbsent("monthly", () => []).add(p);
      } else if (p.id.contains("yearly")) {
        grouped.putIfAbsent("yearly", () => []).add(p);
      } else if (p.id.contains("weekly")) {
        grouped.putIfAbsent("weekly", () => []).add(p);
      }
    }

    if (selectedProduct == null && grouped["yearly"] != null) {
      final yearlyList = grouped["yearly"]!;

      yearlyList.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

      selectedProduct = yearlyList.first;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: Colors.black, size: 24),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          /// 🔁 RESTORE
          TextButton(
            onPressed: () => provider.restore(),
            child: const Text(
              "Restore Purchases",
              style: TextStyle(
                color: Color.fromRGBO(23, 70, 162, 1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔥 HEADER
              Image.asset(
                'assets/images/printImage.png',
                width: 200,
                height: 180,
              ),
              const Text(
                "Start all your Benefits",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(23, 70, 162, 1),
                ),
              ),

              const SizedBox(height: 10),

              _buildFeature("Unlimited Document Printing"),
              _buildFeature("All PDF Tools Unlocked"),
              _buildFeature("Access Premium Features"),
              _buildFeature("VIP Customer Support"),
              _buildFeature("100% Remove Ads"),

              const SizedBox(height: 20),

              Row(
                children: [
                  if (grouped["weekly"] != null) ...[
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          final product = grouped["weekly"]!.first;

                          return _buildPlan(title: "Weekly", product: product);
                        },
                      ),
                    ),
                  ],
                  SizedBox(width: 10),
                  if (grouped["yearly"] != null) ...[
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          final list = grouped["yearly"]!;
                          list.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

                          return _buildPlan(
                            title: "Yearly",
                            product: list.first,
                            originalProduct: list.length > 1 ? list.last : null,
                            showBestValue: true,
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(width: 10),
                  if (grouped["monthly"] != null) ...[
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          final list = grouped["monthly"]!;
                          list.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

                          return _buildPlan(
                            title: "Monthly",
                            product: list.first,
                            originalProduct: list.length > 1 ? list.last : null,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

              /// 🔥 BUY BUTTON
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  backgroundColor: Color.fromRGBO(23, 70, 162, 1),
                  // padding: EdgeInsetsGeometry.all(12),
                  text: 'Continue',
                  onPressed: selectedProduct == null
                      ? null
                      : () async {
                          await provider.buy(selectedProduct!);
                        },
                ),
              ),
              RichText(
              
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  children: [
                    const TextSpan(text:"By subscribing, you agree to our "),

                    /// Terms of Service (Clickable)
                    TextSpan(
                      text: "Terms of Service",
                      style: const TextStyle(
                        color: Color.fromRGBO(0, 85, 255, 1),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL("https://www.toclicksol.com/terms-conditions");
                        },
                    ),

                    const TextSpan(text: " and "),

                    /// Privacy Policy (Clickable)
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(
                         color: Color.fromRGBO(0, 85, 255, 1),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL("https://www.toclicksol.com/privacy-policy");
                        },
                    ),

                    const TextSpan(text: ".\n"),

                    const TextSpan(
                      text:
                          "Subscriptions are tied to your device and cannot be transferred",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



 // Expanded(
            //   child: ListView.builder(
            //     itemCount: products.length,
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     itemBuilder: (context, index) {
            //       final product = products[index];
        
            //       bool isSelected = selectedProduct?.id == product.id;
            //       bool isYearly = product.id.contains("yearly");
        
            //       return GestureDetector(
            //         onTap: () {
            //           setState(() {
            //             selectedProduct = product;
            //           });
            //         },
            //         child: Container(
            //           margin: const EdgeInsets.only(bottom: 12),
            //           padding: const EdgeInsets.all(14),
            //           decoration: BoxDecoration(
            //             color: isSelected
            //                 ? Colors.deepPurple.withOpacity(0.1)
            //                 : Colors.white,
            //             borderRadius: BorderRadius.circular(14),
            //             border: Border.all(
            //               color: isSelected
            //                   ? Colors.deepPurple
            //                   : Colors.grey.shade300,
            //               width: 1.5,
            //             ),
            //           ),
            //           child: Row(
            //             children: [
            //               /// 🔘 RADIO
            //               Container(
            //                 width: 20,
            //                 height: 20,
            //                 decoration: BoxDecoration(
            //                   shape: BoxShape.circle,
            //                   border: Border.all(
            //                     color: isSelected
            //                         ? Colors.deepPurple
            //                         : Colors.grey,
            //                   ),
            //                 ),
            //                 child: isSelected
            //                     ? const Center(
            //                         child: CircleAvatar(
            //                           radius: 6,
            //                           backgroundColor: Colors.deepPurple,
            //                         ),
            //                       )
            //                     : null,
            //               ),
        
            //               const SizedBox(width: 12),
        
            //               /// TEXT
            //               Expanded(
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       product.title,
            //                       style: const TextStyle(
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                     const SizedBox(height: 4),
            //                     Text(product.price),
            //                   ],
            //                 ),
            //               ),
        
            //               /// 🔥 BEST VALUE BADGE
            //               if (isYearly)
            //                 Container(
            //                   padding: const EdgeInsets.symmetric(
            //                     horizontal: 8,
            //                     vertical: 4,
            //                   ),
            //                   decoration: BoxDecoration(
            //                     color: Colors.green,
            //                     borderRadius: BorderRadius.circular(8),
            //                   ),
            //                   child: const Text(
            //                     "BEST VALUE",
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontSize: 10,
            //                     ),
            //                   ),
            //                 ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
        