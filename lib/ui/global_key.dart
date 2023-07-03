import 'package:flutter/material.dart';
import 'package:store/ui/user/index_page.dart';
import 'package:store/ui/user/menus/cart_page.dart';

import 'user/menus/sub_menu/history_order_page.dart';

GlobalKey<IndexPageState> indexPageKey = GlobalKey<IndexPageState>();
GlobalKey<HistoryOrderPageState> pesananPageKey =
GlobalKey<HistoryOrderPageState>();
GlobalKey<CartPageState> cartPageKey =
GlobalKey<CartPageState>();

void refreshIndexPage() {
  final indexPageState = indexPageKey.currentState;
  // ignore: invalid_use_of_protected_member
  indexPageState?.fetchData();
}

void refreshPesananPage() {
  final pesananPageState = pesananPageKey.currentState;
  // ignore: invalid_use_of_protected_member
  pesananPageState?.fetchData();
}

void refreshCartPage() {
  final cartPageState = cartPageKey.currentState;

  cartPageState?.fetchData();
}
