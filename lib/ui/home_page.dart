import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:store/ui/login_page.dart';
import 'package:store/ui/register_page.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../common/styles.dart';
import 'widgets/custom_text.dart';

class HomePage extends StatelessWidget {
  static String routeName = '/home_page';

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 36),
              child: const Text(
                'Akun',
                style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'work sans',
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.75,
              margin: const EdgeInsets.all(29),
              padding: const EdgeInsets.only(top: 29, bottom: 29),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    height: 66.32,
                  ),
                  SizedBox(
                    width: 258,
                    child: TextButtonTheme(
                      data: CustomButtonStyle(
                        color: primaryColor,
                        horizontal: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, RegisterPage.routeName),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: CustomText(
                              text: 'DAFTAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 18.62,
                  ),
                  SizedBox(
                    width: 258,
                    child: TextButtonTheme(
                      data: CustomButtonStyle(
                        color: primaryColor,
                        horizontal: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, LoginPage.routeName),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: CustomText(
                              text: 'MASUK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )),
                    ),
                  ),
                  Container(
                      height: 57,
                      margin: const EdgeInsets.fromLTRB(43, 100, 43, 10),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: const AssetImage('assets/logo/logo.png'),
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.35),
                                BlendMode.modulate,
                              ))))
                ],
              ),
            ),
          ],
        ));
  }
}
