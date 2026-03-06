/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';

import 'package:star_forum/pages/home/view.dart';
import 'package:star_forum/pages/notification/view.dart';
import 'package:star_forum/pages/account/view.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;
  final Rxn<DiscussionItem> selectedDiscussion = Rxn<DiscussionItem>();
  final RxBool isHomeSearchActive = false.obs;
  final RxnString homeSearchKeyword = RxnString();

  List<Widget> pages = [
    const HomePage(),
    const NotificationPage(),
    const AccountPage(),
  ];

  void _initData() {
    // update(["main"]);
  }

  void onDestinationSelected(int index) {
    if (selectedIndex.value == index) return;
    if (index != 0) {
      isHomeSearchActive.value = false;
      homeSearchKeyword.value = null;
    }
    selectedIndex.value = index;
  }

  void showDiscussionDetail(DiscussionItem discussion) {
    if (selectedDiscussion.value?.id == discussion.id) {
      selectedDiscussion.value = null;
    }
    selectedDiscussion.value = discussion;
  }

  void openHomeSearch() {
    isHomeSearchActive.value = true;
    homeSearchKeyword.value = null;
  }

  void closeHomeSearch() {
    isHomeSearchActive.value = false;
    homeSearchKeyword.value = null;
  }

  void submitHomeSearch(String keyword) {
    isHomeSearchActive.value = true;
    if (homeSearchKeyword.value == keyword) {
      homeSearchKeyword.value = '';
      Future.microtask(() {
        homeSearchKeyword.value = keyword;
      });
      return;
    }
    homeSearchKeyword.value = keyword;
  }

  void editHomeSearch() {
    homeSearchKeyword.value = null;
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
