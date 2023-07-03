import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:store/firebase_services/notification_services.dart';
import 'package:store/models/notification.dart';

class FCMService {
  final NotificationService _notificationService = NotificationService();

  Future<void> sendMessage(
      String deviceToken, Map<String, dynamic> messageData) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAaq-5WvM:APA91bGLx29C3w13GnqtcMilRZ90mAmt6T1Qzw2xx5DCbQTdm0-cJ5U6q8jViat1GM4F28n9zQ9BnFq2ggCiQfYFn8GrKscW-iWlVPbxws6sL8abzMCzBKl_8im_hwfvacImMBqzyJwb',
      // Replace with your FCM server key
    };

    final body = {
      'notification': {
        'body': messageData['body'],
        'title': messageData['title'],
      },
      'priority': 'high',
      'data': messageData,
      'to': deviceToken,
    };

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      Notifications notifications = Notifications(
          idUser: messageData['uid'],
          message: messageData['body'],
          titlePage: messageData['link'],
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now());
      await _notificationService.createNotification(notifications);
      if (kDebugMode) {
        print('Message sent successfully');
      }
    } else {
      if (kDebugMode) {
        print('Error sending message: ${response.body}');
      }
    }
  }
}
