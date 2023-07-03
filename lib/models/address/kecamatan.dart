// To parse this JSON data, do
//
//     final kecamatan = kecamatanFromJson(jsonString);

import 'dart:convert';

List<Kecamatan> kecamatanFromJson(String str) =>
    List<Kecamatan>.from(json.decode(str).map((x) => Kecamatan.fromJson(x)));

String kecamatanToJson(List<Kecamatan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Kecamatan {
  String id;
  String regencyId;
  String name;

  Kecamatan({
    required this.id,
    required this.regencyId,
    required this.name,
  });

  factory Kecamatan.fromJson(Map<String, dynamic> json) => Kecamatan(
        id: json["id"],
        regencyId: json["regency_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "regency_id": regencyId,
        "name": name,
      };
}
