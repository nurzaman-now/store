import 'package:flutter/material.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/firebase_services/notification_services.dart';
import 'package:store/ui/widgets/custom_appbar.dart';
import 'package:store/ui/widgets/custom_loading.dart';

import '../../../models/notification.dart';
import '../popup/confirmation.dart';
import '../widgets/custom_text.dart';

class NotificationPage extends StatefulWidget {
  static const routeName = '/notification_page';
  static const String title = 'Notifikasi';

  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  late List<Notifications> notifications = [];
  late bool loading = true;
  late bool isDeleteAll = true;
  late String notificationId = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var user = await _authService.getUser();
    notifications =
        await _notificationService.getNotificationsByUserId(user!['uid']);
    loading = false;
    setState(() {});
  }

  void deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      fetchData();
    } catch (e) {
      rethrow;
    }
  }

  void deleteAllNotification() async {
    try {
      setState(() {
        isDeleteAll = false;
      });
      await _notificationService
          .deleteNotificationsByUserId(notifications[0].idUser!);
      setState(() {
        isDeleteAll = true;
      });
      fetchData();
    } catch (e) {
      setState(() {
        isDeleteAll = true;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();
        // Return false to prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppbar(
          titleActions: NotificationPage.title,
        ),
        body: loading
            ? const CustomLoading()
            : Container(
                height: MediaQuery.of(context).size.height,
                color: secondaryColor,
                padding: const EdgeInsets.only(
                    top: 29, bottom: 29, left: 20, right: 20),
                alignment: Alignment.center,
                child: RefreshIndicator(
                  onRefresh: () {
                    fetchData();
                    return Future.delayed(const Duration(seconds: 1));
                  },
                  child: notifications.isEmpty
                      ? const Center(
                          child: CustomText(
                            text: 'Tidak Ada Notifikasi',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    'assets/logo/loading.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                title: CustomText(
                                  text: notifications[index].message!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () {
                                  if (notifications[index].titlePage != null) {
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                    Navigator.pushNamed(context,
                                        notifications[index].titlePage!,
                                        arguments: 0);
                                  }
                                },
                                onLongPress: () {
                                  notificationId = notifications[index].id!;
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => Confirm(
                                            message: 'Hapus Pesan?',
                                            createPage:
                                                NotificationPage.routeName,
                                            isBack: false,
                                            onConfirmation: handleConfirmation,
                                          ));
                                });
                          },
                        ),
                ),
              ),
        floatingActionButton: notifications.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => isDeleteAll
                    ? showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Confirm(
                              message: 'Hapus Semua Pesan?',
                              createPage: NotificationPage.routeName,
                              isBack: false,
                              onConfirmation: handleDeleteAllNotification,
                            ))
                    : null,
                label: const Text('Hapus Semua'),
                icon: const Icon(Icons.delete),
              )
            : null,
      ),
    );
  }

  void handleConfirmation(bool? conf) {
    if (conf!) {
      deleteNotification(notificationId);
    }
  }

  void handleDeleteAllNotification(bool? conf) {
    if (conf!) {
      deleteAllNotification();
    }
  }
}
