// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/common/styles.dart';
import 'package:store/models/user.dart';
import 'package:store/ui/popup/dialog.dart';
import 'package:store/ui/user/index_page.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../../../../firebase_services/auth_services.dart';
import '../../../../firebase_services/upload_service.dart';
import '../../popup/confirmation.dart';
import '../../splash_screen.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/custom_text.dart';

class AdminProfilePage extends StatefulWidget {
  static const routeName = '/profile_page';
  static const String title = 'Profile';

  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AuthService _authService = AuthService();
  final UploadService _uploadService = UploadService();

  final List _menu = [
    {
      "title": "Nama",
      "icon": FractionallySizedBox(
          widthFactor: 0.09, child: SvgPicture.asset('assets/logo/user.svg')),
      "controller": TextEditingController(),
    },
    {
      "title": "Nomor Telpon",
      "icon": const Icon(Icons.phone),
      "controller": TextEditingController(),
    },
    {
      "title": "Jenis Kelamin",
      "icon": const Icon(Icons.book),
      "controller": TextEditingController(),
    },
    {
      "title": "Tanggal Lahir",
      "icon": const Icon(Icons.history),
      "controller": TextEditingController(),
    },
    {
      "title": "Email",
      "icon": const Icon(Icons.email),
      "controller": TextEditingController(),
    },
  ];

  final List<String> listJK = <String>['Laki laki', 'Perempuan', 'Lainnya'];

  late String jk = 'Laki laki';
  late String ttl = '';
  late Map<String, dynamic>? user;
  late bool loading = true;
  late bool enable = false;
  late bool noTelpLength = true;

  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    user = await _authService.getUser();
    if (user != null) {
      setState(() {
        loading = false;
      });
    }
  }

  Future _update() async {
    String name = _menu[0]['controller'].text;
    String noTelp = _menu[1]['controller'].text;
    String email = _menu[4]['controller'].text;

    try {
      Users users = Users(
        email: email,
        name: name,
        phoneNumber: noTelp,
        gender: jk,
        birthDate: Timestamp.fromDate(DateTime.parse(ttl)),
        updatedAt: Timestamp.now(),
      );

      await _authService.updateUser(users);

      // ignore: use_build_context_synchronously
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MyDialog(
                message: 'BERHASIL DISIMPAN',
                createPage: IndexPage.routeName,
                isBack: false,
                isGo: false,
              ));
    } catch (e) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MyDialog(
                message: 'GAGAL DISIMPAN',
                createPage: IndexPage.routeName,
                isBack: false,
                isGo: false,
              ));
    }
  }

  void uploadProfil(String uid) async {
    setState(() {
      loading = true;
    });
    try {
      String image = await _uploadService.pickUploadImage('users', uid);

      fetchData();
      // ignore: use_build_context_synchronously
      image != ''
          ? showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => MyDialog(
                    message: 'BERHASIL DISIMPAN',
                    createPage: IndexPage.routeName,
                    arguments: 3,
                    isBack: false,
                    isGo: false,
                  ))
          : const Text('');
    } catch (e) {
      // ignore: use_build_context_synchronously
      setState(() {
        loading = false;
      });
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MyDialog(
                message: 'GAGAL DISIMPAN',
                createPage: IndexPage.routeName,
                arguments: 3,
                isRedirect: true,
                isGo: false,
              ));
    }
  }

  void handleConfirmation(bool? confirmed) async {
    if (confirmed!) {
      logout();
    }
  }

  void isEnable() {
    noTelpLength = _menu[1]['controller'].text.length > 0 ||
        _menu[1]['controller'].text.length > 9;
    if (_menu[0]['controller'].text.isNotEmpty &&
        _menu[1]['controller'].text.isNotEmpty &&
        _menu[1]['controller'].text.length > 9 &&
        jk != '' &&
        ttl != '' &&
        _menu[4]['controller'].text.isNotEmpty) {
      setState(() {
        enable = true;
      });
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
    }
    var uid = user!['uid'];
    var email = user!['email'];
    var image = user!['image'];
    var name = user!['name'];
    var noTelp = user!['noTelp'];
    if (_menu[0]['controller'].text == '') {
      jk = user!['jk'];
      DateTime dateTime = user!['ttl'].toDate();
      String dateString = dateTime.toString();
      ttl = dateString;
      _menu[0]['controller'].text = name;
      _menu[1]['controller'].text = noTelp;
      _menu[4]['controller'].text = email;
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: RefreshIndicator(
        onRefresh: () {
          loading = true;
          fetchData();
          setState(() {});
          return Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(27),
              child: ListTile(
                leading: SizedBox(
                  // height: 100,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () => uploadProfil(uid),
                        child: image == ''
                            ? const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'assets/images/avatar.png',
                                ),
                              )
                            : SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipOval(
                                  child: FadeInImage(
                                    placeholder: const AssetImage(
                                        'assets/logo/loading_icon.gif'),
                                    image: NetworkImage(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 15,
                            )),
                      )
                    ],
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomText(
                      text: email,
                      style: const TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.only(
                    top: 22, bottom: 20, left: 20, right: 20),
                margin: const EdgeInsets.only(left: 27, right: 27),
                decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _menu.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 2) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: CustomText(
                                    text: _menu[index]["title"],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: DropdownButtonFormField<String>(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        hintText: 'Jenis Kelamin',
                                        border: InputBorder.none,
                                        focusColor: Colors.black,
                                        hoverColor: primaryColor,
                                      ),
                                      value: jk,
                                      items: listJK
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: CustomText(
                                            text: value,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        jk = value.toString();
                                        isEnable();
                                      },
                                    )),
                              ],
                            );
                          } else if (index == 3) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: CustomText(
                                    text: _menu[index]["title"],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: DateTimePicker(
                                      type: DateTimePickerType.date,
                                      initialValue: ttl,
                                      firstDate:
                                          DateTime(currentDate.year - 70),
                                      lastDate: DateTime(currentDate.year + 1),
                                      icon: const Icon(Icons.event),
                                      dateHintText: 'Tanggal Lahir',
                                      decoration: const InputDecoration(
                                          hintText: '',
                                          border: InputBorder.none,
                                          focusColor: Colors.black,
                                          hoverColor: primaryColor),
                                      onChanged: (val) {
                                        setState(() {
                                          ttl = val;
                                          isEnable();
                                        });
                                      },
                                      validator: (val) {
                                        return null;
                                      },
                                      onSaved: (val) {
                                        setState(() {
                                          ttl = val!;
                                          isEnable();
                                        });
                                      },
                                    )),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: CustomText(
                                  text: _menu[index]["title"],
                                  style: const TextStyle(),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: !noTelpLength && index == 1
                                      ? Border.all(width: 1, color: Colors.red)
                                      : null,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  controller: _menu[index]["controller"],
                                  cursorColor: primaryColor,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'work sans'),
                                  decoration: const InputDecoration(
                                      hintText: 'Tulis Disini',
                                      border: InputBorder.none,
                                      focusColor: Colors.black,
                                      hoverColor: primaryColor),
                                  onChanged: (val) => isEnable(),
                                ),
                              ),
                            ],
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButtonTheme(
                            data: CustomButtonStyle(
                                color: enable ? primaryColor : secondaryColor,
                                isBorder: enable ? false : true),
                            child: TextButton(
                                onPressed: () => enable ? _update() : false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  child: CustomText(
                                    text: "Simpan",
                                    style: TextStyle(
                                        color: enable
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ))),
                        const SizedBox(width: 5),
                        TextButtonTheme(
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
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
