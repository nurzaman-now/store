// To parse this JSON data, do
//
//     final courier = courierFromJson(jsonString);

import 'dart:convert';

Courier courierFromJson(String str) => Courier.fromJson(json.decode(str));

String courierToJson(Courier data) => json.encode(data.toJson());

class Courier {
  int status;
  String message;
  Data data;

  Courier({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Summary summary;
  Detail detail;
  List<History> history;

  Data({
    required this.summary,
    required this.detail,
    required this.history,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        summary: Summary.fromJson(json["summary"]),
        detail: Detail.fromJson(json["detail"]),
        history:
            List<History>.from(json["history"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "summary": summary.toJson(),
        "detail": detail.toJson(),
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
      };
}

class Detail {
  String origin;
  String destination;
  String shipper;
  String receiver;

  Detail({
    required this.origin,
    required this.destination,
    required this.shipper,
    required this.receiver,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        origin: json["origin"],
        destination: json["destination"],
        shipper: json["shipper"],
        receiver: json["receiver"],
      );

  Map<String, dynamic> toJson() => {
        "origin": origin,
        "destination": destination,
        "shipper": shipper,
        "receiver": receiver,
      };
}

class History {
  DateTime date;
  String desc;
  String location;

  History({
    required this.date,
    required this.desc,
    required this.location,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        date: DateTime.parse(json["date"]),
        desc: json["desc"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "desc": desc,
        "location": location,
      };
}

class Summary {
  String awb;
  String courier;
  String service;
  String status;
  DateTime date;
  String desc;
  String amount;
  String weight;

  Summary({
    required this.awb,
    required this.courier,
    required this.service,
    required this.status,
    required this.date,
    required this.desc,
    required this.amount,
    required this.weight,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        awb: json["awb"],
        courier: json["courier"],
        service: json["service"],
        status: json["status"],
        date: DateTime.parse(json["date"]),
        desc: json["desc"],
        amount: json["amount"],
        weight: json["weight"],
      );

  Map<String, dynamic> toJson() => {
        "awb": awb,
        "courier": courier,
        "service": service,
        "status": status,
        "date": date.toIso8601String(),
        "desc": desc,
        "amount": amount,
        "weight": weight,
      };
}
