/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/pages/main/view.dart';
import 'package:star_forum/pages/setup/controller.dart';
import 'package:star_forum/pages/setup/pages/finish_page.dart';
import 'package:star_forum/pages/setup/pages/greeting_page.dart';
import 'package:star_forum/pages/setup/pages/setup_site_page.dart';
import 'package:get/get.dart';

class SetupPage extends StatefulWidget {
  final bool isSetup;
  final bool embedded;
  final VoidCallback? onEmbeddedLeadingPressed;
  final bool showEmbeddedBack;
  final VoidCallback? onFinish;

  const SetupPage({
    super.key,
    this.isSetup = false,
    this.embedded = false,
    this.onEmbeddedLeadingPressed,
    this.showEmbeddedBack = false,
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
        automaticallyImplyLeading: !(widget.isSetup || widget.embedded),
        leading: widget.isSetup
            ? null
            : widget.embedded
            ? Obx(
                () => IconButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : widget.onEmbeddedLeadingPressed,
                  icon: Icon(
                    widget.showEmbeddedBack
                        ? Icons.arrow_back_rounded
                        : Icons.close_rounded,
                  ),
                ),
              )
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
          if (!Api.hasFixedBaseUrl) SetupSitePage(controller: controller),
          FinishPage(
            controller: controller,
            onFinish: _onFinishSetup,
          ),
        ],
      ),
    );
  }

  void _onCloseCall() {
    Navigator.of(context).pop();
  }

  void _onFinishSetup() {
    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (route) => false,
    );
  }
}
