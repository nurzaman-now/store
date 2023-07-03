import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:store/models/user.dart';
import 'package:store/ui/popup/dialog.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../common/styles.dart';
import '../firebase_services/auth_services.dart';
import 'home_page.dart';
import 'widgets/custom_text.dart';

class RegisterPage extends StatefulWidget {
  static String routeName = '/register_page';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();

  final List<String> listJK = <String>['Laki laki', 'Perempuan'];

  late String jk = 'Laki laki';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  bool isButtonEnabled = false;
  bool passwordLength = true;
  bool noTelpLength = true;
  bool rePassSamePass = false;
  bool obscurePass = true;
  bool obscureRePass = true;

  DateTime currentDate = DateTime.now();

  // check button enable
  void _checkButtonStatus() {
    setState(() {
      rePassSamePass = repasswordController.text == passwordController.text;
      passwordLength = passwordController.text.length > 5;
      noTelpLength = noTelpController.text.length > 9;
      isButtonEnabled = nameController.text.isNotEmpty &&
          noTelpController.text.isNotEmpty &&
          jk != '' &&
          birthDateController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          repasswordController.text.isNotEmpty &&
          rePassSamePass &&
          passwordLength &&
          noTelpLength;
    });
  }

  Future<void> _register() async {
    setState(() {
      isButtonEnabled = false;
    });
    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;
    String noTelp = noTelpController.text;
    String birthDay = birthDateController.text;

    Users user = Users(
      email: email.trim(),
      password: password,
      name: name,
      phoneNumber: noTelp,
      gender: jk,
      birthDate: Timestamp.fromDate(DateTime.parse(birthDay)),
      image:
          'https://firebasestorage.googleapis.com/v0/b/roomstock-store.appspot.com/o/avatar.png?alt=media&token=b1c2f014-c88d-4213-800c-079d57971171&_gl=1*x32wo3*_ga*MTc0MjI5ODA0MS4xNjg0MTMzMzMy*_ga_CW55HF8NVT*MTY4NTU0NjE3OC4xMS4xLjE2ODU1NDYxODcuMC4wLjA.',
      token: 'noDevice',
      role: 'user',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // Call the register function with the provided data
    await _authService.register(user).then((value) {
      if (value == 'BERHASIL DAFTAR') {
        // Registration successful, navigate to the next screen or perform other actions
        // ignore: use_build_context_synchronously
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => MyDialog(
                  message: value,
                  createPage: HomePage.routeName,
                  isRedirect: true,
                ));
      } else {
        // Registration failed, handle the error
        _checkButtonStatus();
        if (value.contains('email address is already')) {
          value = 'Email Sudah Terdaftar';
        }
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => MyDialog(
                  message: value.toString(),
                  textColor: Colors.red,
                  image: 'assets/logo/fail.png',
                  createPage: RegisterPage.routeName,
                  isBack: false,
                  isGo: false,
                ));
      }
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
          titleActions: 'Daftar',
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 29, bottom: 29, left: 20, right: 20),
              child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(
                    top: 28,
                    bottom: 28,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(18)),
                  child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: CustomText(
                              text: 'Nama Lengkap',
                              style: TextStyle(fontSize: 12)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            controller: nameController,
                            cursorColor: primaryColor,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusColor: Colors.black,
                                hoverColor: primaryColor),
                            onChanged: (value) => _checkButtonStatus(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: CustomText(
                              text: 'Nomor Telpon',
                              style: TextStyle(fontSize: 12)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border:
                                noTelpLength || noTelpController.text.isEmpty
                                    ? null
                                    : Border.all(width: 1, color: Colors.red),
                          ),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            controller: noTelpController,
                            cursorColor: primaryColor,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusColor: Colors.black,
                                hoverColor: primaryColor),
                            onChanged: (value) => _checkButtonStatus(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: CustomText(
                              text: 'Jenis Kelamin',
                              style: TextStyle(fontSize: 12)),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: DropdownButtonFormField<String>(
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusColor: Colors.black,
                                hoverColor: primaryColor,
                              ),
                              value: jk,
                              items: listJK.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  jk = value.toString();
                                });
                              },
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: CustomText(
                              text: 'Tanggal Lahir',
                              style: TextStyle(fontSize: 12)),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: DateTimePicker(
                              type: DateTimePickerType.date,
                              controller: birthDateController,
                              firstDate: DateTime(currentDate.year - 70),
                              lastDate: DateTime(currentDate.year + 1),
                              icon: const Icon(Icons.event),
                              fieldHintText: 'Tanggal Lahir',
                              decoration: const InputDecoration(
                                  hintText: '',
                                  border: InputBorder.none,
                                  focusColor: Colors.black,
                                  hoverColor: primaryColor),
                              onChanged: (val) {
                                _checkButtonStatus();
                              },
                              validator: (val) {
                                return null;
                              },
                              onSaved: (val) {
                                _checkButtonStatus();
                              },
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: CustomText(
                              text: 'Email', style: TextStyle(fontSize: 12)),
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
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusColor: Colors.black,
                                hoverColor: primaryColor),
                            onChanged: (value) => _checkButtonStatus(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomText(
                                  text: 'Password',
                                  style: TextStyle(fontSize: 12)),
                              passwordLength || passwordController.text.isEmpty
                                  ? const SizedBox()
                                  : const CustomText(
                                      text: 'minimal 6 karakter',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.red)),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: passwordLength ||
                                    passwordController.text.isEmpty
                                ? null
                                : Border.all(width: 1, color: Colors.red),
                          ),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            obscureText: obscurePass,
                            keyboardType: TextInputType.visiblePassword,
                            controller: passwordController,
                            cursorColor: primaryColor,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusColor: Colors.black,
                              hoverColor: primaryColor,
                              fillColor: primaryColor,
                              iconColor: primaryColor,
                              suffixIcon: IconButton(
                                color: primaryColor,
                                icon: Icon(obscurePass
                                    ? Icons.visibility_off
                                    : Icons.visibility),
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
                        const SizedBox(
                          height: 15,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: CustomText(
                              text: 'Konfirmasi Password',
                              style: TextStyle(fontSize: 12)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: rePassSamePass ||
                                    repasswordController.text.isEmpty
                                ? null
                                : Border.all(width: 1, color: Colors.red),
                          ),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            obscureText: obscureRePass,
                            keyboardType: TextInputType.visiblePassword,
                            controller: repasswordController,
                            cursorColor: primaryColor,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusColor: Colors.black,
                              hoverColor: primaryColor,
                              fillColor: primaryColor,
                              iconColor: primaryColor,
                              suffixIcon: IconButton(
                                color: primaryColor,
                                icon: Icon(obscureRePass
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    obscureRePass = !obscureRePass;
                                  });
                                },
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            onChanged: (value) => _checkButtonStatus(),
                          ),
                        ),
                      ])),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: TextButtonTheme(
            data: CustomButtonStyle(
                color: isButtonEnabled ? primaryColor : thirdColor,
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.height * 0.005),
            child: TextButton(
                onPressed: isButtonEnabled ? () => _register() : null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 13, bottom: 13),
                  child: CustomText(
                    text: 'Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isButtonEnabled ? Colors.white : Colors.black,
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
