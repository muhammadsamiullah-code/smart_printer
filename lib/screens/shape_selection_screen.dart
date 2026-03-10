import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/models/labels_shape.dart';
import 'package:smart_scanner/providers/labels_provider.dart';
import 'package:smart_scanner/screens/template_selection_screen.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class ShapeSelectionScreen extends StatefulWidget {
  const ShapeSelectionScreen({super.key});

  @override
  State<ShapeSelectionScreen> createState() => _ShapeSelectionScreenState();
}

class _ShapeSelectionScreenState extends State<ShapeSelectionScreen> {

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

    final provider = Provider.of<LabelProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 24, color: Colors.black),
        ),
        title: const TrText(
          "select_label_shape",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              children: LabelShape.values.map((shape) {
                return GestureDetector(
                  onTap: () {

                    provider.setShape(shape);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TemplateSelectionScreen(),
                      ),
                    );
                  },
                  child: Card(
                    color: provider.selectedShape == shape
                        ? Colors.blue.shade100
                        : Colors.white,
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
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
// class ShapeSelectionScreen extends StatelessWidget {
//   const ShapeSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<LabelProvider>(context);

//     return Scaffold(
//       backgroundColor: const Color(0xffEDEDED),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent, // same as appbar
//           statusBarIconBrightness: Brightness.dark, // dark icons
//           statusBarBrightness: Brightness.light,
//         ),
//         foregroundColor: Colors.transparent,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
//         ),
//         title: const TrText(
//           "select_label_shape",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//          centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2,
//               padding: const EdgeInsets.all(16),
//               children: LabelShape.values.map((shape) {
//                 return GestureDetector(
//                   onTap: () {
//                     provider.setShape(shape);

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const TemplateSelectionScreen(),
//                       ),
//                     );
//                   },
//                   // onTap: () => provider.setShape(shape),
//                   child: Card(
//                     color: provider.selectedShape == shape
//                         ? Colors.blue.shade100
//                         : Colors.white,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SvgPicture.asset(shape.imagePath, height: 70),
//                         const SizedBox(height: 10),

//                         Text(
//                           shape.name.toUpperCase(),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
