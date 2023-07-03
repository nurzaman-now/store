// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/models/address.dart';
import 'package:store/ui/user/menus/sub_menu/add_address_page.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../firebase_services/address_services.dart';
import '../../../popup/confirmation.dart';
import '../../../widgets/custom_text.dart';

class AddressPage extends StatefulWidget {
  static const routeName = '/address_page';
  static const String title = 'Alamat';
  List item = [false];

  // bool isSelectAddress = false;
  // final void Function(String) onConfirmation;

  AddressPage(this.item, {Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final AuthService _authService = AuthService();
  final AddressServices _address = AddressServices();

  late List<Address> addresses = [];
  late bool loading = true;
  late String addressId = '';

  void fetchData() async {
    var user = await _authService.getUser();
    addresses = await _address.getAddressesByUserId(user!['uid']);
    setState(() {
      loading = false;
    });
  }

  void _handleUtama(int index) async {
    if (!addresses[index].main!) {
      setState(() {
        loading = true;
      });
      Address address = Address(
        id: addresses[index].id,
        main: true,
        updatedAt: Timestamp.now(),
      );
      await _address.utamaAddress(address);
      fetchData();
    }
  }

  void deleteAddress() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Confirm(
              message: 'Apakah yakin ingin menghapusnya?',
              createPage: AddressPage.routeName,
              imageDialog: 'assets/logo/success.png',
              messageDialog: 'Berhasil dihapus',
              argument: const [false],
              isBack: false,
              isGo: false,
              onConfirmation: handleConfirmation,
            ));
  }

  void handleConfirmation(bool? confirmed) async {
    if (confirmed!) {
      await _address.deleteAddress(addressId);
      if (addresses.isNotEmpty) {
        late bool toUtama = false;
        addresses.removeWhere((element) => element.id == addressId);
        for (var element in addresses) {
          if (element.main == false) {
            toUtama = true;
          } else {
            toUtama = false;
            break;
          }
        }
        if (toUtama) {
          _handleUtama(0);
        } else {
          setState(() {
            loading = true;
          });
        }
      }
      fetchData();
    }
  }

  @override
  void initState() {
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
            : Scaffold(
                appBar: const CustomAppbar(
                  titleActions: AddressPage.title,
                ),
                body: addresses.isEmpty
                    ? const Center(
                        child: CustomText(
                        text: 'Silahkan Tambahkan Alamat anda, sebelum memesan',
                        style: TextStyle(fontSize: 12),
                      ))
                    : RefreshIndicator(
                        onRefresh: () {
                          fetchData();
                          return Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (widget.item[0]) {
                                    widget.item[1](addresses[index].id);
                                    // OrderPage.idAddress = 'idAddress';
                                    Navigator.pop(context);
                                  } else {
                                    _handleUtama(index);
                                  }
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        top: 22,
                                        bottom: 20,
                                        left: 20,
                                        right: 20),
                                    margin: const EdgeInsets.only(
                                        top: 26, left: 27, right: 27),
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Stack(
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: const [
                                                  Icon(Icons.location_on),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  CustomText(
                                                    text: "Alamat Pengiriman",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30, top: 20),
                                                child: CustomText(
                                                  text:
                                                      '${addresses[index].name} '
                                                      '| ${addresses[index].noTelp} '
                                                      '${addresses[index].detail}, '
                                                      '${addresses[index].jln}, '
                                                      '${addresses[index].wilayah![3]}, '
                                                      '${addresses[index].wilayah![2]}, '
                                                      '${addresses[index].wilayah![1]}, '
                                                      '${addresses[index].wilayah![0]}, '
                                                      '${addresses[index].kodePos}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              addresses[index].main!
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 10),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color: primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: const CustomText(
                                                        text: "Utama",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ]),
                                        Positioned(
                                          top: -15,
                                          right: -15,
                                          child: IconButton(
                                              onPressed: () {
                                                addressId =
                                                    addresses[index].id!;
                                                deleteAddress();
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: primaryColor,
                                              )),
                                        ),
                                      ],
                                    )),
                              );
                            }),
                      ),
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  child: TextButtonTheme(
                    data: CustomButtonStyle(color: primaryColor),
                    child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AddAddressPage.routeName),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 13, bottom: 13),
                          child: CustomText(
                            text: '+ Tambah Alamat Baru',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ),
                ),
              ));
  }
}
