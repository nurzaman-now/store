import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:store/firebase_services/auth_services.dart';
import 'package:store/ui/admin/index_page.dart';
import 'package:store/ui/admin/menus/order_menus/manage_product_page.dart';
import 'package:store/ui/forgot_pass_page.dart';
import 'package:store/ui/home_page.dart';
import 'package:store/ui/login_page.dart';
import 'package:store/ui/others/notification_page.dart';
import 'package:store/ui/others/search_page.dart';
import 'package:store/ui/register_page.dart';
import 'package:store/ui/splash_screen.dart';
import 'package:store/ui/user/index_page.dart';
import 'package:store/ui/user/menus/setting_menus/address_page.dart';
import 'package:store/ui/user/menus/setting_menus/order_page.dart';
import 'package:store/ui/user/menus/setting_menus/profile_page.dart';
import 'package:store/ui/user/menus/sub_menu/add_address_page.dart';
import 'package:store/ui/user/menus/sub_menu/cancel_order_page.dart';
import 'package:store/ui/user/menus/sub_menu/detail_order_page.dart';
import 'package:store/ui/user/menus/sub_menu/history_order_page.dart';
import 'package:store/ui/user/menus/sub_menu/product_page.dart';
import 'package:store/ui/user/menus/sub_menu/status_order_page.dart';

import 'common/styles.dart';
import 'ui/admin/menus/order_menus/detail_order_page.dart';
import 'ui/admin/menus/order_menus/update_order_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver firebaseAnalyticsObserver =
      FirebaseAnalyticsObserver(analytics: analytics);
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    init();
    initializeNotifications();
    super.initState();
  }

  // Initialize the local notification plugin
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@drawable/ic_notification'); // Replace with your app icon name
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  init() async {
    //set token if user login
    var user = await _authService.getUser();

    // listen message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Handle foreground messages here
      if (user != null) {
        if (kDebugMode) {
          print('message ${message.notification?.title}');
        }
        showNotification(
            message.notification?.title, message.notification?.body);
      }
    });

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  // Display a local notification
  Future<void> showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'roomstock', // Replace with your channel ID
      'roomstock_message', //// Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Title
      body, // Body
      platformChannelSpecifics,
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stockroom Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryColor,
              onPrimary: Colors.black,
              secondary: primaryColor,
            ),
        iconTheme: const IconThemeData(color: primaryColor),
        primaryIconTheme: const IconThemeData(color: primaryColor),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0),
        fontFamily: 'work sans',
      ),
      navigatorObservers: [
        ClearFocusNavigatorObserver(),
        firebaseAnalyticsObserver,
      ],
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomePage.routeName: (context) => const HomePage(),
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        ForgotPassPage.routeName: (context) => const ForgotPassPage(),

        // dashboard user
        IndexPage.routeName: (context) =>
            IndexPage(ModalRoute.of(context)?.settings.arguments as dynamic),
        NotificationPage.routeName: (context) => const NotificationPage(),
        SearchPage.routeName: (context) =>
            SearchPage(ModalRoute.of(context)?.settings.arguments as String),
        ProductPage.routeName: (context) =>
            ProductPage(ModalRoute.of(context)?.settings.arguments as String),
        ProfilePage.routeName: (context) => const ProfilePage(),
        AddressPage.routeName: (context) =>
            AddressPage(ModalRoute.of(context)?.settings.arguments as List),
        AddAddressPage.routeName: (context) => const AddAddressPage(),
        OrderPage.routeName: (context) => OrderPage(
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>),
        HistoryOrderPage.routeName: (context) => HistoryOrderPage(),
        DetailOrderPage.routeName: (context) => DetailOrderPage(
            ModalRoute.of(context)?.settings.arguments as String),
        StatusOrderPage.routeName: (context) => StatusOrderPage(
            ModalRoute.of(context)?.settings.arguments as String),
        CancelOrderPage.routeName: (context) => CancelOrderPage(
            ModalRoute.of(context)?.settings.arguments as String),

        //  dashboard admin
        AdminIndexPage.routeName: (context) => AdminIndexPage(
            ModalRoute.of(context)?.settings.arguments as dynamic),
        ManageProductPage.routeName: (context) => ManageProductPage(
            ModalRoute.of(context)?.settings.arguments as String),
        AdminDetailOrderPage.routeName: (context) => AdminDetailOrderPage(
            ModalRoute.of(context)?.settings.arguments as String),
        UpdateOrderPage.routeName: (context) => UpdateOrderPage(
            ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}

class ClearFocusNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null) {
      FocusScopeNode currentFocus = FocusScope.of(route.navigator!.context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
  }
}
