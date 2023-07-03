// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/ui/global_key.dart';
import 'package:store/ui/popup/show_profile.dart';
import 'package:store/ui/splash_screen.dart';
import 'package:store/ui/user/menus/setting_menus/address_page.dart';
import 'package:store/ui/user/menus/setting_menus/profile_page.dart';
import 'package:store/ui/user/menus/sub_menu/history_order_page.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../../popup/confirmation.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/custom_text.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/setting_page';
  static const String title = 'Akun';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  // If the future completed successfully, you can access the retrieved data
  late Map<String, dynamic>? user;

  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  final List _menu = [
    {
      "title": "Profile",
      "icon": FractionallySizedBox(
          widthFactor: 0.09, child: SvgPicture.asset('assets/logo/user.svg')),
      "route": ProfilePage.routeName,
      "argument": [0],
    },
    {
      "title": "Alamat",
      "icon": const Icon(
        Icons.location_on,
        color: primaryColor,
      ),
      "route": AddressPage.routeName,
      "argument": [false],
    },
    {
      "title": "Pesanan",
      "icon": const Icon(
        Icons.book,
        color: primaryColor,
      ),
      "route": HistoryOrderPage.routeName,
      "argument": [0],
    },
  ];

  void fetchData() async {
    // Contoh Future yang mengembalikan String
    try {
      user = await _authService.getUser();
      // Callback yang dijalankan ketika Future selesai

      if (mounted) {
        setState(() {
          loading = false;
        });
      }

// Menggunakan hasil Future sesuai kebutuhan Anda
    } catch (error) {
      // Callback yang dijalankan jika terjadi error saat menjalankan Future
      if (kDebugMode) {
        print('Error: $error');
      }
      return null;
    }
  }

  void _refreshPage() {
    refreshIndexPage();
    fetchData();
  }

  void handleConfirmation(bool? confirmed) async {
    if (confirmed!) {
      logout();
    }
  }

  //  logout
  void logout() async {
    await _authService.logout(true);
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacementNamed(context, SplashScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    } else {
      return RefreshIndicator(
        onRefresh: () {
          _refreshPage();
          return Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(27),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        if (user!['image'] != '') {
                          return ShowProfile(
                              imageNetwork: true, image: user!['image']);
                        }
                        return const ShowProfile();
                      }),
                  child: user!['image'] == ''
                      ? const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                            'assets/images/avatar.png',
                          ),
                        )
                      : SizedBox(
                          width: 45,
                          height: 45,
                          child: ClipOval(
                            child: FadeInImage(
                              placeholder: const AssetImage(
                                  'assets/logo/loading_icon.gif'),
                              image: NetworkImage(user!['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: user!['name'],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomText(
                      text: user!['email'],
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.only(
                  top: 22, bottom: 20, left: 20, right: 20),
              margin: const EdgeInsets.only(left: 27, right: 27),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Stack(
                children: [
                  ListView.builder(
                      itemCount: _menu.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: _menu[index]['icon']),
                          contentPadding: const EdgeInsets.all(3.0),
                          title: TextButtonTheme(
                            data: CustomButtonStyle(
                                color: Colors.white, vertical: 8.0),
                            child: TextButton(
                              onPressed: () => _menu[index]["argument"][0] != 0
                                  ? Navigator.pushNamed(
                                      context, _menu[index]["route"],
                                      arguments: _menu[index]["argument"])
                                  : Navigator.pushNamed(
                                      context, _menu[index]["route"]),
                              child: Container(
                                padding: const EdgeInsets.only(left: 13),
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  text: _menu[index]['title'],
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  Container(
                      margin: const EdgeInsets.fromLTRB(43, 300, 43, 60),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: const AssetImage('assets/logo/logo.png'),
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.35),
                                BlendMode.modulate,
                              )))),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: TextButtonTheme(
                        data: CustomButtonStyle(
                            color: primaryColor,
                            horizontal: 20.0,
                            vertical: 10.0),
                        child: TextButton(
                          onPressed: () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Confirm(
                                    message: 'Apakah yakin ingin keluar?',
                                    createPage: SplashScreen.routeName,
                                    isBack: false,
                                    onConfirmation: handleConfirmation,
                                  )),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              CustomText(
                                text: 'Logout',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
