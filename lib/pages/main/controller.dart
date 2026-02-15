/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */


import 'package:flutter/material.dart';

import 'package:star_forum/pages/home/view.dart';
import 'package:star_forum/pages/notification/view.dart';
import 'package:star_forum/pages/account/view.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;

  List<Widget> pages = [
    const HomePage(),
    const NotificationPage(),
    const AccountPage(),
  ];

  void _initData() {
    // update(["main"]);
  }

  void onTap() {}

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
