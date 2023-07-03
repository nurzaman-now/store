// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, must_be_immutable

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/api/fcm_services.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/address_services.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/firebase_services/cart_services.dart';
import 'package:store/firebase_services/order_services.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/firebase_services/user_services.dart';
import 'package:store/models/address.dart';
import 'package:store/models/order.dart';
import 'package:store/ui/global_key.dart';
import 'package:store/ui/user/menus/sub_menu/history_order_page.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../common/money_format_id.dart';
import '../../../../models/shoes.dart';
import '../../../popup/dialog.dart';
import '../../../widgets/custom_collapse.dart';
import '../../../widgets/custom_text.dart';
import 'address_page.dart';

class OrderPage extends StatefulWidget {
  static const routeName = '/order_page';
  static const String title = 'Pembayaran';
  Map<String, dynamic> shoesOrder;

  OrderPage(this.shoesOrder, {Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final AuthService _authService = AuthService();
  final UserServices _userServices = UserServices();
  final AddressServices _addressServices = AddressServices();
  final ShoesService _shoesService = ShoesService();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final FCMService _fcmService = FCMService();
  final TextEditingController _pesan = TextEditingController();
  late Map<String, dynamic>? user;
  late Address? _address;
  final List<Shoes?> _shoeses = [];
  late String idAddress = '';
  late String textAddress = '';

  late bool loading = true;
  late double total = 0;
  late double subTotalProduk = 0;
  late double subTotalDiscount = 0.0;
  late int ongkir = 15000;

  late bool expandShoes = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void handleIdAddress(String? id) async {
    idAddress = id!;
    _address = await _addressServices.getAddressById(idAddress);
    if (_address!.provinsi == '15') {
      ongkir = 15000;
    } else {
      ongkir = 20000;
    }
    total = subTotalProduk - subTotalDiscount + ongkir;
    textAddress = '${_address!.name} '
        '| ${_address!.noTelp} '
        '${_address!.detail}, '
        '${_address!.jln}, '
        '${_address!.wilayah![3]}, '
        '${_address!.wilayah![2]}, '
        '${_address!.wilayah![1]}, '
        '${_address!.wilayah![0]}, '
        '${_address!.kodePos}';
    setState(() {});
  }

  List<Shoes?> removeDuplicates(List<Shoes?> shoesList) {
    List<Shoes?> shoes = [];
    for (int i = 0; i < shoesList.length; i++) {
      Shoes? currentShoes = shoesList[i];
      if (currentShoes != null) {
        bool isDuplicate = false;
        for (int j = i + 1; j < shoesList.length; j++) {
          Shoes? nextShoes = shoesList[j];
          if (nextShoes != null && currentShoes.idShoes == nextShoes.idShoes) {
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          shoes.add(currentShoes);
        }
      }
    }
    return shoes;
  }

  void fetchData() async {
    try {
      user = await _authService.getUser();
      _address = await _addressServices.getAddressesByUtama(user!['uid']);
      if (_address == null) {
        Navigator.of(context).pop();
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const MyDialog(
                  message: 'Silahkan isi alamat tujuan anda terlebih dahulu',
                  image: 'assets/logo/packing.png',
                  createPage: AddressPage.routeName,
                  arguments: [false],
                  isBack: false,
                ));
      }
      for (var element in widget.shoesOrder['idShoes']) {
        Shoes? shoes = await _shoesService.getOneShoe(element);
        _shoeses.add(shoes);
      }
      if (_shoeses[0] != null) {
        total = 0;
        int index = 0;
        for (var element in _shoeses) {
          subTotalProduk += element!.price! * widget.shoesOrder['count'][index];
          subTotalDiscount += element.discount! *
              element.price! *
              widget.shoesOrder['count'][index];
          index++;
        }
        if (_address!.provinsi == '15') {
          ongkir = 15000;
        } else {
          ongkir = 20000;
        }
        total = subTotalProduk - subTotalDiscount + ongkir;
        textAddress = '${_address!.name} '
            '| ${_address!.noTelp} '
            '${_address!.detail}, '
            '${_address!.jln}, '
            '${_address!.wilayah![3]}, '
            '${_address!.wilayah![2]}, '
            '${_address!.wilayah![1]}, '
            '${_address!.wilayah![0]}, '
            '${_address!.kodePos}';

        loading = false;
        setState(() {});
      } else {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const MyDialog(
                  message: 'Produk tidak tesedia',
                  image: 'assets/logo/fail.png',
                  createPage: HistoryOrderPage.routeName,
                  isRedirect: true,
                ));
      }
    } catch (e) {
      rethrow;
    }
  }

  void _checkout() async {
    setState(() {
      loading = true;
    });
    final random = Random();
    List? idCart = widget.shoesOrder['idCart'];
    Orderr orderr = Orderr(
      idUser: user?['uid'],
      noOrder: random.nextInt(10000),
      shoes: _shoeses,
      size: widget.shoesOrder['size'],
      count: widget.shoesOrder['count'],
      pesan: _pesan.text,
      total: total,
      status: 1,
      ongkir: ongkir,
      cancel: [],
      orderAddress: textAddress,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    bool addOrder = await _orderService.addOrder(orderr);
    if (addOrder) {
      List<Shoes?> shoesOrderFillter = removeDuplicates(_shoeses);
      for (var element in shoesOrderFillter) {
        var sizes = element!.sizes;
        int index = 0;
        widget.shoesOrder['size'].forEach((size) {
          if (sizes!.containsKey(size)) {
            sizes[size] = sizes[size]! -
                int.parse(widget.shoesOrder['count'][index].toString());
          }
          index++;
        });
        Shoes shoes = Shoes(
          idShoes: element.idShoes,
          sizes: sizes,
          updatedAt: Timestamp.now(),
        );
        await _shoesService.updateShoes(shoes);
      }
      if (idCart != null) {
        await _cartService.deleteCartMultiple(widget.shoesOrder['idCart']);
        refreshCartPage();
      }
      var usersAdmin = await _userServices.getUsersByRole('admin');
      for (var element in usersAdmin) {
        var data = {
          'uid': element.id,
          'title': 'Pesanan Baru',
          'body': 'Mohon segera dikemas dan dikirim',
          'link': '/admin/history_order_page'
        };
        await _fcmService.sendMessage(element.token!, data);
      }
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MyDialog(
                message: 'Pesanan Sedang Diproses',
                createPage: HistoryOrderPage.routeName,
                isRedirect: true,
              ));
    } else {
      setState(() {
        loading = false;
      });
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MyDialog(
                message: 'Pesanan gagal diproses',
                textColor: Colors.red,
                image: 'assets/logo/fail.png',
                createPage: HistoryOrderPage.routeName,
                isBack: false,
                isGo: false,
              ));
    }
  }

  void expand() {
    setState(() {
      expandShoes = !expandShoes;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    String formattedTotal = formatMoney(total);
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();

        // Return false to prevent the default back button behavior
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: const CustomAppbar(
            titleActions: OrderPage.title,
          ),
          body: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _shoeses.length,
                    itemBuilder: (context, index) {
                      String formattedPrice =
                          formatMoney(_shoeses[index]?.price);
                      return index == 0
                          ? Container(
                              padding: const EdgeInsets.only(
                                  top: 22, bottom: 20, right: 20),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 27, vertical: 5),
                              decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                leading: FractionallySizedBox(
                                  heightFactor: 2,
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            'assets/logo/loading_icon.gif'),
                                        image: NetworkImage(
                                            _shoeses[index]!.image ??
                                                'https://'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: _shoeses[index]!.name ?? '',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          CustomText(
                                            text:
                                                "Ukuran : ${widget.shoesOrder['size'][index]}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ]),
                                    const SizedBox(
                                      height: 28,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        CustomText(
                                          text: formattedPrice,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const CustomText(
                                              text: "Jumlah",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Container(
                                              color: fourColor,
                                              width: 30,
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              alignment: Alignment.center,
                                              child: CustomText(
                                                text: widget.shoesOrder['count']
                                                        [index]
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                index == 1
                                    ? GestureDetector(
                                        onTap: () => expand(),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 27, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: secondaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                  text:
                                                      '${_shoeses.length - 1} produk Lainnya',
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              const Icon(Icons.expand_more)
                                            ],
                                          ),
                                        ))
                                    : const SizedBox(),
                                ExpandedSection(
                                  expand: expandShoes,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 22, bottom: 20, right: 20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 27),
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: ListTile(
                                      leading: FractionallySizedBox(
                                        heightFactor: 2,
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 25),
                                            child: FadeInImage(
                                              placeholder: const AssetImage(
                                                  'assets/logo/loading_icon.gif'),
                                              image: NetworkImage(
                                                  _shoeses[index]!.image ??
                                                      'https://'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  text: _shoeses[index]!.name ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                CustomText(
                                                  text:
                                                      "Ukuran : ${widget.shoesOrder['size'][index]}",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ]),
                                          const SizedBox(
                                            height: 28,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              CustomText(
                                                text: formattedPrice,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  const CustomText(
                                                    text: "Jumlah",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  Container(
                                                    color: fourColor,
                                                    width: 30,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    alignment: Alignment.center,
                                                    child: CustomText(
                                                      text: widget
                                                          .shoesOrder['count']
                                                              [index]
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                    }),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AddressPage.routeName,
                    arguments: [true, handleIdAddress]),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        top: 22, bottom: 20, left: 20, right: 20),
                    margin:
                        const EdgeInsets.only(bottom: 12, left: 27, right: 27),
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 8),
                                  CustomText(
                                    text: "Alamat Pengiriman",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                children: const [
                                  Icon(Icons.crop_square),
                                  Icon(Icons.chevron_right),
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30, top: 10),
                            child: CustomText(
                              text: textAddress,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ])),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      top: 22, bottom: 20, left: 20, right: 20),
                  margin:
                      const EdgeInsets.only(bottom: 12, left: 27, right: 27),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.credit_card),
                            SizedBox(
                              width: 10,
                            ),
                            CustomText(
                              text: "Metode Pembayaran",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 35, top: 10),
                          child: CustomText(
                            text: "COD (Cash On Delivery)",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 35, top: 5),
                          child: CustomText(
                            text: "Bayar Ditempat",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ])),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      top: 22, bottom: 20, left: 20, right: 20),
                  margin:
                      const EdgeInsets.only(bottom: 12, left: 27, right: 27),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.chat),
                            SizedBox(
                              width: 10,
                            ),
                            CustomText(
                              text: "Pesan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 10),
                          child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                controller: _pesan,
                                cursorColor: primaryColor,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  hintText: 'Silahkan Masukan Pesan',
                                  border: InputBorder.none,
                                  focusColor: Colors.black,
                                  hoverColor: primaryColor,
                                ),
                              )),
                        ),
                      ])),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      top: 22, bottom: 20, left: 20, right: 20),
                  margin:
                      const EdgeInsets.only(bottom: 12, left: 27, right: 27),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.monetization_on),
                            SizedBox(
                              width: 10,
                            ),
                            CustomText(
                              text: "Rincian Biaya",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "Subtotal Produk",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  CustomText(
                                    text: formatMoney(subTotalProduk),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "Subtotal Diskon",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  CustomText(
                                    text:
                                        '- ' + formatMoney((subTotalDiscount)),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "Ongkos Kirim",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  CustomText(
                                    text: formatMoney(ongkir),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Divider(
                                color: primaryColor,
                                thickness: 1,
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "Total Pesanan",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  CustomText(
                                    text: formattedTotal,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ])),
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(10),
            padding:
                const EdgeInsets.only(left: 19, top: 10, bottom: 10, right: 19),
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: BoxDecoration(
                color: secondaryColor, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'Total',
                      style: TextStyle(fontSize: 26),
                    ),
                    const CustomText(
                      text: '|',
                      style: TextStyle(fontSize: 26),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    CustomText(
                      text: formattedTotal,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButtonTheme(
                  data: CustomButtonStyle(color: primaryColor),
                  child: TextButton(
                      onPressed: () => _checkout(),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                        child: CustomText(
                          text: 'Buat Pesanan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
