/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/pages/finish_page.dart';
import 'package:star_forum/pages/setup/pages/greeting_page.dart';
import 'package:star_forum/pages/setup/pages/setup_site_page.dart';
import 'package:get/get.dart';

class SetupPage extends StatefulWidget {
  final bool isSetup;

  const SetupPage({super.key, this.isSetup = false});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  ForumInfo? siteInfo;
  late final SetupPageController controller;

  @override
  void initState() {
    controller = Get.put(SetupPageController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<SetupPageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: widget.isSetup
            ? null
            : Obx(
                () => IconButton(
                  onPressed: controller.isLoading.value ? null : _onCloseCall,
                  icon: const Icon(Icons.arrow_back_outlined),
                ),
              ),
      ),
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (widget.isSetup) GreetingPage(controller: controller),
          SetupSitePage(controller: controller),
          FinishPage(controller: controller),
        ],
      ),
    );
  }

  void _onCloseCall() {
    Navigator.of(context).pop();
  }
}
