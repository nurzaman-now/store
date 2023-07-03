// To parse this JSON data, do
//
//     final kabupaten = kabupatenFromJson(jsonString);

import 'dart:convert';

List<Kabupaten> kabupatenFromJson(String str) =>
    List<Kabupaten>.from(json.decode(str).map((x) => Kabupaten.fromJson(x)));

String kabupatenToJson(List<Kabupaten> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Kabupaten {
  String id;
  String provinceId;
  String name;

  Kabupaten({
    required this.id,
    required this.provinceId,
    required this.name,
  });

  factory Kabupaten.fromJson(Map<String, dynamic> json) => Kabupaten(
        id: json["id"],
        provinceId: json["province_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "province_id": provinceId,
        "name": name,
      };
}
