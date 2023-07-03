// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/ui/login_page.dart';
import 'package:store/ui/popup/dialog.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../common/styles.dart';
import '../firebase_services/auth_services.dart';

class ForgotPassPage extends StatefulWidget {
  static String routeName = '/forgot_pass_page';

  const ForgotPassPage({Key? key}) : super(key: key);

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  bool isButtonEnabled = false;

  void _checkButtonStatus() {
    setState(() {
      isButtonEnabled = emailController.text.isNotEmpty;
    });
  }

  Future _reset() async {
    setState(() {
      isButtonEnabled = false;
    });
    bool isReset = await _authService.resetPassword(emailController.text);
    if (isReset) {
      showDialog(
          context: context,
          builder: (context) => MyDialog(
                message: 'BERHASIL DISIMPAN, silahkan periksa email anda',
                createPage: LoginPage.routeName,
                isRedirect: true,
              ));
    } else {
      _checkButtonStatus();
      showDialog(
          context: context,
          builder: (context) => MyDialog(
                message: 'GAGAL MENGIRIM, Email salah!!!',
                image: 'assets/logo/fail.png',
                textColor: Colors.red,
                createPage: LoginPage.routeName,
                isGo: false,
                isBack: false,
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const CustomAppbar(titleActions: 'Lupa Password'),
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
                  borderRadius: BorderRadius.circular(15.0)),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    SvgPicture.asset('assets/logo/user.svg'),
                    const SizedBox(
                      height: 53,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        cursorColor: primaryColor,
                        style: const TextStyle(
                            color: Colors.black, fontFamily: 'work sans'),
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            border: InputBorder.none,
                            focusColor: Colors.black,
                            hoverColor: primaryColor),
                        onChanged: (value) => _checkButtonStatus(),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButtonTheme(
                        data: CustomButtonStyle(
                          color: isButtonEnabled ? primaryColor : thirdColor,
                          horizontal: MediaQuery.of(context).size.width * 0.1,
                        ),
                        child: TextButton(
                            onPressed: isButtonEnabled ? () => _reset() : null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 13, bottom: 13),
                              child: Text(
                                'SIMPAN',
                                style: TextStyle(
                                  fontSize: 22,
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
