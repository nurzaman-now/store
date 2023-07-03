import 'package:flutter/material.dart';

import '../../common/styles.dart';
import 'custom_text.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Image.asset('assets/logo/loading.png'),
                ),
              ),
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          const CustomText(
            text: 'Roomstock',
            style: TextStyle(fontSize: 24, color: primaryColor),
          ),
        ],
      ),
    );
  }
}
