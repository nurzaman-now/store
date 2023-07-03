import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/notification.dart';

class NotificationService {
  final CollectionReference<Map<String, dynamic>> notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> createNotification(Notifications notifications) async {
    try {
      await notificationCollection.add(notifications.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error creating notification: $error');
      }
      rethrow;
    }
  }

  Future<void> updateNotification(Notifications notifications) async {
    try {
      await notificationCollection
          .doc(notifications.id)
          .update(notifications.toMap());
    } catch (error) {
      if (kDebugMode) {
        print('Error updating notification: $error');
      }
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationCollection.doc(notificationId).delete();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting notification: $error');
      }
      rethrow;
    }
  }

  Future<List<Notifications>> getNotificationsByUserId(String userId) async {
    try {
      List<Notifications> listNotify = [];
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await notificationCollection
              .where('id_user', isEqualTo: userId)
              .get();
      if (querySnapshot.size > 0) {
        for (var element in querySnapshot.docs) {
          Notifications notifications = Notifications.fromSnapshot(element);
          listNotify.add(notifications);
        }
      }
      return listNotify;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting notifications: $error');
      }
      rethrow;
    }
  }

  Future<void> deleteNotificationsByUserId(String userId) async {
    try {
      final notificationsSnapshot = await notificationCollection
          .where('id_user', isEqualTo: userId)
          .get();

      for (final notificationDoc in notificationsSnapshot.docs) {
        await notificationDoc.reference.delete();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting notifications: $error');
      }
      rethrow;
    }
  }
}
