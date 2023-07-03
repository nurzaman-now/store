import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:store/firebase_services/shoes_services.dart';
import 'package:store/models/shoes.dart';

import '../models/categories.dart';

class CategoryService {
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');
  final ShoesService _shoesServices = ShoesService();

  Future<List<Categories>> getAllCategory() async {
    try {
      QuerySnapshot snapshot = await categoryCollection.get();
      List<Categories> categoryList = [];
      if (snapshot.size > 0) {
        // Get the first document from the QuerySnapshot
        for (var element in snapshot.docs) {
          QueryDocumentSnapshot<Object?> queryDocumentSnapshot = element;

          // Cast the QueryDocumentSnapshot to DocumentSnapshot<Map<String, dynamic>>
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              queryDocumentSnapshot as DocumentSnapshot<Map<String, dynamic>>;

          // Process the data as needed
          Categories categories = Categories.fromSnapshot(documentSnapshot);
          categoryList.add(categories);
        }
      }
      return categoryList;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting Category: $error');
      }
      rethrow;
    }
  }

  Future<Categories> getCategoryById(String idCategory) async {
    try {
      DocumentSnapshot snapshot =
          await categoryCollection.doc(idCategory).get();
      var data = snapshot as DocumentSnapshot<Map<String, dynamic>>;

      if (snapshot.exists) {
        return Categories.fromSnapshot(data);
      } else {
        throw Exception('Category not found');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error getting Category: $error');
      }
      rethrow;
    }
  }

  Future<void> addCategory(Categories category) async {
    try {
      await categoryCollection.doc(category.idKategori).set(category.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error adding Category: $error');
      }
      rethrow;
    }
  }

  Future<void> updateCategory(Categories category) async {
    try {
      await categoryCollection
          .doc(category.idKategori)
          .update(category.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error updating Category: $error');
      }
      rethrow;
    }
  }

  Future<bool> deleteCategory(String idCategory) async {
    try {
      List<Shoes>? shoes =
          await _shoesServices.getShoesByCategoryId(idCategory);
      if (shoes.isEmpty) {
        await categoryCollection.doc(idCategory).delete();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting Category: $error');
      }
      return false;
    }
  }
}
