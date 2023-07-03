import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store/models/address.dart';
import 'package:store/models/shoes.dart';

import 'courier.dart';

class Orderr {
  final String? idOrder;
  final int? noOrder;
  final String? idUser;
  final String? idAddress;
  final List? size;
  final List? count;
  final String? pesan;
  final double? total;
  final String? courier;
  final String? resi;
  final int? status;
  final int? ongkir;
  final List<String>? cancel;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final List<Shoes?>? shoes;
  final List<Map<String, dynamic>?>? product;
  Address? address;
  final String? orderAddress;
  Courier? courierApi;

  Orderr({
    this.idOrder,
    this.noOrder,
    this.idUser,
    this.shoes,
    this.product,
    this.idAddress,
    this.size,
    this.count,
    this.pesan,
    this.total,
    this.courier,
    this.resi,
    this.status,
    this.ongkir,
    this.cancel,
    this.address,
    this.orderAddress,
    this.courierApi,
    this.createdAt,
    this.updatedAt,
  });

  factory Orderr.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Orderr(
      idOrder: snapshot.id,
      idUser: data?['id_user'] ?? '',
      noOrder: data?['no_order'] ?? 0,
      product: List<Map<String, dynamic>>.from(data?['product'] ?? []),
      size: data?['size'] ?? [],
      count: data?['count'] ?? 0,
      pesan: data?['pesan'] ?? '',
      total: data?['total'] ?? 0.0,
      courier: data?['courier'] ?? '',
      resi: data?['resi'] ?? '',
      status: data?['status'] ?? 0,
      ongkir: data?['ongkir'] ?? 0,
      orderAddress: data?['address'] ?? '',
      cancel: List<String>.from(data?['cancel'] ?? []),
      createdAt: data?['created_at'] ?? Timestamp(0, 0),
      updatedAt: data?['updated_at'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'id_user': idUser,
      'no_order': noOrder,
      'id_order': idOrder,
      'product': shoes,
      'size': size,
      'count': count,
      'pesan': pesan,
      'total': total,
      'courier': courier,
      'resi': resi,
      'status': status,
      'ongkir': ongkir,
      'cancel': cancel,
      'address': orderAddress,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    if (shoes != null) {
      data['product'] = shoes!
          .map((shoe) => {
                'id_shoes': shoe!.idShoes,
                'name': shoe.name,
                'sizes': shoe.sizes,
                'price': shoe.price,
                'discount': shoe.discount,
                'image': shoe.image,
                'sold': shoe.sold,
                'description': shoe.description,
                'id_kategori': shoe.idKategori,
                'created_at': shoe.createdAt,
                'updated_at': shoe.updatedAt
              })
          .toList();
    }
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
