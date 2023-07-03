import 'package:flutter/material.dart';

class CustomButtonStyle extends TextButtonThemeData {
  CustomButtonStyle(
      {Color? color,
      double horizontal = 5.0,
      double? vertical = 0,
      bool isBorder = false,
      bool isShadow = false})
      : super(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: isBorder
                      ? const BorderSide(color: Colors.black, width: 2)
                      : const BorderSide(color: Colors.transparent)),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(color!),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical!),
            ),
            elevation: isShadow ? MaterialStateProperty.all<double>(3.0) : null,
            // Add shadow elevation
            shadowColor:
                isShadow ? MaterialStateProperty.all<Color>(Colors.grey) : null,
          ),
        );
}
