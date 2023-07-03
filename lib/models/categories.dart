// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';

class Categories {
  final String? idKategori;
  final String? name;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Categories({
    this.idKategori,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Categories.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Categories(
      idKategori: snapshot.id,
      name: data?['name'] ?? '',
      createdAt: data?['created_at'] ?? Timestamp(0, 0),
      updatedAt: data?['updated_at'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'id_kategori': idKategori,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    data.removeWhere((key, value) => value == null);

    return data;
  }
}
