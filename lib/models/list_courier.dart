// To parse this JSON data, do
//
//     final listCourier = listCourierFromJson(jsonString);

import 'dart:convert';

List<ListCourier> listCourierFromJson(String str) => List<ListCourier>.from(
    json.decode(str).map((x) => ListCourier.fromJson(x)));

String listCourierToJson(List<ListCourier> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListCourier {
  String code;
  String description;

  ListCourier({
    required this.code,
    required this.description,
  });

  factory ListCourier.fromJson(Map<String, dynamic> json) => ListCourier(
        code: json["code"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "description": description,
      };
}
