import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/cart.dart';

class CartService {
  final CollectionReference _cartsCollection =
      FirebaseFirestore.instance.collection('carts');

  Future<void> createCart(Cart cart) async {
    try {
      await _cartsCollection.add(cart.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error adding shoe: $error');
      }
      rethrow;
    }
  }

  static Future<Cart?> getCartById(String cartId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('carts').doc(cartId).get();

    if (snapshot.exists) {
      return Cart.fromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Future<List<Cart>> getCartByUserId(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('carts')
        .where('id_user', isEqualTo: userId)
        .get();

    final cartList =
        querySnapshot.docs.map((doc) => Cart.fromSnapshot(doc)).toList();

    return cartList;
  }

  Future<List<Cart>> getCartByUserIdProductId(
      String userId, String productId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('carts')
        .where('id_user', isEqualTo: userId)
        .where('id_product', isEqualTo: productId)
        .get();

    final cartList =
        querySnapshot.docs.map((doc) => Cart.fromSnapshot(doc)).toList();

    return cartList;
  }

  Future<void> updateCart(Cart cart) async {
    await _cartsCollection.doc(cart.idCart).update(cart.toMap());
  }

  Future<void> deleteCart(String idCart) async {
    await _cartsCollection.doc(idCart).delete();
  }

  Future<void> deleteCartMultiple(List idCart) async {
    for (var element in idCart) {
      await _cartsCollection.doc(element).delete();
    }
  }
}
