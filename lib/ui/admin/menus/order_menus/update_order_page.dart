// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/api/fcm_services.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/order_services.dart';
import 'package:store/firebase_services/user_services.dart';
import 'package:store/ui/admin/index_page.dart';
import 'package:store/ui/popup/confirmation.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../api/courier_services.dart';
import '../../../../models/list_courier.dart';
import '../../../../models/order.dart';
import '../../../../models/user.dart';

class UpdateOrderPage extends StatefulWidget {
  static String routeName = '/admin/update_order_page';
  String idOrder;

  UpdateOrderPage(this.idOrder, {Key? key}) : super(key: key);

  @override
  State<UpdateOrderPage> createState() => _UpdateOrderPageState();
}

class _UpdateOrderPageState extends State<UpdateOrderPage> {
  final UserServices _userServices = UserServices();
  final OrderService _orderService = OrderService();
  final CourierServices _courierServices = CourierServices();
  final FCMService _fcmService = FCMService();

  late Orderr? order;
  late Users? user;
  late List<ListCourier> courier = [];
  late bool loading = true;
  late bool confirmed = false;

  final TextEditingController _resiController = TextEditingController();
  late String _courierController;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    _courierController = '';
    courier = await _courierServices.fetchListCourier();
    order = await _orderService.getOrderById(widget.idOrder);
    user = await _userServices.getUserById(order!.idUser!);
    if (order!.courier != '') {
      _courierController = order!.courier!;
      _resiController.text = order!.resi!;
    } else {
      _courierController = courier[0].code;
    }
    setState(() {
      loading = false;
    });
  }

  void _handleConfirmBool() {
    confirmed = false;
    if (_courierController.isNotEmpty && _resiController.text.isNotEmpty) {
      confirmed = true;
    }
    setState(() {});
  }

  void handleConfirmation(bool? conf) async {
    if (conf!) {
      Orderr orderr = Orderr(
        idOrder: widget.idOrder,
        courier: _courierController,
        resi: _resiController.text,
        status: 2,
        updatedAt: Timestamp.now(),
      );
      await _orderService.updateOrder(orderr);
      var data = {
        'uid': user!.id,
        'title': 'Pesan Baru',
        'body': 'Pesanan anda ${order!.noOrder} dalam proses pengiriman',
        'link': '/history_order_page'
      };
      await _fcmService.sendMessage(user!.token!, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const CustomLoading()
        : WillPopScope(
            onWillPop: () async {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();

              // Return false to prevent the default back button behavior
              return false;
            },
            child: Scaffold(
                appBar: const CustomAppbar(
                  titleActions: 'Kirim Pesanan',
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
                        "Masukan kurir dan resi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 27),
                        child: Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18)),
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: DropdownButtonFormField<String>(
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: 'Kurir',
                                    border: InputBorder.none,
                                    focusColor: Colors.black,
                                    hoverColor: primaryColor,
                                  ),
                                  value: _courierController,
                                  items: courier.map((ListCourier item) {
                                    return DropdownMenuItem<String>(
                                      value: item.code,
                                      child: Text(item.description),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _courierController = value.toString();
                                    });
                                    _handleConfirmBool;
                                  },
                                )),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18)),
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                controller: _resiController,
                                cursorColor: primaryColor,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontFamily: 'work sans'),
                                decoration: const InputDecoration(
                                    hintText: 'Kode Resi',
                                    border: InputBorder.none,
                                    focusColor: Colors.black,
                                    hoverColor: primaryColor),
                                onChanged: (value) => _handleConfirmBool(),
                              ),
                            ),
                          ],
                        ),
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
                                          createPage: AdminIndexPage.routeName,
                                          isShowDialog: true,
                                          isRedirect: true,
                                          argument: 1,
                                          messageDialog: order!.status == 1
                                              ? "Pesanan dikirim"
                                              : "Resi diperbarui",
                                          imageDialog:
                                              "assets/logo/success.png",
                                          onConfirmation: handleConfirmation,
                                        ))
                                : null,
                            child: Text(
                              "Konfirmasi",
                              style: TextStyle(
                                  color:
                                      confirmed ? Colors.white : primaryColor,
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
