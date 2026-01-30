/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/notification/controller.dart';
import 'package:forum/pages/notification/widgets/notify_card.dart';
import 'package:forum/pages/settings/settings_page.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationPageController controller;

  @override
  void initState() {
    controller = Get.put(NotificationPageController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<NotificationPageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("消息通知"),
        actions: [
          IconButton(
            onPressed: () {
              controller.readAll();
            },
            icon: Icon(Icons.checklist_outlined),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              controller.clearAll();
            },
            icon: Icon(Icons.delete),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
            icon: Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        childBuilder: (context, physics) => Obx(() {
          return ListView.builder(
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            controller: controller.scrollController,
            physics: physics,
            padding: EdgeInsets.zero,
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 16, right: 16),
                    child: NotifyCard(item: item, controller: controller),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
