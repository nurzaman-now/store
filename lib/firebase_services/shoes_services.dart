import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/shoes.dart';

class ShoesService {
  final CollectionReference shoesCollection =
      FirebaseFirestore.instance.collection('products');

  Future<String> addShoe(Shoes shoes) async {
    try {
      var shoesRef = await shoesCollection.add(shoes.toMap());
      return shoesRef.id;
    } catch (error) {
      if (kDebugMode) {
        print('Error adding shoe: $error');
      }
      rethrow;
    }
  }

  Future<List<Shoes>> getAllShoes() async {
    try {
      QuerySnapshot snapshot = await shoesCollection.get();
      List<Shoes> shoes = snapshot.docs
          .map((doc) =>
              Shoes.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      return shoes;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting shoes: $error');
      }
      rethrow;
    }
  }

  Future<Shoes?> getOneShoe(String idShoes) async {
    try {
      DocumentSnapshot snapshot = await shoesCollection.doc(idShoes).get();
      if (snapshot.exists) {
        final data = snapshot as DocumentSnapshot<Map<String, dynamic>>;
        return Shoes.fromSnapshot(data);
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error getting shoe: $error');
      }
      rethrow;
    }
  }

  Future<List<Shoes>> getTopSoldShoes(int limit) async {
    try {
      QuerySnapshot snapshot = await shoesCollection
          .orderBy('sold', descending: true)
          .limit(limit)
          .get();

      List<Shoes> topSoldShoes = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        final data = doc as DocumentSnapshot<Map<String, dynamic>>;

        Shoes shoes = Shoes.fromSnapshot(data);

        topSoldShoes.add(shoes);
      }

      return topSoldShoes;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting top sold shoes: $error');
      }
      rethrow;
    }
  }

  Future<List<Shoes>> getShoesByCategoryId(String idKategori) async {
    try {
      QuerySnapshot snapshot = await shoesCollection
          .where('id_kategori', isEqualTo: idKategori)
          .get();

      List<Shoes> shoesList = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        final data = doc as DocumentSnapshot<Map<String, dynamic>>;

        Shoes shoes = Shoes.fromSnapshot(data);

        shoesList.add(shoes);
      }

      return shoesList;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting shoes by category: $error');
      }
      rethrow;
    }
  }

  Future<List<Shoes>> getShoesByName(String value) async {
    try {
      QuerySnapshot snapshot = await shoesCollection.orderBy('name').get();

      List<Shoes> shoesList = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        final data = doc as DocumentSnapshot<Map<String, dynamic>>;

        Shoes shoes = Shoes.fromSnapshot(data);

        var name = shoes.name?.toLowerCase();
        var valuee = value.toLowerCase();
        if (name!.contains(valuee)) {
          shoesList.add(shoes);
        }
      }

      return shoesList;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting shoes by category: $error');
      }
      rethrow;
    }
  }

  Future<void> updateShoes(Shoes shoes) async {
    try {
      await shoesCollection.doc(shoes.idShoes).update(shoes.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error updating shoe: $error');
      }
      rethrow;
    }
  }

  Future<void> deleteShoe(String idShoes) async {
    try {
      await shoesCollection.doc(idShoes).delete();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting shoe: $error');
      }
      rethrow;
    }
  }
}
