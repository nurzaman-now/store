import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';

class UserServices {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<List<Users>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _usersCollection.get();
      List<Users> users =
          snapshot.docs.map((doc) => Users.fromSnapshot(doc)).toList();
      return users;
    } catch (error) {
      throw Exception('Failed to fetch users: $error');
    }
  }

  Future<Users> getUserById(String id) async {
    try {
      DocumentSnapshot snapshot = await _usersCollection.doc(id).get();
      if (snapshot.exists) {
        Users user = Users.fromSnapshot(snapshot);
        return user;
      } else {
        throw Exception('User not found');
      }
    } catch (error) {
      throw Exception('Failed to fetch user: $error');
    }
  }

  Future<List<Users>> getUsersByRole(String role) async {
    try {
      QuerySnapshot snapshot =
          await _usersCollection.where('role', isEqualTo: role).get();
      List<Users> users = [];
      for (var doc in snapshot.docs) {
        Users user = Users.fromSnapshot(doc);
        users.add(user);
      }
      return users;
    } catch (error) {
      throw Exception('Failed to fetch users by role: $error');
    }
  }

  Future<void> createUser(Users user) async {
    try {
      String id = user.id!;
      user.id = null;
      await _usersCollection.doc(id).set(user.toMap());
      if (kDebugMode) {
        print('User created successfully!');
      }
    } catch (error) {
      throw Exception('Failed to create user: $error');
    }
  }

  Future<void> updateUser(Users user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
      if (kDebugMode) {
        print('User updated successfully!');
      }
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }

  Future<void> deleteUser(Users user) async {
    try {
      await _usersCollection.doc(user.id).delete();
      if (kDebugMode) {
        print('User deleted successfully!');
      }
    } catch (error) {
      throw Exception('Failed to delete user: $error');
    }
  }
}
