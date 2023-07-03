// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store/common/money_format_id.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/order_services.dart';
import 'package:store/ui/user/menus/sub_menu/status_order_page.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_collapse.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../../firebase_services/shoes_services.dart';
import '../../../../../models/order.dart';
import '../../../../../models/shoes.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_text.dart';
import 'update_order_page.dart';

class AdminDetailOrderPage extends StatefulWidget {
  static const routeName = '/admin/detail_order_page';
  static const String title = 'Rincian Pesanan';
  static String idAddress = '';
  String idOrder = '';

  AdminDetailOrderPage(this.idOrder, {Key? key}) : super(key: key);

  @override
  State<AdminDetailOrderPage> createState() => _AdminDetailOrderPageState();
}

class _AdminDetailOrderPageState extends State<AdminDetailOrderPage> {
  final OrderService _orderService = OrderService();
  final ShoesService _shoesService = ShoesService();
  late Orderr? order;
  late bool loading = true;
  late double subTotalProduk = 0;
  late double subTotalDiscount = 0;
  late int ongkir = 15000;

  late bool expandShoes = false;

  List<String> status = [
    "Pesanan anda dalam Proses Pengemasan",
    "Pesanan anda dalam Proses Pengiriman",
    "Pesanan anda telah diterima",
    "Pesanan anda dibatalkan"
  ];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    order = await _orderService.getOrderById(widget.idOrder);

    //get sub total
    int index = 0;
    order!.product?.forEach((element) {
      subTotalProduk += element!['price'] * order!.count![index];
      subTotalDiscount +=
          element['discount'] * element['price'] * order!.count![index];
      index++;
    });
    ongkir = order!.ongkir!;
    loading = false;
    setState(() {});
  }

  void hanldeSelesai(bool? confirm) async {
    if (confirm!) {
      if (order!.status == 3) {
        for (var element in order!.shoes!) {
          Shoes shoes = Shoes(
            idShoes: element!.idShoes,
            sold: element.sold! + 1,
            updatedAt: Timestamp.now(),
          );
          await _shoesService.updateShoes(shoes);
        }
      }
      Orderr orderr = Orderr(
        idOrder: order!.idOrder,
        status: 3,
        updatedAt: Timestamp.now(),
      );
      await _orderService.updateOrder(orderr);
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
    String formattedTotal = formatMoney(order?.total ?? 0);
    Timestamp? createdDate = order!.createdAt;
    Timestamp? updatedDate = order!.updatedAt;

    DateTime createdDateTime = createdDate!.toDate();
    String formattedCreatedDateTime =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(createdDateTime);

    DateTime updatedDateTime = updatedDate!.toDate();
    String formattedUpdatedDateTime =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedDateTime);

    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();

        // Return false to prevent the default back button behavior
        return false;
      },
      child: Scaffold(
          appBar: const CustomAppbar(
            titleActions: AdminDetailOrderPage.title,
          ),
          body: RefreshIndicator(
            onRefresh: () {
              fetchData();
              return Future.delayed(const Duration(seconds: 1));
            },
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order!.product?.length,
                      itemBuilder: (context, index) {
                        String formattedPrice =
                        formatMoney(order!.product?[index]!['price']);
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
                                    image: NetworkImage(order!
                                        .product?[index]!['image'] ??
                                        ''),
                                    fit: BoxFit.fitWidth,
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
                                        text: order!.product?[index]![
                                        'name'] ??
                                            '',
                                        style:
                                        const TextStyle(fontSize: 16),
                                      ),
                                      CustomText(
                                        text:
                                        "Ukuran : ${order!.size![index]}",
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
                                      style:
                                      const TextStyle(fontSize: 16),
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
                                            text: order?.count![index]
                                                .toString() ??
                                                '',
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
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  height: MediaQuery
                                      .of(context)
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
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      CustomText(
                                          text:
                                          '${order!.product!.length -
                                              1} produk Lainnya',
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
                                        padding: const EdgeInsets.only(
                                            top: 25),
                                        child: FadeInImage(
                                          placeholder: const AssetImage(
                                              'assets/logo/loading_icon.gif'),
                                          image: NetworkImage(
                                              order!.product?[index]![
                                              'image'] ??
                                                  ''),
                                          fit: BoxFit.fitWidth,
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
                                              text: order!.product?[
                                              index]!['name'] ??
                                                  '',
                                              style: const TextStyle(
                                                  fontSize: 16),
                                            ),
                                            CustomText(
                                              text:
                                              "Ukuran : ${order!.size![index]}",
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
                                                style: TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Container(
                                                color: fourColor,
                                                width: 30,
                                                margin:
                                                const EdgeInsets.only(
                                                    left: 10),
                                                alignment:
                                                Alignment.center,
                                                child: CustomText(
                                                  text: order
                                                      ?.count![index]
                                                      .toString() ??
                                                      '',
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
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                              Icon(Icons.location_on),
                              SizedBox(
                                width: 10,
                              ),
                              CustomText(
                                text: "Alamat Pengiriman",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30, top: 10),
                            child: CustomText(
                              text: order!.orderAddress!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ])),
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                              Icon(Icons.credit_card),
                              SizedBox(
                                width: 10,
                              ),
                              CustomText(
                                text: "Metode Pembayaran",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 35, top: 10),
                            child: CustomText(
                              text: "COD (Cash On Delivery)",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(
                          context, StatusOrderPage.routeName,
                          arguments: order!.idOrder),
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      padding: const EdgeInsets.only(
                          top: 22, bottom: 20, left: 20, right: 20),
                      margin: const EdgeInsets.only(
                          bottom: 12, left: 27, right: 27),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.local_shipping),
                                    SizedBox(width: 8),
                                    CustomText(
                                      text: "Informasi Pengiriman",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: status[order!.status! - 1],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        text: "Catatan : ",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(
                                        width:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width *
                                            0.45,
                                        child: CustomText(
                                          text: order!.pesan!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )
                                    ],
                                  ),
                                  const CustomText(
                                    text:
                                    "*Pesanan tidak dapat dibatalkan apabila telah dalam proses pengiriman",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ])),
                ),
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                              Icon(Icons.monetization_on_outlined),
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
                                      text: '- ' +
                                          formatMoney((subTotalDiscount)),
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
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                              Icon(Icons.info_outline_rounded),
                              SizedBox(
                                width: 10,
                              ),
                              CustomText(
                                text: "Detail Pesanan",
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
                                      text: "No Pesanan:",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    CustomText(
                                      text: order!.noOrder.toString(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const CustomText(
                                      text: "Waktu Pemesanan",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    CustomText(
                                      text: formattedCreatedDateTime,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                order!.status != 1 && order!.status != 4
                                    ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const CustomText(
                                      text: "Waktu Pengiriman",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    CustomText(
                                      text: formattedUpdatedDateTime,
                                      style:
                                      const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                        ])),
              ],
            ),
          ),
          bottomNavigationBar: order!.status! <= 2
              ? Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextButtonTheme(
              data: CustomButtonStyle(
                  color: primaryColor,
                  horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.1,
                  vertical: 15.0),
              child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(
                          context, UpdateOrderPage.routeName,
                          arguments: order!.idOrder),
                  child: CustomText(
                    text: order!.status! == 1
                        ? 'Ubah status ke dikirim'
                        : 'Update kode resi',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ),
          )
              : null),
    );
  }
}
