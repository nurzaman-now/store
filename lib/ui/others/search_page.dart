// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:store/common/styles.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../common/money_format_id.dart';
import '../../../firebase_services/shoes_services.dart';
import '../../../models/shoes.dart';
import '../user/menus/sub_menu/product_page.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text.dart';

class SearchPage extends StatefulWidget {
  static const routeName = '/search_page';
  static const String title = 'Pencarian';
  late String query;

  SearchPage(this.query, {super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ShoesService _shoesService = ShoesService();
  late List<Shoes> shoeses = [];
  late bool loading = true;
  TextEditingController search = TextEditingController();

  void fetchData() async {
    shoeses = await _shoesService.getShoesByName(search.text);
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    search.text = widget.query;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        Navigator.pop(context);
        // Return false to prevent the default back button behavior
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: CustomAppbar(
            titleActions: SearchPage.title,
            isBottom: true,
            bottomItem: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 28, right: 28),
                padding: const EdgeInsets.only(left: 10),
                width: MediaQuery.of(context).size.width * 0.6,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: thirdColor, width: 1),
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                    controller: search,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      hintText: 'Cari',
                      icon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 10),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (String value) {
                      widget.query = value;
                      fetchData();
                      setState(() {});
                    }),
              ),
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
            child: ListView(children: [
              const SizedBox(
                height: 9,
              ),
              shoeses.isEmpty
                  ? const Center(
                      child: CustomText(
                        text: 'produk yang anda cari tidak ditemukan',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  : GridView.builder(
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
            ]),
          ),
        ),
      ),
    );
  }
}
