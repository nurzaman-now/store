import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:store/firebase_services/user_services.dart';
import 'package:store/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserServices _userServices = UserServices();

  // Register a new user
  Future<String> register(Users users) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: users.email!,
        password: users.password!,
      );

      // Get the user reference from the userCredential
      User? user = userCredential.user;

      if (user != null) {
        users.id = user.uid;
        // Create a document for the user in Firestore
        await _userServices.createUser(users);
      }
      return 'BERHASIL DAFTAR';
    } catch (e) {
      if (kDebugMode) {
        print('Error registering user: $e');
      }
      return e.toString().replaceAll(RegExp(r'\[.*?\]'), "");
    }
  }

  // Log in with email and password
  Future<String> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'BERHASIL LOGIN';
    } catch (e) {
      if (kDebugMode) {
        print('Error logging in: $e');
      }
      return e.toString().replaceAll(RegExp(r'\[.*?\]'), "");
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference documentRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        DocumentSnapshot snapshot = await documentRef.get();

        if (snapshot.exists) {
          // Document exists, you can access its data here
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          data['uid'] = user.uid;
          return data;
        } else {
          if (kDebugMode) {
            print('Document does not exist');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting document: $e');
      }
    }
    return null;
  }

  // Update user's display name
  Future<void> updateUser(Users users) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (user.email != users.email) {
          await user.updateEmail(users.email!);
        }
        users.id = user.uid;
        await _userServices.updateUser(users);
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating display name: $e');
      }
      rethrow;
    }
  }

  // Reset user's password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: $e');
      }
      return false;
    }
  }

  Future<void> logout(bool delToken) async {
    try {
      if (delToken) {
        User? user = _auth.currentUser;
        await _userServices.updateUser(Users(id: user!.uid, token: 'noDevice'));
      }
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out: $e');
      }
      rethrow;
    }
  }
}
