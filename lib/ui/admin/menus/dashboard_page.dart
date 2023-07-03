import 'package:flutter/material.dart';
import 'package:store/common/money_format_id.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/category_services.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/models/categories.dart';
import 'package:store/models/shoes.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import 'order_menus/manage_product_page.dart';

class AdminDashboardPage extends StatefulWidget {
  static const routeName = '/admin/dashboard_page';
  static const String title = 'Roomstock';

  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ShoesService _shoesService = ShoesService();
  final CategoryService _kategoriService = CategoryService();

  int _categoryIndex = 0;
  late List<Shoes> shoeses = [];
  late List<Shoes> shoesesTop = [];
  late List<Categories> categories = [];
  late List listKategori = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _categoryToIndex(int index) async {
    _categoryIndex = index;
    if (index == 0) {
      shoeses = await _shoesService.getAllShoes();
    } else {
      var idKategori = listKategori[index - 1];
      shoeses = await _shoesService.getShoesByCategoryId(idKategori);
    }
    setState(() {});
  }

  void fetchData() async {
    _categoryToIndex(_categoryIndex);

    shoesesTop =
        await _shoesService.getTopSoldShoes(5); // mengambil data top 5 shoes

    // mengambil semua kategori
    categories = await _kategoriService.getAllCategory();

    //set list kategori
    listKategori = [];
    for (var element in categories) {
      listKategori.add(element.idKategori);
    }
    // set loading false
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 16),
      child: RefreshIndicator(
        onRefresh: () {
          loading = true;
          fetchData();
          setState(() {});
          return Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(children: [
          const SizedBox(
            height: 9,
          ),
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: TextButtonTheme(
                            data: CustomButtonStyle(
                              color: _categoryIndex == index
                                  ? primaryColor
                                  : Colors.white,
                              isShadow: true,
                            ),
                            child: TextButton(
                                onPressed: () => _categoryToIndex(index),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomText(
                                    text: 'Semua',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _categoryIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                )),
                          ));
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      child: TextButtonTheme(
                        data: CustomButtonStyle(
                          color: _categoryIndex == index
                              ? primaryColor
                              : Colors.white,
                          isShadow: true,
                        ),
                        child: TextButton(
                            onPressed: () => _categoryToIndex(index),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                text: categories[index - 1].name!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _categoryIndex == index
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            )),
                      ),
                    );
                  }),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          shoeses.isEmpty
              ? const Center(
                  child: CustomText(
                    text: 'Data Kosong',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        childAspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height /
                                1.5), // Calculate item height dynamically
                      ),
                      itemCount: shoeses.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String formattedPrice =
                            formatMoney(shoeses[index].price);
                        return LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              ManageProductPage.routeName,
                              arguments: shoeses[index].idShoes,
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 6, bottom: 8, right: 6),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 4,
                                color: secondaryColor,
                                child: Column(
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
                                        child: FadeInImage(
                                          placeholder: const AssetImage(
                                              'assets/logo/loading_icon.gif'),
                                          image: NetworkImage(
                                              shoeses[index].image ?? ''),
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: CustomText(
                                        text: shoeses[index].name ?? '',
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
                              ),
                            ),
                          );
                        });
                      }),
                ),
        ]),
      ),
    );
  }
}
