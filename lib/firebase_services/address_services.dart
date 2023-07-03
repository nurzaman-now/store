import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/address.dart';

class AddressServices {
  final CollectionReference<Map<String, dynamic>> addressCollection =
      FirebaseFirestore.instance.collection('addresses');

  Future<void> createAddress(Address address) async {
    try {
      await addressCollection.add(address.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error creating address: $e');
      }
      rethrow;
    }
  }

  Future<Address> getAddressById(String idOrder) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await addressCollection.doc(idOrder).get();
      if (snapshot.exists) {
        return Address.fromSnapshot(snapshot);
      } else {
        throw Exception('Order not found');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error getting order: $error');
      }
      rethrow;
    }
  }

  Future<List<Address>> getAddressesByUserId(String userId) async {
    try {
      List<Address> addresses = [];
      QuerySnapshot querySnapshot =
          await addressCollection.where('userId', isEqualTo: userId).get();

      for (DocumentSnapshot doc in querySnapshot.docs) {
        final data = doc as DocumentSnapshot<Map<String, dynamic>>;

        Address address = Address.fromSnapshot(data);

        addresses.add(address);
      }
      //jika address tinggal 1 maka dijadikan utama
      if (addresses.length == 1) {
        Address address = Address(
          id: addresses[0].id,
          main: true,
          updatedAt: Timestamp.now(),
        );
        await updateAddress(address);
      }
      return addresses;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting addresses: $e');
      }
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      await addressCollection.doc(address.id).update(address.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating address: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await addressCollection.doc(addressId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting address: $e');
      }
      rethrow;
    }
  }

  Future<Address?> getAddressesByUtama(String userId) async {
    try {
      Address? address;
      QuerySnapshot querySnapshot = await addressCollection
          .where('userId', isEqualTo: userId)
          .where('main', isEqualTo: true)
          .get();

      for (DocumentSnapshot doc in querySnapshot.docs) {
        final data = doc as DocumentSnapshot<Map<String, dynamic>>;

        address = Address.fromSnapshot(data);
      }

      return address;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting addresses: $e');
      }
      rethrow;
    }
  }

  Future<bool> utamaAddress(Address address) async {
    try {
      QuerySnapshot data = await addressCollection.get();
      for (DocumentSnapshot doc in data.docs) {
        await doc.reference.update({
          'main': false,
        });
      }
      await addressCollection.doc(address.id).update(address.toMap());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting address: $e');
      }
      return false;
    }
  }
}
