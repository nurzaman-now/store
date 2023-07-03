// To parse this JSON data, do
//
//     final kelurahan = kelurahanFromJson(jsonString);

import 'dart:convert';

List<Kelurahan> kelurahanFromJson(String str) =>
    List<Kelurahan>.from(json.decode(str).map((x) => Kelurahan.fromJson(x)));

String kelurahanToJson(List<Kelurahan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Kelurahan {
  String id;
  String districtId;
  String name;

  Kelurahan({
    required this.id,
    required this.districtId,
    required this.name,
  });

  factory Kelurahan.fromJson(Map<String, dynamic> json) => Kelurahan(
        id: json["id"],
        districtId: json["district_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "district_id": districtId,
        "name": name,
      };
}
