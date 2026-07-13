/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/pages/main/view.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/pages/finish_page.dart';
import 'package:star_forum/pages/setup/pages/greeting_page.dart';
import 'package:star_forum/pages/setup/pages/setup_site_page.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:get/get.dart';

class SetupPage extends StatefulWidget {
  final bool isSetup;
  final bool embedded;
  final VoidCallback? onFinish;

  const SetupPage({
    super.key,
    this.isSetup = false,
    this.embedded = false,
    this.onFinish,
  });

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  ForumInfo? siteInfo;
  late final SetupPageController controller;

  @override
  void initState() {
    controller = Get.isRegistered<SetupPageController>()
        ? Get.find<SetupPageController>()
        : Get.put(SetupPageController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (widget.isSetup) GreetingPage(controller: controller),
          if (!getIt<ForumRepository>().hasFixedBaseUrl)
            SetupSitePage(
              controller: controller,
              onBackPressed: _handleBackPressed,
            ),
          FinishPage(controller: controller, onFinish: _onFinishSetup),
        ],
      ),
    );
  }

  void _handleBackPressed() {
    if (controller.isLoading.value) {
      return;
    }
    if (widget.embedded) {
      FuiNavigation.closeCurrent(context);
      return;
    }
    if (widget.isSetup &&
        controller.pageController.hasClients &&
        (controller.pageController.page ?? 0) > 0) {
      controller.pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      return;
    }
    _onCloseCall();
  }

  void _onCloseCall() {
    Navigator.of(context).pop();
  }

  void _onFinishSetup() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().resetToHome();
    }
    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      FuiPageRoute(builder: (_) => const MainPage()),
      (route) => false,
    );
  }
}
