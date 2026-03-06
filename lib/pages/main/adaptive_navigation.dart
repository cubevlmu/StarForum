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

void openSettingsAdaptive(BuildContext context) {
  if (isThreePaneLayout(context)) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width * 0.6;
    final maxHeight = size.height * 0.9;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: maxWidth.clamp(560.0, 760.0),
          height: maxHeight.clamp(620.0, 920.0),
          child: const SettingsDialogNavigator(),
        ),
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SettingsPage()),
  );
}
