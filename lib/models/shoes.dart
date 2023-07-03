// To parse this JSON data, do
//
//     final shoes = shoesFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';

class Shoes {
  final String? idShoes;
  final String? name;
  final Map<String, int>? sizes;
  final int? price;
  final double? discount;
  final String? image;
  final int? sold;
  final String? description;
  final String? idKategori;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Shoes({
    this.idShoes,
    this.name,
    this.sizes,
    this.price,
    this.discount,
    this.image,
    this.sold,
    this.description,
    this.idKategori,
    this.createdAt,
    this.updatedAt,
  });

  factory Shoes.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Shoes(
      idShoes: snapshot.id,
      name: data?['name'] ?? '',
      sizes: Map<String, int>.from(data?['sizes'] ?? []),
      price: data?['price'] ?? 0,
      discount: data?['discount'] ?? 0.0,
      image: data?['image'] ?? '',
      sold: data?['sold'] ?? 0,
      description: data?['description'] ?? '',
      idKategori: data?['id_kategori'] ?? '',
      createdAt: data?['created_at'] ?? Timestamp(0, 0),
      updatedAt: data?['updated_at'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'name': name,
      'sizes': sizes,
      'price': price,
      'discount': discount,
      'image': image,
      'sold': sold,
      'description': description,
      'id_kategori': idKategori,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
