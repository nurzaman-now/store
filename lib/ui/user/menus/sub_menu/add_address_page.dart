// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/api/location_service.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/address_services.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/models/address.dart';
import 'package:store/models/address/kabupaten.dart';
import 'package:store/models/address/kecamatan.dart';
import 'package:store/models/address/kelurahan.dart';
import 'package:store/models/address/provinsi.dart';
import 'package:store/ui/user/menus/setting_menus/address_page.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../popup/dialog.dart';
import '../../../widgets/custom_text.dart';

class AddAddressPage extends StatefulWidget {
  static const routeName = '/add_address_page';
  static const String title = 'Tambah Alamat';

  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final List<dynamic> _form = [
    {
      "title": "Nama Lengkap",
      "keyType": TextInputType.text,
      "controller": TextEditingController(),
    },
    {
      "title": "Nomor Telepon",
      "keyType": TextInputType.phone,
      "controller": TextEditingController(),
    },
    {
      "title": "Provinsi",
      "keyType": TextInputType.text,
      "controller": '11',
    },
    {
      "title": "Kabupaten",
      "keyType": TextInputType.text,
      "controller": '1101',
    },
    {
      "title": "Kecamatan",
      "keyType": TextInputType.text,
      "controller": '1101010',
    },
    {
      "title": "Kelurahan",
      "keyType": TextInputType.text,
      "controller": '1101010001',
    },
    {
      "title": "Kode Pos",
      "keyType": TextInputType.number,
      "controller": TextEditingController(),
    },
    {
      "title": "Nama Jalan",
      "keyType": TextInputType.streetAddress,
      "controller": TextEditingController(),
    },
    {
      "title": "Detail Lain (Cth: Blok/ No unit)",
      "keyType": TextInputType.streetAddress,
      "controller": TextEditingController(),
    },
  ];

  final LocationService _locationService = LocationService();
  final AddressServices _addressServices = AddressServices();
  final AuthService _authService = AuthService();

  late List<Provinsi> provinces = [];
  late List<Kabupaten> cities = [];
  late List<Kecamatan> districts = [];
  late List<Kelurahan> villages = [];
  late List wilayah = [];

  late bool _isEnabled = false;
  late bool loading = true;

  late bool errorNoTelp = false;
  late bool errorKodePos = false;

  final List _location = [
    {'name': 'Provinsi'},
    {'name': 'Kabupaten'},
    {'name': 'Kecamatan'},
    {'name': 'Kelurahan'},
  ];

  void _checkEnabledButton() {
    for (var element in _form) {
      if (element["controller"] is String) {
        if (element["controller"] != '') {
          _isEnabled = true;
        } else {
          _isEnabled = false;
        }
      } else {
        if (element["controller"].text != '') {
          _isEnabled = true;
        } else {
          _isEnabled = false;
        }
      }
    }
    if (_form[1]["controller"].text.length > 0 &&
        _form[1]["controller"].text.length < 12) {
      errorNoTelp = true;
      _isEnabled = false;
    } else {
      errorNoTelp = false;
      _isEnabled = true;
    }
    if (_form[6]["controller"].text.length > 0 &&
        _form[6]["controller"].text.length < 5) {
      errorKodePos = true;
      _isEnabled = false;
    } else {
      errorKodePos = false;
      _isEnabled = true;
    }
    setState(() {});
  }

  Future<void> _addAddress() async {
    setState(() {
      loading = true;
    });
    try {
      var user = await _authService.getUser();
      List<Address> addresses =
          await _addressServices.getAddressesByUserId(user!['uid']);
      Address address = Address(
        userId: user['uid'],
        name: _form[0]['controller'].text,
        noTelp: _form[1]['controller'].text,
        provinsi: _form[2]['controller'],
        kabupaten: _form[3]['controller'],
        kecamatan: _form[4]['controller'],
        kelurahan: _form[5]['controller'],
        kodePos: _form[6]['controller'].text,
        jln: _form[7]['controller'].text,
        detail: _form[8]['controller'].text,
        main: addresses.isEmpty ? true : false,
        wilayah: wilayah,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _addressServices.createAddress(address);

      // Registration successful, navigate to the next screen or perform other actions
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MyDialog(
                message: 'BERHASIL DISIMPAN',
                createPage: AddressPage.routeName,
                isRedirect: true,
                arguments: [false],
              ));
    } catch (e) {
      // Registration failed, handle the error
      setState(() {
        loading = false;
      });
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MyDialog(
                message: 'GAGAL DISIMPAN',
                textColor: Colors.red,
                image: 'assets/logo/fail.png',
                createPage: AddressPage.routeName,
                isBack: false,
                isGo: false,
              ));
    }
  }

  void fetchData() async {
    if (provinces.isEmpty &&
        cities.isEmpty &&
        districts.isEmpty &&
        villages.isEmpty) {
      provinces = await _locationService.fetchProvinces();
      cities = await _locationService.fetchCities(provinces[0].id);
      districts = await _locationService.fetchDistricts(cities[0].id);
      villages = await _locationService.fetchVillages(districts[0].id);

      _form[2]['controller'] = provinces[0].id;
      _form[3]['controller'] = cities[0].id;
      _form[4]['controller'] = districts[0].id;
      _form[5]['controller'] = villages[0].id;
    } else {
      cities = await _locationService.fetchCities(_form[2]['controller']);
      districts = await _locationService.fetchDistricts(_form[3]['controller']);
      villages = await _locationService.fetchVillages(_form[4]['controller']);
    }

    bool isCityEmpty =
        cities.where((element) => element.id == _form[3]['controller']).isEmpty;
    if (isCityEmpty) {
      _form[3]['controller'] = cities[0].id;
      wilayah[1] = cities[0].name;
      cities = await _locationService.fetchCities(_form[2]['controller']);
      districts = await _locationService.fetchDistricts(cities[0].id);
    }
    bool isDistrictEmpty = districts
        .where((element) => element.id == _form[4]['controller'])
        .isEmpty;

    if (isDistrictEmpty) {
      _form[4]['controller'] = districts[0].id;
      wilayah[2] = districts[0].name;
      villages = await _locationService.fetchVillages(_form[4]['controller']);
    }
    bool isVillageEmpty = villages
        .where((element) => element.id == _form[5]['controller'])
        .isEmpty;

    if (isVillageEmpty) {
      _form[5]['controller'] = villages[0].id;
      wilayah[3] = villages[0].name;
    }

    //set wilayah
    if (wilayah.isEmpty) {
      wilayah.add(provinces[0].name);
      wilayah.add(cities[0].name);
      wilayah.add(districts[0].name);
      wilayah.add(villages[0].name);
    }

    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();
        // Return false to prevent the default back button behavior
        return false;
      },
      child: loading
          ? const CustomLoading()
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                appBar: const CustomAppbar(
                  titleActions: AddAddressPage.title,
                ),
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  child: TextButtonTheme(
                    data: CustomButtonStyle(
                      color: _isEnabled ? primaryColor : secondaryColor,
                    ),
                    child: TextButton(
                        onPressed: () => _isEnabled ? _addAddress() : null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 13, bottom: 13),
                          child: CustomText(
                            text: 'Simpan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isEnabled ? Colors.white : Colors.black,
                            ),
                          ),
                        )),
                  ),
                ),
                body: ListView(children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          top: 22, bottom: 20, left: 20, right: 20),
                      margin: const EdgeInsets.only(
                          top: 26, left: 27, right: 27, bottom: 26),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: ListView.builder(
                          itemCount: _form.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 2) {
                              return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DropdownButtonFormField<String>(
                                    value: _form[index]['controller'],
                                    isExpanded: true,
                                    items: provinces.map((province) {
                                      return DropdownMenuItem<String>(
                                        value: province.id,
                                        child: CustomText(
                                          text: province.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      _form[index]['controller'] = value!;
                                      Provinsi selectedProvince = provinces
                                          .firstWhere((p) => p.id == value);
                                      wilayah[0] = selectedProvince.name;
                                      fetchData();
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: _location[index - 2]['name'],
                                      border: InputBorder.none,
                                      labelStyle:
                                          const TextStyle(color: primaryColor),
                                    ),
                                  ));
                            } else if (index == 3) {
                              return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DropdownButtonFormField<String>(
                                    value: _form[index]['controller'],
                                    isExpanded: true,
                                    items: cities.map((city) {
                                      return DropdownMenuItem<String>(
                                        value: city.id,
                                        child: CustomText(
                                          text: city.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      _form[index]['controller'] = value!;
                                      Kabupaten selectedCity = cities
                                          .firstWhere((p) => p.id == value);
                                      wilayah[1] = selectedCity.name;
                                      fetchData();
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                        labelText: _location[index - 2]['name'],
                                        border: InputBorder.none,
                                        labelStyle: const TextStyle(
                                            color: primaryColor)),
                                  ));
                            } else if (index == 4) {
                              return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DropdownButtonFormField<String>(
                                    value: _form[index]['controller'],
                                    isExpanded: true,
                                    items: districts.map((district) {
                                      return DropdownMenuItem<String>(
                                        value: district.id,
                                        child: CustomText(
                                          text: district.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      _form[index]['controller'] = value!;
                                      Kecamatan selectedDistict = districts
                                          .firstWhere((p) => p.id == value);
                                      wilayah[2] = selectedDistict.name;
                                      fetchData();
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                        labelText: _location[index - 2]['name'],
                                        border: InputBorder.none,
                                        labelStyle: const TextStyle(
                                            color: primaryColor)),
                                  ));
                            } else if (index == 5) {
                              return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DropdownButtonFormField<String>(
                                    value: _form[index]['controller'],
                                    isExpanded: true,
                                    items: villages.map((village) {
                                      return DropdownMenuItem<String>(
                                        value: village.id,
                                        child: CustomText(
                                          text: village.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      _form[index]['controller'] = value!;
                                      Kelurahan selectedVillage = villages
                                          .firstWhere((p) => p.id == value);
                                      wilayah[3] = selectedVillage.name;
                                      fetchData();
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                        labelText: _location[index - 2]['name'],
                                        border: InputBorder.none,
                                        labelStyle: const TextStyle(
                                            color: primaryColor)),
                                  ));
                            }
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: index == 1 && errorNoTelp ||
                                          index == 6 && errorKodePos
                                      ? Border.all(width: 1, color: Colors.red)
                                      : null),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                keyboardType: _form[index]["keyType"],
                                controller: _form[index]["controller"],
                                cursorColor: primaryColor,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: _form[index]["title"],
                                  border: InputBorder.none,
                                  focusColor: Colors.black,
                                  hoverColor: primaryColor,
                                ),
                                onChanged: (value) => _checkEnabledButton(),
                              ),
                            );
                          })),
                ]),
              )),
    );
  }
}
