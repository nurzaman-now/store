// To parse this JSON data, do
//
//     final provinsi = provinsiFromJson(jsonString);

import 'dart:convert';

List<Provinsi> provinsiFromJson(String str) =>
    List<Provinsi>.from(json.decode(str).map((x) => Provinsi.fromJson(x)));

String provinsiToJson(List<Provinsi> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<Provinsi> parseProvinsi(String? json) {
  if (json == null) {
    return [];
  }

  final List parsed = jsonDecode(json);
  return parsed.map((json) => Provinsi.fromJson(json)).toList();
}

class Provinsi {
  String id;
  String name;

  Provinsi({
    required this.id,
    required this.name,
  });

  factory Provinsi.fromJson(Map<String, dynamic> json) => Provinsi(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
