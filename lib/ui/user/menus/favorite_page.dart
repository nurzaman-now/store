// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:store/common/money_format_id.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/firebase_services/favorite_services.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../common/styles.dart';
import '../../../models/favorite.dart';
import '../../../models/shoes.dart';
import '../../widgets/custom_text.dart';
import 'sub_menu/product_page.dart';

class FavoritePage extends StatefulWidget {
  static const routeName = '/favorite_page';
  static const String title = 'Favorite';

  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favoriteService = FavoriteService();
  final ShoesService _shoesService = ShoesService();
  final AuthService _authService = AuthService();

  late List<Favorite> favorites = [];
  late List<Shoes> shoeses = [];
  late bool loading = true;
  late bool removeFav = true;

  void fetchData() async {
    var user = await _authService.getUser();
    favorites = await _favoriteService.getFavoriteByUserId(user!['uid']);
    shoeses = [];
    if (favorites.isNotEmpty) {
      for (var element in favorites) {
        Shoes? data = await _shoesService.getOneShoe(element.idProduct ?? '');
        if (data != null) {
          shoeses.add(data);
        } else {
          Shoes shoes = Shoes();
          shoeses.add(shoes);
        }
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void deleteFav(int index) async {
    if (removeFav) {
      try {
        setState(() {
          removeFav = false;
        });
        await _favoriteService
            .deleteFavorite(favorites[index].idFavorite ?? '');
        fetchData();
        setState(() {
          removeFav = true;
        });
      } catch (e) {
        setState(() {
          removeFav = true;
        });
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(top: 1, bottom: 29, left: 20, right: 20),
      child: favorites.isEmpty
          ? const Center(child: Text('Data Favorite tidak ada'))
          : RefreshIndicator(
              onRefresh: () {
                fetchData();
                return Future.delayed(const Duration(seconds: 1));
              },
              child: ListView(
                children: [
                  GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        childAspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height /
                                1.5), // Calculate item height dynamically
                      ),
                      itemCount: favorites.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String formattedPrice = '';
                        if (shoeses.isNotEmpty &&
                            shoeses[index].price != null) {
                          formattedPrice = formatMoney(shoeses[index].price);
                        }
                        return LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return GestureDetector(
                            onTap: () {
                              if (shoeses.isNotEmpty &&
                                  shoeses[index].idShoes != null) {
                                Navigator.pushNamed(
                                    context, ProductPage.routeName,
                                    arguments: shoeses[index].idShoes);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 6, bottom: 8, right: 6),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 4,
                                color: secondaryColor,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            topRight: Radius.circular(18),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            height: constraints.maxHeight * 0.6,
                                            // Adjust the image height as needed
                                            padding: const EdgeInsets.all(8.0),
                                            child: shoeses.isNotEmpty &&
                                                    shoeses[index].image != null
                                                ? FadeInImage(
                                                    placeholder: const AssetImage(
                                                        'assets/logo/loading_icon.gif'),
                                                    image: NetworkImage(
                                                        shoeses[index].image ??
                                                            ''),
                                                    fit: BoxFit.scaleDown,
                                                  )
                                                : const FadeInImage(
                                                    placeholder: AssetImage(
                                                        'assets/logo/loading_icon.gif'),
                                                    image: AssetImage(
                                                        'assets/logo/loading.png'),
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                          ),
                                        ),
                                        ListTile(
                                          title: CustomText(
                                            text: shoeses.isNotEmpty &&
                                                    shoeses[index].name != null
                                                ? shoeses[index].name ?? ''
                                                : 'Produk tidak tersedia',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: CustomText(
                                            text: formattedPrice,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                        top: 0,
                                        left: 0,
                                        child: IconButton(
                                          onPressed: () => deleteFav(index),
                                          icon: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      }),
                ],
              ),
            ),
    );
  }
}
