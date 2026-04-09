/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/badge/view.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/home/widgets/user_dialog.dart';
import 'package:star_forum/pages/post_list/view.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/subscription/view.dart';
import 'package:star_forum/pages/user_group/view.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/sheet_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final HomeController controller;
  late final TabController _tabController;

  @override
  void initState() {
    controller = Get.put(HomeController());
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.info.value?.title ?? "")),
        actions: [
          IconButton(
            onPressed: () {
              if (isThreePaneLayout(context)) {
                if (Get.isRegistered<MainController>()) {
                  Get.find<MainController>().openHomeSearch();
                }
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search_outlined),
          ),
          const SizedBox(width: 10),
          Obx(() {
            return AvatarWidget(
              avatarUrl: controller.isLogin.value
                  ? controller.avatarUrl.value
                  : "",
              radius: 18,
              placeholder: "",
              onPressed: () {
                SheetUtil.newBottomSheet(
                  widget: UserDialogWidget(controller: controller),
                );
              },
            );
          }),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: l10n.homeSectionAllTopics),
                Tab(text: l10n.homeSectionFollowing),
                Tab(text: l10n.homeSectionUsers),
                Tab(text: l10n.homeSectionBadges),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                PostListPage(),
                SubscriptionPage(),
                UserGroupPage(),
                BadgePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
