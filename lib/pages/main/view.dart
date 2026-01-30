/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/main/controller.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainController controller;

  @override
  void initState() {
    //清理上一次启动留下的图片缓存
    CacheUtils.deleteAllCacheImage();
    // BiliUrlScheme.init(context);
    controller = Get.put(MainController());
    super.initState();
  }

  void onDestinationSelected(int value) {
    // 点击当前 NavigationBar
    if (value == controller.selectedIndex.value) {
      // var currentPage = controller.pages[value];
      // 首页
    //   if (currentPage is HomePage) {
    //     var homeController = Get.find<HomeController>();
    //     // var controllerName = homeController
    //     //     .tabsList[homeController.tabController!.index]['controller'];
    //     // late dynamic controller;
    //     // // if (controllerName == 'RecommendController') {
    //     // //   controller = Get.find<RecommendController>();
    //     // // } else if (controllerName == "PopularVideoController") {
    //     // //   controller = Get.find<PopularVideoController>();
    //     // // } else if (controllerName == "LiveTabPageController") {
    //     // //   controller = Get.find<LiveTabPageController>();
    //     // // }
    //     // if (controller.scrollController.offset == 0) {
    //     //   controller.refreshController.callRefresh();
    //     // } else {
    //     //   controller.animateToTop();
    //     // }
    //   }
    //   // 动态
    //   if (currentPage is AccountPage) {
    //     // var controller = Get.find<AccountPageController>();
    //     // if (controller.scrollController.offset == 0) {
    //     //   controller.refreshController.callRefresh();
    //     // } else {
    //     //   Get.find<AccountPageController>().animateToTop();
    //     // }
    //   }
    // }
    }
    controller.selectedIndex.value = value;
  }

  @override
  void dispose() {
    Get.delete<MainController>();
    super.dispose();
  }

  // 主视图
  Widget _buildView() {
    return Obx(
      () => Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        primary: true,
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 640)
              NavigationRail(
                extended: false,
                groupAlignment: 0,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text("首页"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications),
                    label: Text("通知"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    label: Text("账户"),
                    selectedIcon: Icon(Icons.account_circle),
                  ),
                ],
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (value) => onDestinationSelected(value),
              ),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: controller.pages,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: MediaQuery.of(context).size.width < 640
            ? NavigationBar(
                height: 64,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: "首页",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    label: "通知",
                    selectedIcon: Icon(Icons.notifications),
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    label: "账户",
                    selectedIcon: Icon(Icons.account_circle),
                  ),
                ],
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (value) => onDestinationSelected(value),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildView();
  }
}
