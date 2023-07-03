import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String? idFavorite;
  final String? idUser;
  final String? idProduct;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Favorite({
    this.idFavorite,
    this.idUser,
    this.idProduct,
    this.createdAt,
    this.updatedAt,
  });

  factory Favorite.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Favorite(
      idFavorite: snapshot.id,
      idUser: data['id_user'],
      idProduct: data['id_product'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'id_favorite': idFavorite,
      'id_user': idUser,
      'id_product': idProduct,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
