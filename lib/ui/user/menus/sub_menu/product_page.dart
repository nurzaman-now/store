// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/common/money_format_id.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/firebase_services/cart_services.dart';
import 'package:store/firebase_services/favorite_services.dart';
import 'package:store/models/favorite.dart';
import 'package:store/ui/user/menus/setting_menus/order_page.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../firebase_services/shoes_services.dart';
import '../../../../models/cart.dart';
import '../../../../models/shoes.dart';
import '../../../popup/dialog.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_text.dart';

class ProductPage extends StatefulWidget {
  static const routeName = '/product_page';
  static const String title = 'produk';
  late String idShoes;

  ProductPage(this.idShoes, {super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final AuthService _authService = AuthService();
  final ShoesService _shoesService = ShoesService();
  final CartService _cartService = CartService();
  final FavoriteService _favoriteService = FavoriteService();
  Map<String, dynamic>? user;
  late Shoes? shoes;
  late List<Favorite> favorite;
  late bool loading = true;
  late bool buttonFav = true;
  late bool buttonCart = true;
  late int selectSize = -1;
  late String selectedSize = '0';
  late Map<String, int>? sortedSizes;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    //check is fav
    user = await _authService.getUser();
    shoes = await _shoesService.getOneShoe(widget.idShoes);
    favorite = await _favoriteService.getFavoriteByProductInUser(
        user!['uid'], shoes!.idShoes ?? '');
    if (shoes!.sizes != null) {
      int index = 0;
      final shoesSizes = shoes!.sizes!;
      sortedSizes = Map<String, int>.fromEntries(
          shoesSizes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      sortedSizes!.forEach((key, value) {
        if (value != 0 && selectSize == -1) {
          selectSize = index;
          selectedSize = key;
        }
        index++;
      });
    }
    loading = false;
    setState(() {});
  }

  void _addToCart() async {
    if (buttonCart) {
      setState(() {
        buttonCart = false;
      });
      try {
        var currentCart = await _cartService.getCartByUserIdProductId(
            user!['uid'], shoes!.idShoes ?? '');
        var currentTime = Timestamp.now();

        if (currentCart.isEmpty || currentCart[0].size != selectedSize) {
          Cart cart = Cart(
            idUser: user!['uid'],
            idProduct: shoes!.idShoes,
            size: sortedSizes!.keys.elementAt(selectSize) ?? '',
            count: 1,
            createdAt: currentTime,
            updatedAt: currentTime,
          );
          await _cartService.createCart(cart);
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const MyDialog(
                    message: 'BERHASIL MENAMBAHKAN KERANJANG',
                    createPage: ProductPage.routeName,
                    arguments: '',
                    isGo: false,
                  ));
        } else {
          Cart cart = Cart(
            idCart: currentCart[0].idCart!,
            count: currentCart[0].count! + 1,
            updatedAt: currentTime,
          );
          await _cartService.updateCart(cart);

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const MyDialog(
                    message: 'BERHASIL MENAMBAHKAN KERANJANG',
                    createPage: ProductPage.routeName,
                    arguments: '',
                    isGo: false,
                  ));
        }
        setState(() {
          buttonCart = true;
        });
      } catch (e) {
        setState(() {
          buttonCart = true;
        });
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const MyDialog(
                  message: 'GAGAL MENAMBAHKAN KERANJANG',
                  textColor: Colors.red,
                  image: 'assets/logo/fail.png',
                  createPage: ProductPage.routeName,
                  arguments: '',
                  isGo: false,
                ));
      }
    }
  }

  void _addToFavorite() async {
    if (buttonFav) {
      setState(() {
        buttonFav = false;
      });
      try {
        final favorites = await _favoriteService.getFavoriteByProductInUser(
            user!['uid'], shoes!.idShoes ?? '');
        if (favorites.isEmpty) {
          Favorite favorite = Favorite(
            idUser: user!['uid'],
            idProduct: shoes!.idShoes,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          );
          await _favoriteService.addFavorite(favorite);
        } else {
          await _favoriteService.deleteFavorite(favorites[0].idFavorite ?? '');
        }
        setState(() {
          buttonFav = true;
        });
        fetchData();
      } catch (e) {
        setState(() {
          buttonFav = true;
        });
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    } else {
      String formattedPrice = formatMoney(shoes!.price);
      final discount = (shoes!.discount ?? 0) * 100;
      return WillPopScope(
          onWillPop: () async {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();

            // Return false to prevent the default back button behavior
            return false;
          },
          child: Scaffold(
            appBar: const CustomAppbar(
              titleActions: ProductPage.title,
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: RefreshIndicator(
                onRefresh: () {
                  fetchData();
                  return Future.delayed(const Duration(seconds: 1));
                },
                child: ListView(children: [
                  const SizedBox(
                    height: 9,
                  ),
                  Center(
                    child: CustomText(
                      text: shoes?.name ?? '',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Stack(children: [
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/logo/loading_icon.gif'),
                          image: NetworkImage(shoes?.image ?? ''),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 50,
                        left: 5,
                        child: Column(
                          children: [
                            const CustomText(
                              text: 'Ukuran',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: ListView.builder(
                                itemCount: sortedSizes!.length ?? 0,
                                itemBuilder: (BuildContext context,
                                        int index) =>
                                    TextButtonTheme(
                                        data: CustomButtonStyle(
                                            color: sortedSizes!.values
                                                        .elementAt(index) !=
                                                    0
                                                ? Colors.white
                                                : Colors.grey,
                                            isBorder: selectSize == index
                                                ? true
                                                : false,
                                            isShadow: true),
                                        child: TextButton(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: CustomText(
                                              text: sortedSizes!.keys
                                                      .elementAt(index)
                                                      .toString() ??
                                                  '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (sortedSizes!.values
                                                    .elementAt(index) !=
                                                0) {
                                              selectSize = index;
                                              selectedSize = sortedSizes!.keys
                                                      .elementAt(index) ??
                                                  '';
                                              setState(() {});
                                            }
                                          },
                                        )),
                              ),
                            )
                          ],
                        )),
                    Positioned(
                        top: 65,
                        right: 8,
                        child: IconButton(
                          icon: favorite.isNotEmpty
                              ? const Icon(
                                  Icons.favorite,
                                  size: 38,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border_outlined,
                                  size: 38,
                                  color: Colors.red,
                                ),
                          onPressed: () => _addToFavorite(),
                        )),
                  ]),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text:
                            "Stock: ${sortedSizes!.values.elementAt(selectSize).toString() ?? ''}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(160),
                              // Flip horizontally
                              child: const Icon(
                                Icons.local_offer,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomText(
                                text: formattedPrice,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              CustomText(
                                text: 'Diskon $discount%',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                            text: 'Description :',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        CustomText(
                            text: shoes!.description!,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )
                ]),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButtonTheme(
                      data: CustomButtonStyle(
                          color: primaryColor,
                          horizontal: MediaQuery.of(context).size.width * 0.25),
                      child: TextButton(
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CustomText(
                            text: 'Beli',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                            context, OrderPage.routeName,
                            arguments: {
                              'idShoes': [shoes!.idShoes],
                              'size': [selectedSize],
                              'count': [1]
                            }),
                      )),
                  const SizedBox(
                    width: 34,
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/logo/cart.svg',
                      width: 150,
                    ),
                    onPressed: () => _addToCart(),
                  )
                ],
              ),
            ),
          ));
    }
  }
}
