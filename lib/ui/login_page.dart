// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/firebase_services/user_services.dart';
import 'package:store/ui/admin/index_page.dart';
import 'package:store/ui/forgot_pass_page.dart';
import 'package:store/ui/popup/dialog.dart';
import 'package:store/ui/user/index_page.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../common/styles.dart';
import '../models/user.dart';
import 'widgets/custom_text.dart';

class LoginPage extends StatefulWidget {
  static String routeName = '/login_page';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final UserServices _userServices = UserServices();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePass = true;
  bool isButtonEnabled = false;

  void _checkButtonStatus() {
    setState(() {
      isButtonEnabled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  Future _login() async {
    setState(() {
      isButtonEnabled = false;
    });
    String email = emailController.text.trim();
    String password = passwordController.text;

    await _authService.login(email, password).then((login) {
      _authService.getUser().then((user) async {
        if (login == 'BERHASIL LOGIN' && user != null) {
          if (user['token'] != 'noDevice') {
            // Deny the login request, as the user already has an active device
            await _authService.logout(false);
            _checkButtonStatus();
            return showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => MyDialog(
                      message: 'GAGAL LOGIN, ANDA SUDAH LOGIN',
                      image: 'assets/logo/fail.png',
                      textColor: Colors.red,
                      createPage: IndexPage.routeName,
                      isGo: false,
                      isBack: false,
                    ));
          }
          // get token
          await messaging.getToken().then((value) async {
            if (user['token'] != value) {
              Users userr = Users(
                  id: user['uid'], token: value, updatedAt: Timestamp.now());
              await _userServices.updateUser(userr);
            }
          });

          if (user['role'] == 'admin') {
            return showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => MyDialog(
                      message: '$login SEBAGAI ADMIN',
                      createPage: AdminIndexPage.routeName,
                    ));
          } else {
            return showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => MyDialog(
                      message: login,
                      createPage: IndexPage.routeName,
                    ));
          }
        } else {
          _checkButtonStatus();
          if (login.contains('password is invalid')) {
            login = 'Password Salah';
          } else if (login.contains('no user record')) {
            login = 'Email Tidak Terdaftar';
          }
          return showDialog(
              context: context,
              builder: (context) => MyDialog(
                    message: login,
                    image: 'assets/logo/fail.png',
                    textColor: Colors.red,
                    createPage: LoginPage.routeName,
                    isGo: false,
                    isBack: false,
                  ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const CustomAppbar(
          titleActions: 'Masuk',
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding:
              const EdgeInsets.only(top: 29, bottom: 29, left: 20, right: 20),
          alignment: Alignment.center,
          child: ListView(children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.only(
                top: 28,
                bottom: 28,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomText(
                      text: 'Account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    SizedBox(
                        width: 60,
                        height: 60,
                        child: SvgPicture.asset('assets/logo/user.svg')),
                    const SizedBox(
                      height: 53,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        cursorColor: primaryColor,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: 'work sans'),
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            border: InputBorder.none,
                            focusColor: Colors.black,
                            hoverColor: primaryColor),
                        onChanged: (value) => _checkButtonStatus(),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        obscureText: obscurePass,
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordController,
                        cursorColor: primaryColor,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontFamily: 'work sans'),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: InputBorder.none,
                          focusColor: Colors.black,
                          hoverColor: primaryColor,
                          fillColor: primaryColor,
                          iconColor: primaryColor,
                          suffixIcon: IconButton(
                            color: primaryColor,
                            icon: Icon(obscurePass
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                obscurePass = !obscurePass;
                              });
                            },
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        onChanged: (value) => _checkButtonStatus(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, ForgotPassPage.routeName),
                            child: const CustomText(
                              text: 'Lupa Password?',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'work sans',
                                  color: Colors.black),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButtonTheme(
                        data: CustomButtonStyle(
                          color: isButtonEnabled ? primaryColor : thirdColor,
                          horizontal: MediaQuery.of(context).size.width * 0.1,
                        ),
                        child: TextButton(
                            onPressed: () => isButtonEnabled ? _login() : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: CustomText(
                                text: 'MASUK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isButtonEnabled
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
