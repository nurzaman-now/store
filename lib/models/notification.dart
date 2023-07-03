import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String? id;
  final String? idUser;
  final String? message;
  final String? titlePage;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Notifications({
    this.id,
    this.idUser,
    this.message,
    this.titlePage,
    this.createdAt,
    this.updatedAt,
  });

  factory Notifications.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Notifications(
      id: snapshot.id,
      idUser: data?['id_user'] ?? '',
      message: data?['pesan'] ?? '',
      titlePage: data?['title_page'] ?? '',
      createdAt: data?['created_at'] ?? Timestamp(0, 0),
      updatedAt: data?['updated_at'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    var data = {
      'id': id,
      'id_user': idUser,
      'pesan': message,
      'title_page': titlePage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
