// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/ui/admin/index_page.dart';

import 'home_page.dart';
import 'user/index_page.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/splashscreen_page';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () async {
      var session = await _authService.getUser();
      if (session != null) {
        if (session['role'] == 'user') {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, IndexPage.routeName,
              arguments: 0);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, AdminIndexPage.routeName,
              arguments: 0);
        }
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, HomePage.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Image(
              image: AssetImage('assets/logo/logo.png'),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: 60.0,
                  right: 60.0),
              child: Image.asset('assets/logo/app_icon.png')),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                    right: 10,
                    top: 0,
                    child: Image.asset('assets/images/shoes_3.png')),
                Positioned(
                  left: 10,
                  bottom: 0,
                  child: Image.asset('assets/images/shoes_4.png'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
