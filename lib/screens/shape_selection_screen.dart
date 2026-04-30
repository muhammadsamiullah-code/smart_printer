import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/models/labels_shape.dart';
import 'package:smart_scanner/providers/labels_provider.dart';
import 'package:smart_scanner/screens/template_selection_screen.dart';
import 'package:smart_scanner/subscription/purchase_provider.dart';
import 'package:smart_scanner/subscription/subscription_screen.dart';

import '../widgets/custom_appbar.dart';

class ShapeSelectionScreen extends StatefulWidget {
  const ShapeSelectionScreen({super.key});

  @override
  State<ShapeSelectionScreen> createState() => _ShapeSelectionScreenState();
}

class _ShapeSelectionScreenState extends State<ShapeSelectionScreen> {
  bool isPremiumShape(LabelShape shape) {
    return shape != LabelShape.rectangle; // rectangle free hai
  }

  @override
  void initState() {
    super.initState();

    /// reset previous selection
    Future.microtask(() {
      context.read<LabelProvider>().resetShape();
      // context.read<LabelProvider>().selectedShape = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumUser = context.watch<PurchaseProvider>().isPremium;
    final provider = Provider.of<LabelProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(title: 'select_label_shape'),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(16),
              children: LabelShape.values.map((shape) {
                return GestureDetector(
                  onTap: () {
                    final isPremiumUser = context
                        .read<PurchaseProvider>()
                        .isPremium;

                    /// 🔒 LOCK CHECK
                    if (isPremiumShape(shape) && !isPremiumUser) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                      return;
                    }

                    /// ✅ Allowed
                    provider.setShape(shape);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TemplateSelectionScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: provider.selectedShape == shape
                              ? Colors.blue.shade100
                              : Colors.white,
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(shape.imagePath, height: 70),
                            const SizedBox(height: 10),
                            Text(
                              shape.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPremiumShape(shape) && !isPremiumUser)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
