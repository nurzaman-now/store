import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:store/common/money_format_id.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/category_services.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/models/categories.dart';
import 'package:store/models/shoes.dart';
import 'package:store/ui/user/menus/sub_menu/product_page.dart';
import 'package:store/ui/widgets/custom_button.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../widgets/custom_text.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = '/dashboard_page';
  static const String title = 'Roomstock';

  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ShoesService _shoesService = ShoesService();
  final CategoryService _kategoriService = CategoryService();

  int _currentIndex = 0;
  int _categoryIndex = 0;
  late List<Shoes> shoeses = [];
  late List<Shoes> shoesesTop = [];
  late List<Categories> categories = [];
  late List listKategori = [];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void _scrollToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
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
          setState(() {
            _currentIndex = 0;
          });
          return Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.7,
            child: CarouselSlider(
                options: CarouselOptions(
                  height: 1000.0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                  aspectRatio: 2.0,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    _scrollToIndex(index);
                  },
                ),
                items: shoesesTop.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    // final value = entry.value;
                    return Builder(builder: (context) {
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, ProductPage.routeName,
                            arguments: shoesesTop[index].idShoes),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.only(
                              left: 19, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const CustomText(
                                            text: 'Terlaris',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 6),
                                          CustomText(
                                            text: shoesesTop[index].name!,
                                            style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      TextButtonTheme(
                                        data: CustomButtonStyle(
                                            color: primaryColor),
                                        child: TextButton(
                                            onPressed: () =>
                                                Navigator.pushNamed(context,
                                                    ProductPage.routeName,
                                                    arguments: shoesesTop[index]
                                                        .idShoes),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CustomText(
                                                text: 'Beli Sekarang',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: FadeInImage(
                                      placeholder: const AssetImage(
                                        'assets/logo/loading_icon.gif',
                                      ),
                                      image: NetworkImage(
                                          shoesesTop[index].image ?? ''),
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      );
                    });
                  },
                ).toList()),
          ),
          const SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                shoesesTop.length,
                (index) => _currentIndex == index
                    ? const Icon(
                        Icons.fiber_manual_record,
                        size: 12,
                      )
                    : const Icon(
                        Icons.fiber_manual_record,
                        size: 12,
                        color: secondaryColor,
                      ),
              )),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                context, ProductPage.routeName,
                                arguments: shoeses[index].idShoes),
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
