import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favorite.dart';

class FavoriteService {
  final CollectionReference<Map<String, dynamic>> favoriteCollection =
      FirebaseFirestore.instance.collection('favorites');

  Future<void> addFavorite(Favorite favorite) async {
    await favoriteCollection.doc(favorite.idFavorite).set(favorite.toMap());
  }

  Future<Favorite?> getFavorite(String idFavorite) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await favoriteCollection.doc(idFavorite).get();
    if (snapshot.exists) {
      return Favorite.fromSnapshot(snapshot);
    }
    return null;
  }

  Future<List<Favorite>> getFavoriteByUserId(String idUser) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await favoriteCollection.where('id_user', isEqualTo: idUser).get();
      List<Favorite> listFavorites = [];
      if (snapshot.size > 0) {
        for (var doc in snapshot.docs) {
          Favorite favorite = Favorite.fromSnapshot(doc);
          listFavorites.add(favorite);
        }
      }
      return listFavorites;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Favorite>> getFavoriteByProductInUser(
      String idUser, String idFav) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await favoriteCollection
              .where('id_user', isEqualTo: idUser)
              .where('id_product', isEqualTo: idFav)
              .get();
      List<Favorite> listFavorites = [];
      if (snapshot.size > 0) {
        for (var doc in snapshot.docs) {
          Favorite favorite = Favorite.fromSnapshot(doc);
          listFavorites.add(favorite);
        }
      }
      return listFavorites;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Favorite>> getAllFavorites() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await favoriteCollection.get();
    return snapshot.docs.map((doc) => Favorite.fromSnapshot(doc)).toList();
  }

  Future<void> updateFavorite(Favorite favorite) async {
    await favoriteCollection.doc(favorite.idFavorite).update(favorite.toMap());
  }

  Future<void> deleteFavorite(String idFavorite) async {
    await favoriteCollection.doc(idFavorite).delete();
  }
}
