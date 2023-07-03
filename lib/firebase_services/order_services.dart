import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:store/models/order.dart';

class OrderService {
  final CollectionReference<Map<String, dynamic>> ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Future<List<Orderr>> getAllOrders() async {
    try {
      List<Orderr> orders = [];
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await ordersCollection.orderBy('created_at', descending: true).get();
      if (snapshot.size > 0) {
        for (var element in snapshot.docs) {
          Orderr order = Orderr.fromSnapshot(element);
          orders.add(order);
        }
      }
      return orders;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting orders: $error');
      }
      rethrow;
    }
  }

  Future<Orderr> getOrderById(String idOrder) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await ordersCollection.doc(idOrder).get();
      if (snapshot.exists) {
        Orderr order = Orderr.fromSnapshot(snapshot);

        return order;
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

  Future<List<Orderr>> getOrdersByIdUser(String idUser) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await ordersCollection.where('id_user', isEqualTo: idUser).get();
      List<Orderr> orders = [];

      for (var doc in snapshot.docs) {
        Orderr order = Orderr.fromSnapshot(doc);
        orders.add(order);
      }

      return orders;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting orders by status: $error');
      }
      rethrow;
    }
  }

  Future<bool> addOrder(Orderr order) async {
    try {
      await ordersCollection.add(order.toMap());
      return true;
    } catch (error) {
      if (kDebugMode) {
        print('Error adding order: $error');
      }
      return false;
    }
  }

  Future<void> updateOrder(Orderr order) async {
    try {
      await ordersCollection.doc(order.idOrder).update(order.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error updating order: $error');
      }
      rethrow;
    }
  }

  Future<void> deleteOrder(String idOrder) async {
    try {
      await ordersCollection.doc(idOrder).delete();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting order: $error');
      }
      rethrow;
    }
  }
}
