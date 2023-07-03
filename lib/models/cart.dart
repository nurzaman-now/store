import 'package:cloud_firestore/cloud_firestore.dart';

class Cart {
  late String? idCart;
  late String? idUser;
  late String? idProduct;
  late String? size;
  late int? count;
  late Timestamp? createdAt;
  late Timestamp? updatedAt;

  Cart({
    this.idCart,
    this.idUser,
    this.idProduct,
    this.size,
    this.count,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Cart(
      idCart: snapshot.id,
      idUser: data?['id_user'] ?? '',
      idProduct: data?['id_product'] ?? '',
      size: data?['size'] ?? '',
      count: data?['count'] ?? 1,
      createdAt: data?['created_at'] ?? Timestamp(0, 0),
      updatedAt: data?['updated_at'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'id_cart': idCart,
      'id_user': idUser,
      'id_product': idProduct,
      'size': size,
      'count': count,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };

    data.removeWhere((key, value) => value == null);
    return data;
  }
}
