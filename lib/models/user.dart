import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? id;
  String? name;
  String? phoneNumber;
  String? gender;
  Timestamp? birthDate;
  String? email;
  String? password;
  String? image;
  String? token;
  String? role;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  Users({
    this.id,
    this.name,
    this.phoneNumber,
    this.gender,
    this.birthDate,
    this.email,
    this.password,
    this.image,
    this.token,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  // Create a User object from a Firestore snapshot
  factory Users.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return Users(
      id: snapshot.id,
      name: data['name'] ?? '',
      phoneNumber: data['noTelp'] ?? '',
      gender: data['jk'] ?? '',
      birthDate: data['ttl'] ?? Timestamp(0, 0),
      email: data['email'] ?? '',
      image: data['image'] ?? '',
      token: data['token'] ?? '',
      role: data['role'] ?? '',
      createdAt: data['created_at'] ?? Timestamp(0, 0),
      updatedAt: data['updated_at'] ?? Timestamp(0, 0),
    );
  }

  // Convert a User object to a map
  Map<String, dynamic> toMap() {
    var data = {
      'name': name,
      'noTelp': phoneNumber,
      'jk': gender,
      'ttl': birthDate,
      'email': email,
      'image': image,
      'token': token,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
