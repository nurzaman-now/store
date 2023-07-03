import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/custom_text.dart';

class MyDialog extends StatelessWidget {
  final String message;
  final Color textColor;
  final String image;
  final String createPage;
  final bool imageNetwork;
  final bool isBack;
  final bool isGo;
  final bool isRedirect;
  final int type;
  final dynamic arguments;

  const MyDialog(
      {super.key,
      required this.message,
      this.textColor = Colors.green,
      required this.createPage,
      this.imageNetwork = false,
      this.isBack = true,
      this.isGo = true,
      this.isRedirect = false,
      this.type = 0,
      this.image = 'assets/logo/success.png',
      this.arguments = 0});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3, milliseconds: 5), () {
      isRedirect
          ? Navigator.of(context).popUntil((route) => route.isFirst)
          : isBack
              ? Navigator.popUntil(context, ModalRoute.withName(createPage))
              : Navigator.of(context).pop();
      isGo
          ? Navigator.pushNamed(context, createPage, arguments: arguments)
          : null;
    });
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageNetwork
              ? Image.network(
                  image,
                  scale: 3.5,
                )
              : Image.asset(image),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: CustomText(
              text: message,
              style: TextStyle(
                color: type == 0 ? textColor : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'work sans',
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
