// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store/firebase_services/category_services.dart';
import 'package:store/models/categories.dart';
import 'package:store/ui/admin/menus/order_menus/manage_product_page.dart';

import '../../common/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import 'dialog.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({
    Key? key,
  }) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController nameController = TextEditingController();

  bool isEnable = false;

  void _checkButtonStatus() {
    if (nameController.text.isNotEmpty) {
      isEnable = true;
    } else {
      isEnable = false;
    }
    setState(() {});
  }

  void addCategory() async {
    try {
      Categories categories = Categories(
        name: nameController.text,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await _categoryService.addCategory(categories);
      showDialog(
          context: context,
          builder: (dialogContext) => const MyDialog(
                message: 'KATEGORI BERHASIL DITAMBAH',
                image: 'assets/logo/success.png',
                createPage: ManageProductPage.routeName,
                arguments: '',
                isGo: false,
              ));
    } catch (e) {
      showDialog(
          context: context,
          builder: (dialogContext) => const MyDialog(
                message: 'KATEGORI GAGAL DITAMBAH',
                textColor: Colors.red,
                image: 'assets/logo/fail.png',
                createPage: ManageProductPage.routeName,
                arguments: '',
                isBack: false,
                isGo: false,
              ));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context, isEnable),
      ),
    );
  }

  contentBox(context, enable) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(18)),
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
            TextButtonTheme(
              data: CustomButtonStyle(
                color: enable ? primaryColor : thirdColor,
                horizontal: MediaQuery.of(context).size.width * 0.1,
              ),
              child: TextButton(
                  onPressed: () => addCategory(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomText(
                      text: 'Tambah kategori',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: enable ? Colors.white : Colors.black,
                      ),
                    ),
                  )),
            ),
          ],
        ));
  }
}
