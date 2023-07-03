// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:store/common/money_format_id.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/firebase_services/order_services.dart';

import '../../../../common/styles.dart';
import '../../../../models/order.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_loading.dart';
import '../../../widgets/custom_text.dart';
import 'detail_order_page.dart';

class HistoryOrderPage extends StatefulWidget {
  static const routeName = '/history_order_page';
  static const String title = 'Pesanan';

  HistoryOrderPage({Key? key}) : super(key: key);

  @override
  State<HistoryOrderPage> createState() => HistoryOrderPageState();
}

class HistoryOrderPageState extends State<HistoryOrderPage> {
  final AuthService _authService = AuthService();
  final List<String> _status = ["DIKEMAS", "DIKIRIM", "SELESAI", "DIBATALKAN"];
  final OrderService _orderService = OrderService();
  late Map<String, dynamic>? user;
  late List<Orderr> _orders = [];

  late bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  void fetchData() async {
    user = await _authService.getUser();
    _orders = await _orderService.getOrdersByIdUser(user!['uid']);
    loading = false;
    setState(() {});
  }

  Future _handleRefresh() {
    fetchData();
    return Future.delayed(const Duration(seconds: 1));
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
      child: DefaultTabController(
        length: _status.length,
        child: Scaffold(
          appBar: CustomAppbar(
            titleActions: HistoryOrderPage.title,
            bottomItem: TabBar(
              indicatorColor: primaryColor,
              isScrollable: true,
              tabs: List.generate(
                _status.length,
                (index) => Tab(
                    icon: CustomText(
                  text: _status[index],
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                )),
              ),
            ),
            isBottom: true,
          ),
          body: loading
              ? const CustomLoading()
              : TabBarView(
                  children: List.generate(
                      _status.length,
                      (index) => RefreshIndicator(
                            onRefresh: () => _handleRefresh(),
                            child: ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index2) {
                                if (_orders[index2].status == (index + 1)) {
                                  Orderr? orderr = _orders[index2];
                                  String formattedPrice = formatMoney(
                                      orderr.product![0]!['price'] ?? 0);
                                  String formattedTotal =
                                      formatMoney(orderr.total ?? 0);

                                  return GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                          context, DetailOrderPage.routeName,
                                          arguments: orderr.idOrder),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(20),
                                        margin: const EdgeInsets.fromLTRB(
                                            27, 15, 27, 0),
                                        decoration: BoxDecoration(
                                            color: secondaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Stack(
                                          children: [
                                            CustomText(
                                              text: _status[index],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  height: 100,
                                                  width: 80,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 25),
                                                    child: FadeInImage(
                                                      placeholder: const AssetImage(
                                                          'assets/logo/loading_icon.gif'),
                                                      image: NetworkImage(
                                                          orderr.product![0]![
                                                                  'image'] ??
                                                              'https://'),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: orderr.product![0]![
                                                              'name'] ??
                                                          '',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    CustomText(
                                                      text:
                                                          "Ukuran : ${orderr.size![0]}",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.45,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                "x ${orderr.count![0]}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          CustomText(
                                                            text:
                                                                formattedPrice,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          const SizedBox(
                                                            width: 120,
                                                            child: Divider(
                                                              height: 1,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          const CustomText(
                                                            text:
                                                                "Total Harga Pesanan",
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          CustomText(
                                                            text:
                                                                formattedTotal,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          orderr.product!
                                                                      .length >
                                                                  1
                                                              ? CustomText(
                                                                  text:
                                                                      '${orderr.product!.length - 1} Produk lainnya',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                )
                                                              : const Text(''),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          )),
                ),
        ),
      ),
    );
  }
}
