import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const CustomText(
      {super.key,
      required this.text,
      required this.style,
      this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final scaledFontSize =
        style.fontSize != null ? style.fontSize! * textScaleFactor : null;

    return Text(
      text,
      style: style.copyWith(
          fontSize: scaledFontSize, decoration: TextDecoration.none),
      textAlign: textAlign,
    );
  }
}
