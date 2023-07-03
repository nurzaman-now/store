// ignore_for_file: unnecessary_null_comparison, must_be_immutable

import 'package:flutter/material.dart';
import 'package:store/api/courier_services.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/order_services.dart';
import 'package:store/models/order.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../models/courier.dart';
import '../../../widgets/custom_text.dart';

class StatusOrderPage extends StatefulWidget {
  static String routeName = '/status_order_page';
  String idOrder;

  StatusOrderPage(this.idOrder, {Key? key}) : super(key: key);

  @override
  State<StatusOrderPage> createState() => _StatusOrderPageState();
}

class _StatusOrderPageState extends State<StatusOrderPage> {
  final OrderService _orderService = OrderService();
  final CourierServices _courierServices = CourierServices();

  late Orderr _orderr;
  late Courier? _courier;
  late bool loading = true;
  late int status = 0;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    _orderr = await _orderService.getOrderById(widget.idOrder);
    if (_orderr.courier!.isNotEmpty) {
      _courier =
          await _courierServices.fetchCourier(_orderr.courier!, _orderr.resi!);
      if (_courier?.data.summary.status == 'DELIVERED') {
        status = 3;
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();

        // Return false to prevent the default back button behavior
        return false;
      },
      child: Scaffold(
          appBar: const CustomAppbar(
            titleActions: 'Informasi Pengiriman',
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxHeight,
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.all(29),
              padding: const EdgeInsets.only(top: 29, bottom: 29),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(15.0)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: const CustomText(
                          text: 'Status Pengiriman',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 35),
                                // padding: const EdgeInsets.only(left: 70, right: 170),
                                child: Divider(
                                  color: _orderr.status! >= 2
                                      ? primaryColor
                                      : Colors.grey,
                                  thickness: 1,
                                  height: 20,
                                  // padding: const EdgeInsets.only(right: 70, left: 170),
                                  indent: 10,
                                  endIndent: 10,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 35),
                                child: Divider(
                                  color:
                                      status == 3 ? primaryColor : Colors.grey,
                                  thickness: 1,
                                  height: 20,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 70,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 100,
                                      padding: const EdgeInsets.only(top: 5),
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        'assets/logo/packing.png',
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 9),
                                      child: CustomText(
                                        text: "Dikemas",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.local_shipping,
                                        size: 30,
                                        color: _orderr.status! >= 2
                                            ? primaryColor
                                            : Colors.grey,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const CustomText(
                                        text: "Dikirim",
                                        style: TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.stars,
                                        size: 30,
                                        color: status == 3
                                            ? primaryColor
                                            : Colors.grey,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const CustomText(
                                        text: "Selesai",
                                        style: TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      _orderr.status! >= 2
                          ? Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.topCenter,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            CustomText(
                                              text: 'Expedisi',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            CustomText(
                                              text: 'No Resi',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text:
                                                  ': ${_courier?.data.summary.courier ?? _orderr.courier}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            CustomText(
                                              text:
                                                  ': ${_courier?.data.summary.awb ?? 'No resi Invalid'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const CustomText(
                                    text: 'History',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  _courier?.data.history != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                _courier?.data.history.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  CustomText(
                                                    text: _courier
                                                            ?.data
                                                            .history[index]
                                                            .desc ??
                                                        '',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            );
          })),
    );
  }
}
