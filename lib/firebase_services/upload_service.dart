import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  Future<String> pickUploadImage(String collection, String uid) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource
            .gallery); // Use ImageSource.camera for capturing from the camera

    if (pickedImage != null) {
      if (uid != 'new_product') {
        deleteImage(uid);
      }

      File imageFile = File(pickedImage.path);

      Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 100, // Adjust the quality as needed
      );

      String filePath = imageFile.path;
      File compressedFile = File(filePath);
      await compressedFile.writeAsBytes(compressedImage!.toList());
      // Create a reference to the Firebase Storage location
      firebase_storage.Reference storageReference =
      firebase_storage.FirebaseStorage.instance.ref().child('images/$uid');

      // Upload the image to Firebase Storage
      firebase_storage.UploadTask uploadTask =
      storageReference.putFile(compressedFile);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      if (uid != 'new_product') {
        updateImage(imageUrl, collection, uid);
      }
      // Print the download URL or use it as needed
      if (kDebugMode) {
        print('Uploaded image URL: $imageUrl');
      }
      return imageUrl;
    } else {
      // No image was picked
      if (kDebugMode) {
        print('No image selected');
      }
      return '';
    }
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      return imageFile;
    } else {
      return null;
    }
  }

  Future<String> uploadImage(File? file, String uid) async {
    firebase_storage.Reference storageReference =
    firebase_storage.FirebaseStorage.instance.ref().child('images/$uid');

    // Upload the image to Firebase Storage
    firebase_storage.UploadTask uploadTask =
    storageReference.putFile(file!);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL of the uploaded image
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> updateImage(String urlImage, String collection,
      String uid) async {
    try {
      FirebaseFirestore.instance.collection(collection).doc(uid).update({
        'image': urlImage,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating display name: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteImage(String uid) async {
    try {
      firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref().child('images/$uid');

      await storageRef.delete();

      if (kDebugMode) {
        print('Image deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
    }
  }
}
