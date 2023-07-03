import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  String? id;
  String? userId;
  String? name;
  String? noTelp;
  String? provinsi;
  String? kabupaten;
  String? kecamatan;
  String? kelurahan;
  List<dynamic>? wilayah;
  String? kodePos;
  String? jln;
  String? detail;
  bool? main;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  Address({
    this.id,
    this.userId,
    this.name,
    this.noTelp,
    this.provinsi,
    this.kabupaten,
    this.kecamatan,
    this.kelurahan,
    this.kodePos,
    this.jln,
    this.detail,
    this.main,
    this.wilayah,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Address(
      id: snapshot.id,
      userId: data?['userId'],
      name: data?['name'],
      noTelp: data?['noTelp'],
      provinsi: data?['provinsi'],
      kabupaten: data?['kabupaten'],
      kecamatan: data?['kecamatan'],
      kelurahan: data?['kelurahan'],
      wilayah: data?['wilayah'],
      kodePos: data?['kodePos'],
      jln: data?['jln'],
      detail: data?['detail'],
      main: data?['main'],
      createdAt: data?['created_at'],
      updatedAt: data?['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'userId': userId,
      'name': name,
      'noTelp': noTelp,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'wilayah': wilayah,
      'kodePos': kodePos,
      'jln': jln,
      'detail': detail,
      'main': main,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
