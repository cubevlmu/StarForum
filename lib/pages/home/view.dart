/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/home/widgets/user_dialog.dart';
import 'package:star_forum/pages/post_list/controller.dart';
import 'package:star_forum/pages/post_list/view.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/theme_list/controller.dart';
import 'package:star_forum/pages/theme_list/view.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/sheet_util.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late HomeController controller;

  final PostListPage postListPage = const PostListPage();
  final ThemeListPage themeListPage = const ThemeListPage();
  // final LiveTabPage liveTabPage = const LiveTabPage();
  List<Map<String, dynamic>> tabsList = [];

  @override
  void initState() {
    controller = Get.put(HomeController());
    tabsList = controller.tabsList;
    controller.tabController = TabController(
      length: tabsList.length,
      vsync: this,
      initialIndex: controller.tabInitIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.info.value?.title ?? "")),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchPage()),
              );
            },
            icon: Icon(Icons.search_outlined),
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
                SheetUtil.newBottomSheet(widget: UserDialogWidget(controller: controller));
              },
            );
          }),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          isScrollable: true,
          tabs: tabsList.map((e) => Tab(text: e['text'])).toList(),
          controller: controller.tabController,
          onTap: (index) {
            if (controller.tabController!.indexIsChanging) return;
            switch (index) {
              case 0:
                Get.find<PostListController>().animateToTop();
                break;
              case 1:
                Get.find<ThemeListController>().animateToTop();
                break;
              default:
            }
          },
        ),
      ),
      // body:
      body: TabBarView(
        controller: controller.tabController,
        children: tabsList.map((e) {
          switch (e['text']) {
            case '贴文':
              return postListPage;
            case '主题':
              return themeListPage;
            default:
              return const WorkInProgressNotice();
          }
        }).toList(),
      ),
    );
  }
}
