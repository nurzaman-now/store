import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store/common/styles.dart';
import 'package:store/firebase_services/order_services.dart';
import 'package:store/ui/admin/menus/order_menus/manage_product_page.dart';
import 'package:store/ui/admin/menus/order_page.dart';
import 'package:store/ui/others/notification_page.dart';
import 'package:store/ui/user/menus/dashboard_page.dart';

import '../../firebase_services/auth_services.dart';
import '../others/search_page.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text.dart';
import 'menus/dashboard_page.dart';
import 'menus/profile_page.dart';

class AdminIndexPage extends StatefulWidget {
  static String routeName = '/admin/index_page';
  final dynamic index;

  const AdminIndexPage(this.index, {Key? key}) : super(key: key);

  @override
  State<AdminIndexPage> createState() => AdminIndexPageState();
}

class AdminIndexPageState extends State<AdminIndexPage> {
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  int _bottomNavIndex = 0;
  String image = '';
  int countOrder = 0;

  final List<String> _status = ["DIKEMAS", "DIKIRIM", "SELESAI", "DIBATALKAN"];

  @override
  void initState() {
    super.initState();
    fetchData();
    widget.index != 0 ? _bottomNavIndex = widget.index : 0;
  }

  final TextEditingController _querySearch = TextEditingController();

  final List<Widget> _listWidget = [
    const AdminDashboardPage(),
    AdminOrderPage(),
    const AdminProfilePage()
  ];

  final List<String> _title = const [
    DashboardPage.title,
    AdminOrderPage.title,
    AdminProfilePage.title
  ];

  final List<String> _iconAssets = const [
    'assets/logo/home.svg',
    'assets/logo/cart.svg',
    'assets/images/avatar.png'
  ];

  void fetchData() async {
    try {
      var data = await _authService
          .getUser(); // Contoh Future yang mengembalikan String
      var order = await _orderService.getAllOrders();
      // Callback yang dijalankan ketika Future selesai
      setState(() {
        image = data!['image'];
        countOrder = 0;
        for (var element in order) {
          if (element.status == 1) {
            countOrder += 1;
          }
        }
      });

// Menggunakan hasil Future sesuai kebutuhan Anda
    } catch (error) {
      // Callback yang dijalankan jika terjadi error saat menjalankan Future
      if (kDebugMode) {
        print('Error: $error');
      }
      return null;
    }
  }

  List<CustomAppbar> _listAppbar() {
    return [
      CustomAppbar(
        title: _title[_bottomNavIndex],
        isActionIcon: true,
        isBottom: true,
        isBack: false,
        bottomItem: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 28, right: 28),
            padding: const EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.6,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: thirdColor, width: 1),
                borderRadius: BorderRadius.circular(15)),
            child: TextField(
                cursorColor: Colors.black,
                controller: _querySearch,
                decoration: const InputDecoration(
                  hintText: 'Cari',
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 10),
                ),
                style: const TextStyle(fontSize: 16),
                onSubmitted: (String value) {
                  FocusScope.of(context).unfocus();
                  Navigator.pushNamed(context, SearchPage.routeName,
                      arguments: value);
                  setState(() {
                    _querySearch.clear();
                  });
                }),
          ),
        ),
        actionIcon: [
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 31),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_rounded,
                  size: 35,
                ),
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -1),
                          // Slide up from the top
                          end: Offset.zero,
                        ).animate(animation),
                        child: const NotificationPage(),
                      );
                    },
                  ),
                ),
              ))
        ],
      ),
      CustomAppbar(
        titleActions: _title[_bottomNavIndex],
        bottomItem: TabBar(
          indicatorColor: primaryColor,
          isScrollable: true,
          tabs: List.generate(
            _status.length,
            (index) => Tab(
                icon: CustomText(
              text: _status[index],
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            )),
          ),
        ),
        isBottom: true,
      ),
      CustomAppbar(
        titleActions: _title[_bottomNavIndex],
        isBack: false,
      ),
    ];
  }

  void _onBottomNavTapped(int index) {
    FocusScope.of(context).unfocus();
    fetchData();
    setState(() {
      _bottomNavIndex = index;
    });
  }

  Widget _bottomNavigationBar() {
    return Container(
        height: 70,
        decoration: const BoxDecoration(
          color: secondaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // horizontal, vertical offset
            ),
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                  3,
                  (index) => Stack(
                        alignment: Alignment.center,
                        children: [
                          _bottomNavIndex == index
                              ? Positioned(
                                  top: 0,
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: SvgPicture.asset(
                                          'assets/logo/selected.svg')))
                              : const SizedBox(),
                          SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: IconButton(
                                icon: index != 2
                                    ? SvgPicture.asset(
                                        _iconAssets[index],
                                      )
                                    : image == ''
                                        ? SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: Image.asset(
                                              _iconAssets[index],
                                            ))
                                        : SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: ClipOval(
                                              child: FadeInImage(
                                                placeholder: const AssetImage(
                                                    'assets/logo/loading_icon.gif'),
                                                image: NetworkImage(image),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                onPressed: () => _onBottomNavTapped(index),
                              )),
                          index == 1 && countOrder != 0
                              ? Positioned(
                                  top: 15,
                                  right: 15,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      countOrder.toString(),
                                      // Replace with the badge text or counter value
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : const Text('')
                        ],
                      ))),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_bottomNavIndex == 0) {
          return true;
        } else {
          setState(() {
            _bottomNavIndex = 0;
          });
          // Return false to prevent the default back button behavior
          return false;
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: DefaultTabController(
          length: _status.length,
          child: Scaffold(
            appBar: _listAppbar()[_bottomNavIndex],
            body: _listWidget[_bottomNavIndex],
            bottomNavigationBar: _bottomNavigationBar(),
            floatingActionButton: _bottomNavIndex == 0
                ? FloatingActionButton(
                    mini: true,
                    onPressed: () => Navigator.pushNamed(
                        context, ManageProductPage.routeName,
                        arguments: ''),
                    child: const Icon(Icons.add),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
