/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/settings/settings_page.dart';
import 'package:star_forum/pages/user/view.dart';

const double kThreePaneBreakPoint = 980;

bool isThreePaneLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= kThreePaneBreakPoint;
}

void openDiscussionAdaptive(BuildContext context, DiscussionItem item) {
  final useThreePane = isThreePaneLayout(context);
  if (Get.isRegistered<MainController>()) {
    final mainController = Get.find<MainController>();
    if (useThreePane) {
      mainController.showDiscussionDetail(item);
      return;
    }
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PostPage(item: item)),
  );
}

void openUserAdaptive(BuildContext context, int userId) {
  final useThreePane = isThreePaneLayout(context);
  if (Get.isRegistered<MainController>()) {
    final mainController = Get.find<MainController>();
    if (useThreePane) {
      mainController.showUserDetail(userId);
      return;
    }
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => UserPage(userId: userId)),
  );
}

void openSettingsAdaptive(BuildContext context) {
  final useThreePane = isThreePaneLayout(context);
  if (Get.isRegistered<MainController>()) {
    final mainController = Get.find<MainController>();
    if (useThreePane) {
      mainController.showSettingsDetail();
      return;
    }
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SettingsPage()),
  );
}
