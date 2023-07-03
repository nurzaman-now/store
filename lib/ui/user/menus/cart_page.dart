import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store/firebase_services/auth_services.dart';

import '../../../common/styles.dart';
import '../../../firebase_services/cart_services.dart';
import '../../../firebase_services/shoes_services.dart';
import '../../../models/cart.dart';
import '../../../models/shoes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_loading.dart';
import '../../widgets/custom_text.dart';
import 'setting_menus/order_page.dart';

class CartPage extends StatefulWidget {
  static const routeName = '/cart_page';
  static const String title = 'Keranjang';

  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final AuthService _authService = AuthService();
  final ShoesService _shoesService = ShoesService();
  final CartService _cartService = CartService();

  late Map<String, dynamic>? user;
  late List shoeses = [];
  late List<Cart> cart;
  late double _total = 0;
  late String _formattedTotal;
  late bool loading = true;

  late List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  void _funcFormattedTotal(int index, bool check) {
    setState(() {
      check
          ? _items[index]["total"] =
              _items[index]["count"] * shoeses[index].price.toDouble()
          : _items[index]["total"] = 0.0;

      _total = 0;
      _items.map((e) {
        return _total += e["total"];
      }).toList();
      _formattedTotal = NumberFormat.currency(symbol: 'Rp. ').format(_total);
    });
  }

  void fetchData() async {
    user = await _authService.getUser();
    cart = await _cartService.getCartByUserId(user!['uid']);
    shoeses = [];
    for (var element in cart) {
      Shoes? data = await _shoesService.getOneShoe(element.idProduct!);
      shoeses.add(data);
    }
    _items = [];
    if (_items.isEmpty) {
      _items = List.generate(
        shoeses.length,
        (index) => {"select": false, "count": 0, "total": 0},
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void updateCount(String idCart, int index) async {
    Cart cart = Cart(
      idCart: idCart,
      count: _items[index]['count'],
      updatedAt: Timestamp.now(),
    );
    await _cartService.updateCart(cart);
  }

  void deleteCart(int index) async {
    setState(() {
      loading = true;
    });
    await _cartService.deleteCart(cart[index].idCart!);
    _items.removeAt(index);
    fetchData();
  }

  void checkout() {
    List idShoes = [];
    List idCart = [];
    List sizes = [];
    List count = [];
    int index = 0;
    for (var element in _items) {
      if (element['select']) {
        idShoes.add(shoeses[index].idShoes);
        idCart.add(cart[index].idCart);
        sizes.add(cart[index].size);
        count.add(_items[index]['count']);
      }
      index++;
    }
    Navigator.pushNamed(context, OrderPage.routeName, arguments: {
      'idShoes': idShoes,
      'idCart': idCart,
      'size': sizes,
      'count': count
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(bottom: 29, left: 20, right: 20),
          alignment: Alignment.center,
          child: RefreshIndicator(
            onRefresh: () {
              fetchData();
              return Future.delayed(const Duration(seconds: 1));
            },
            child: cart.isEmpty
                ? const Center(
                    child: Text('Keranjang kosong, silahkan belanja'))
                : RefreshIndicator(
                    onRefresh: () {
                      loading = true;
                      fetchData();
                      setState(() {});
                      return Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (BuildContext context, int index) {
                          String formattedPrice = '';
                          int stock = 0;
                          if (shoeses[index] != null) {
                            formattedPrice =
                                NumberFormat.currency(symbol: 'Rp. ')
                                    .format(shoeses[index].price);
                            shoeses[index].sizes.removeWhere(
                                (key, value) => key != cart[index].size);
                            stock = shoeses[index].sizes[cart[index].size];
                          }
                          _items[index]['count'] == 0
                              ? _items[index]['count'] = cart[index].count
                              : 1;
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 10, 10,
                                    index + 1 == shoeses.length ? 100 : 10),
                                padding: const EdgeInsets.only(
                                    left: 19, top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(18)),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(top: 16),
                                  leading: FractionallySizedBox(
                                    heightFactor: 1.8,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 25),
                                      child: shoeses[index] != null
                                          ? FadeInImage(
                                              placeholder: const AssetImage(
                                                  'assets/logo/loading_icon.gif'),
                                              image: NetworkImage(
                                                  shoeses[index].image),
                                              fit: BoxFit.cover,
                                            )
                                          : const FadeInImage(
                                              placeholder: AssetImage(
                                                  'assets/logo/loading_icon.gif'),
                                              image: AssetImage(
                                                  'assets/logo/loading.png'),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  title: Container(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: shoeses[index] != null
                                              ? shoeses[index].name
                                              : 'Produk tidak tersedia',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomText(
                                          text: 'Ukuran: ${cart[index].size}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomText(
                                          text: 'Stock: $stock',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        CustomText(
                                          text: formattedPrice,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 25,
                                              width: 91,
                                              color: fourColor,
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: FractionallySizedBox(
                                                      widthFactor: 1,
                                                      heightFactor: 1,
                                                      child: IconButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          onPressed: () {
                                                            if (shoeses[
                                                                    index] !=
                                                                null) {
                                                              setState(() {
                                                                if (_items[index]
                                                                        [
                                                                        "count"] !=
                                                                    1) {
                                                                  _items[index][
                                                                      "count"]--;
                                                                  _funcFormattedTotal(
                                                                      index,
                                                                      _items[index]
                                                                              [
                                                                              "select"]
                                                                          ? true
                                                                          : false);
                                                                  updateCount(
                                                                      cart[index]
                                                                          .idCart!,
                                                                      index);
                                                                }
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.remove)),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            left: BorderSide(
                                                                width: 1,
                                                                color: Colors
                                                                    .black),
                                                            right: BorderSide(
                                                                width: 1,
                                                                color: Colors
                                                                    .black))),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 9, right: 9),
                                                    child: Text(_items[index]
                                                            ['count']
                                                        .toString()),
                                                  ),
                                                  Expanded(
                                                    child: FractionallySizedBox(
                                                      widthFactor: 1,
                                                      heightFactor: 1,
                                                      child: IconButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          onPressed: () {
                                                            if (shoeses[index] !=
                                                                    null &&
                                                                _items[index][
                                                                        'count'] <
                                                                    stock) {
                                                              setState(() {
                                                                _items[index]
                                                                    ["count"]++;
                                                                _funcFormattedTotal(
                                                                    index,
                                                                    _items[index]
                                                                            [
                                                                            "select"]
                                                                        ? true
                                                                        : false);
                                                                updateCount(
                                                                    cart[index]
                                                                        .idCart!,
                                                                    index);
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.add)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: IconButton(
                                                  onPressed: () =>
                                                      deleteCart(index),
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: primaryColor,
                                                  )),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Checkbox(
                                    value: _items[index]["select"],
                                    onChanged: (bool? value) {
                                      if (shoeses[index] != null &&
                                          stock != 0) {
                                        setState(() {
                                          _items[index]["select"] =
                                              value ?? false;
                                          _funcFormattedTotal(
                                              index, _items[index]["select"]);
                                        });
                                      }
                                    }),
                              ),
                            ],
                          );
                        }),
                  ),
          ),
        ),
        _items.any((element) => element["select"] == true)
            ? Positioned(
                bottom: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.only(
                        left: 19, top: 10, bottom: 10, right: 19),
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CustomText(
                              text: 'Total',
                              style: TextStyle(fontSize: 20),
                            ),
                            const CustomText(
                              text: '|',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            CustomText(
                              text: _formattedTotal,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButtonTheme(
                          data: CustomButtonStyle(
                              color: primaryColor,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.26),
                          child: TextButton(
                              onPressed: () => checkout(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: CustomText(
                                  text: 'Checkout',
                                  style: TextStyle(
                                    fontSize: 24,
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
              )
            : const Text('')
      ],
    );
  }
}
