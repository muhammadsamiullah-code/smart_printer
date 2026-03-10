

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/providers/translator_provider.dart';

class TrText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TrText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final translator = context.watch<TranslatorProvider>();

    return Text(
      translator.tr(textKey),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}