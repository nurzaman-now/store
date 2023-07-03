// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/order_services.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/models/shoes.dart';
import 'package:store/ui/popup/confirmation.dart';
import 'package:store/ui/user/menus/sub_menu/history_order_page.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';

import '../../../../models/order.dart';

class CancelOrderPage extends StatefulWidget {
  static String routeName = '/cancel_order_page';
  String idOrder;

  CancelOrderPage(this.idOrder, {Key? key}) : super(key: key);

  @override
  State<CancelOrderPage> createState() => _CancelOrderPageState();
}

class _CancelOrderPageState extends State<CancelOrderPage> {
  final OrderService _orderService = OrderService();
  final ShoesService _shoesService = ShoesService();
  late Orderr? _order;
  final List<Shoes?> _shoeses = [];
  late bool confirmed = false;

  final List _reason = [
    [false, "Ingin mengubah alamat pengiriman"],
    [false, "Ingin mengubah pesanan"],
    [false, "Barang tidak tersedia"],
    [false, "tidak dapat membayar pesanan"],
    [false, "Salah pilih barang"],
    [false, "Lainnya"],
  ];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    _order = await _orderService.getOrderById(widget.idOrder);
    // get shoes
    _order!.product?.forEach((element) {
      _shoesService.getOneShoe(element!['id_shoes']).then((value) {
        _shoeses.add(value);
      });
      setState(() {});
    });
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

  void handleConfirmBool() {
    confirmed = false;
    for (var element in _reason) {
      if (element[0]) {
        confirmed = true;
      }
    }
    setState(() {});
  }

  void handleConfirmation(bool? conf) async {
    final List<String> cancel = [];
    for (var element in _reason) {
      if (element[0]) {
        cancel.add(element[1]);
      }
    }
    Orderr orderr = Orderr(
      idOrder: widget.idOrder,
      status: 4,
      cancel: cancel,
    );
    await _orderService.updateOrder(orderr);
    List<Shoes?> shoesOrderFillter = removeDuplicates(_shoeses);
    for (var element in shoesOrderFillter) {
      var sizes = element!.sizes;
      int index = 0;
      for (var size in _order!.size!) {
        if (sizes!.containsKey(size)) {
          sizes[size] =
              sizes[size]! + int.parse(_order!.count![index].toString());
        }
        index++;
      }
      Shoes shoes = Shoes(
        idShoes: element.idShoes,
        sizes: sizes,
        updatedAt: Timestamp.now(),
      );
      await _shoesService.updateShoes(shoes);
    }
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
      child: Scaffold(
          appBar: const CustomAppbar(
            titleActions: 'Batalkan Pesanan',
          ),
          body: Container(
            height: 500,
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.all(29),
            padding: const EdgeInsets.only(top: 29, bottom: 29),
            decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(15.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pilih Alasan Pembatalan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _reason.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Checkbox(
                                value: _reason[index][0],
                                onChanged: (value) {
                                  setState(() {
                                    _reason[index][0] = value ?? false;
                                    handleConfirmBool();
                                  });
                                }),
                            Text(_reason[index][1])
                          ],
                        );
                      }),
                ),
                TextButtonTheme(
                    data: CustomButtonStyle(
                      color: confirmed ? primaryColor : Colors.grey,
                      vertical: 15,
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: TextButton(
                      onPressed: () => confirmed
                          ? showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Confirm(
                                    message: 'Apakah anda yakin?',
                                    createPage: HistoryOrderPage.routeName,
                                    isShowDialog: true,
                                    isRedirect: true,
                                    isGo: true,
                                    messageDialog: "Pesanan Dibatalkan",
                                    imageDialog: "assets/logo/success.png",
                                    onConfirmation: handleConfirmation,
                                  ))
                          : null,
                      child: Text(
                        "Konfirmasi",
                        style: TextStyle(
                            color: confirmed ? Colors.white : primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ))
              ],
            ),
          )),
    );
  }
}
