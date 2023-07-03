// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/firebase_services/category_services.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/firebase_services/upload_service.dart';
import 'package:store/ui/popup/add_category.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../../common/styles.dart';
import '../../../../models/categories.dart';
import '../../../../models/shoes.dart';
import '../../../popup/confirmation.dart';
import '../../../popup/dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text.dart';
import '../dashboard_page.dart';

class ManageProductPage extends StatefulWidget {
  static const routeName = '/admin/manage_product_page';
  static const String title = 'Pengelolaan Produk';
  String idShoes = '';

  ManageProductPage(this.idShoes, {Key? key}) : super(key: key);

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final UploadService _uploadService = UploadService();
  final ShoesService _shoesService = ShoesService();
  final CategoryService _categoryService = CategoryService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List sizeControllers = [TextEditingController()];
  List stockControllers = [TextEditingController()];

  late bool loading = true;
  late List<Categories> categories;
  late Shoes? shoes1;
  late String categorySelected = '';
  late String imageUrl = '';
  late File? image;
  late bool isEnable = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    categories = await _categoryService.getAllCategory();

    if (widget.idShoes != '') {
      sizeControllers = [TextEditingController()];
      stockControllers = [TextEditingController()];

      shoes1 = await _shoesService.getOneShoe(widget.idShoes);
      imageUrl = shoes1!.image!;
      categorySelected = shoes1!.idKategori!;
      nameController.text = shoes1!.name!;
      priceController.text = shoes1!.price!.toString();
      discountController.text = (shoes1!.discount! * 100).toString();
      int index = 0;

      final shoesSizes = shoes1!.sizes!;
      final sortedSizes = Map<String, int>.fromEntries(
          shoesSizes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      sortedSizes.forEach((key, value) {
        if (index > 0) {
          sizeControllers.add(TextEditingController());
          stockControllers.add(TextEditingController());
        }
        sizeControllers[index].text = key.toString();
        stockControllers[index].text = value.toString();
        index++;
      });
      descriptionController.text = shoes1!.description!;
    } else {
      categorySelected = categories[0].idKategori!;
    }
    setState(() {
      loading = false;
    });
  }

  // check button enable
  void _checkButtonStatus() {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        discountController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        imageUrl != '') {
      late int index = 0;
      for (var element in sizeControllers) {
        if (element.text.isNotEmpty &&
            stockControllers[index].text.isNotEmpty) {
          isEnable = true;
        }
        index++;
      }
    } else {
      isEnable = false;
    }
    setState(() {});
  }

  void pickImage() async {
    setState(() {
      loading = true;
    });
    image = await _uploadService.pickImage();

    if (image != null) {
      imageUrl = image!.path;
    }
    _checkButtonStatus();
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() async {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    descriptionController.dispose();
    for (var element in sizeControllers) {
      element.dispose();
    }
    for (var element in stockControllers) {
      element.dispose();
    }
    super.dispose();
  }

  void addProduct() async {
    setState(() {
      loading = true;
    });
    Map<String, int> sizes = {};
    late int index = 0;
    for (var element in sizeControllers) {
      sizes[element.text] = int.parse(stockControllers[index].text);
      index++;
    }
    Shoes shoes = Shoes(
      idKategori: categorySelected,
      name: nameController.text,
      price: int.parse(priceController.text),
      discount: double.parse(discountController.text) / 100,
      description: descriptionController.text,
      sizes: sizes,
      sold: 0,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    try {
      String shoe = await _shoesService.addShoe(shoes);
      imageUrl = await _uploadService.uploadImage(image, shoe);
      await _shoesService.updateShoes(Shoes(idShoes: shoe, image: imageUrl));
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const MyDialog(
                message: 'BERHASIL MENAMBAHKAN PRODUK',
                image: 'assets/logo/success.png',
                createPage: AdminDashboardPage.routeName,
                arguments: '',
                isRedirect: true,
                isGo: false,
              ));
    } catch (e) {
      setState(() {
        loading = false;
      });
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const MyDialog(
                message: 'GAGAL MENAMBAHKAN PRODUK',
                textColor: Colors.red,
                image: 'assets/logo/fail.png',
                createPage: AdminDashboardPage.routeName,
                arguments: '',
                isBack: false,
                isGo: false,
              ));
    }
  }

  void updateProduct() async {
    setState(() {
      loading = true;
    });
    Map<String, int> sizes = {};
    late int index = 0;
    for (var element in sizeControllers) {
      sizes[element.text] = int.parse(stockControllers[index].text);
      index++;
    }
    Shoes shoes = Shoes(
      idShoes: shoes1!.idShoes!,
      idKategori: categorySelected,
      name: nameController.text,
      price: int.parse(priceController.text),
      discount: double.parse(discountController.text) / 100,
      description: descriptionController.text,
      sizes: sizes,
      updatedAt: Timestamp.now(),
    );
    try {
      await _shoesService.updateShoes(shoes);
      if (imageUrl != shoes1!.image) {
        await _uploadService.deleteImage(shoes1!.idShoes!);
        imageUrl = await _uploadService.uploadImage(image, shoes1!.idShoes!);
        await _shoesService
            .updateShoes(Shoes(idShoes: shoes1!.idShoes!, image: imageUrl));
      }
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const MyDialog(
                message: 'BERHASIL DIPERBARUI',
                image: 'assets/logo/success.png',
                createPage: AdminDashboardPage.routeName,
                arguments: '',
                isRedirect: true,
                isGo: false,
              ));
    } catch (e) {
      setState(() {
        loading = false;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const MyDialog(
                message: 'GAGAL DIPERBARUI',
                textColor: Colors.red,
                image: 'assets/logo/fail.png',
                createPage: AdminDashboardPage.routeName,
                arguments: '',
                isBack: false,
                isGo: false,
              ));
    }
  }

  void deleteProduct(bool? conf) async {
    setState(() {
      loading = true;
    });
    if (conf!) {
      try {
        String idShoes = shoes1!.idShoes!;
        await _shoesService.deleteShoe(idShoes);
        await _uploadService.deleteImage(idShoes);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => const MyDialog(
                  message: 'BERHASIL MENGHAPUS PRODUK',
                  image: 'assets/logo/success.png',
                  createPage: AdminDashboardPage.routeName,
                  arguments: '',
                  isRedirect: true,
                  isGo: false,
                ));
      } catch (e) {
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => const MyDialog(
                  message: 'GAGAL MENGHAPUS PRODUK',
                  textColor: Colors.red,
                  image: 'assets/logo/fail.png',
                  createPage: AdminDashboardPage.routeName,
                  arguments: '',
                  isBack: false,
                  isGo: false,
                ));
      }
    }
  }

  void handleRemoveCategory(bool? conf) async {
    if (conf!) {
      setState(() {
        loading = true;
      });
      _categoryService.deleteCategory(categorySelected).then((value) {
        if (value) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => const MyDialog(
                    message: 'BERHASIL MENGHAPUS KATEGORI',
                    createPage: ManageProductPage.routeName,
                    arguments: '',
                    isBack: false,
                    isGo: false,
                  ));
          fetchData();
        } else {
          setState(() {
            loading = false;
          });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => const MyDialog(
                    message:
                        'GAGAL MENGHAPUS KATEGORI / KATEGORI MASIH TERPAKAI',
                    textColor: Colors.red,
                    image: 'assets/logo/fail.png',
                    createPage: ManageProductPage.routeName,
                    arguments: '',
                    isBack: false,
                    isGo: false,
                  ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoading();
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const CustomAppbar(
          titleActions: ManageProductPage.title,
        ),
        body: widget.idShoes != ''
            ? RefreshIndicator(
                onRefresh: () {
                  loading = true;
                  fetchData();
                  setState(() {});
                  return Future.delayed(const Duration(seconds: 1));
                },
                child: buildListProduct(context),
              )
            : buildListProduct(context),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          child: Row(
            mainAxisAlignment: widget.idShoes != ''
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              TextButtonTheme(
                data: CustomButtonStyle(
                    color: isEnable ? primaryColor : secondaryColor,
                    horizontal: MediaQuery.of(context).size.width *
                        (widget.idShoes != '' ? 0.17 : 0.25),
                    vertical: 12),
                child: TextButton(
                    onPressed: () => isEnable
                        ? widget.idShoes == ''
                            ? addProduct()
                            : updateProduct()
                        : null,
                    child: CustomText(
                      text: widget.idShoes == ''
                          ? 'Tambahkan Produk'
                          : 'Perbarui Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEnable ? Colors.white : Colors.black,
                      ),
                    )),
              ),
              widget.idShoes != ''
                  ? Container(
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(18)),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Confirm(
                                  message: 'Apakah yakin ingin menghapusnya?',
                                  createPage: ManageProductPage.routeName,
                                  isBack: false,
                                  onConfirmation: deleteProduct,
                                )),
                      ),
                    )
                  : const Text('')
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListProduct(BuildContext context) {
    return ListView(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
              child: Center(
                child: imageUrl == ''
                    ? const FadeInImage(
                        placeholder: AssetImage('assets/logo/loading_icon.gif'),
                        image: AssetImage('assets/logo/loading.png'),
                      )
                    : widget.idShoes == ''
                        ? FadeInImage(
                            placeholder: const AssetImage(
                                'assets/logo/loading_icon.gif'),
                            image: FileImage(image!),
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            placeholder: const AssetImage(
                                'assets/logo/loading_icon.gif'),
                            image: NetworkImage(imageUrl),
                          ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 0,
              child: InkWell(
                onTap: () => pickImage(),
                child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(18)),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  margin: const EdgeInsets.only(left: 12, right: 6),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButtonFormField<String>(
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusColor: Colors.black,
                      hoverColor: primaryColor,
                    ),
                    value: categorySelected,
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category.idKategori,
                        child: Text(category.name!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categorySelected = value.toString();
                      });
                      _checkButtonStatus();
                    },
                  )),
              Container(
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(18)),
                  child: IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Confirm(
                              message: 'Apakah yakin ingin menghapusnya?',
                              createPage: ManageProductPage.routeName,
                              isBack: false,
                              onConfirmation: handleRemoveCategory,
                            )),
                    icon: const Icon(
                      Icons.remove_circle_outline_sharp,
                      color: Colors.white,
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(18)),
                  child: IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) => const AddCategory()),
                    icon: const Icon(
                      Icons.add_circle_outline_sharp,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
                color: secondaryColor, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              keyboardType: TextInputType.text,
              controller: nameController,
              cursorColor: primaryColor,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                  hintText: 'Nama produk',
                  border: InputBorder.none,
                  focusColor: Colors.black,
                  hoverColor: primaryColor),
              onChanged: (value) => _checkButtonStatus(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
                color: secondaryColor, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Stack(
              children: [
                const Positioned(
                  top: 15,
                  child: Text(
                    'Rp. ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: priceController,
                  cursorColor: primaryColor,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                      hintText: 'Harga produk',
                      border: InputBorder.none,
                      focusColor: Colors.black,
                      hoverColor: primaryColor,
                      fillColor: Colors.black,
                      iconColor: Colors.black,
                      prefix: Text(
                        'Rp. ',
                        style: TextStyle(
                          color: Colors.transparent,
                        ),
                      )),
                  onChanged: (value) => _checkButtonStatus(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
                color: secondaryColor, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.only(left: 10, right: 18),
            child: Stack(
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  controller: discountController,
                  cursorColor: primaryColor,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'diskon produk',
                    border: InputBorder.none,
                    focusColor: Colors.black,
                    hoverColor: primaryColor,
                  ),
                  onChanged: (value) => _checkButtonStatus(),
                ),
                const Positioned(
                  top: 15,
                  right: 0,
                  child: Text(
                    '%',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sizeControllers.length,
            itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            margin: const EdgeInsets.only(left: 12, right: 6),
                            decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.only(left: 10, right: 18),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: sizeControllers[index],
                              cursorColor: primaryColor,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Size',
                                border: InputBorder.none,
                                focusColor: Colors.black,
                                hoverColor: primaryColor,
                              ),
                              onChanged: (value) => _checkButtonStatus(),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            margin: const EdgeInsets.only(left: 6, right: 12),
                            decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.only(left: 10, right: 18),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: stockControllers[index],
                              cursorColor: primaryColor,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Stock',
                                border: InputBorder.none,
                                focusColor: Colors.black,
                                hoverColor: primaryColor,
                              ),
                              onChanged: (value) => _checkButtonStatus(),
                            ),
                          ),
                        ],
                      ),
                      index == 0
                          ? Row(
                              children: [
                                sizeControllers.length > 1
                                    ? Container(
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              sizeControllers.removeLast();
                                              stockControllers.removeLast();
                                              _checkButtonStatus();
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.remove_circle_outline_sharp,
                                            color: Colors.white,
                                          ),
                                        ))
                                    : const Text(''),
                                Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          sizeControllers
                                              .add(TextEditingController());
                                          stockControllers
                                              .add(TextEditingController());
                                          _checkButtonStatus();
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline_sharp,
                                        color: Colors.white,
                                      ),
                                    ))
                              ],
                            )
                          : const Text(''),
                    ],
                  ),
                )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
                color: secondaryColor, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.only(left: 10, right: 18),
            child: TextField(
              keyboardType: TextInputType.text,
              controller: descriptionController,
              cursorColor: primaryColor,
              maxLines: 4,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Deskripsi produk',
                border: InputBorder.none,
                focusColor: Colors.black,
                hoverColor: primaryColor,
              ),
              onChanged: (value) => _checkButtonStatus(),
            ),
          ),
        ),
      ],
    );
  }
}
