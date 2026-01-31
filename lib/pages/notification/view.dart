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
import 'package:forum/widgets/shared_notice.dart';
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

  Widget _buildView(BuildContext context) {
    final items = controller.items;

    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      childBuilder: (context, physics) {
        return CustomScrollView(
          controller: controller.scrollController,
          physics: physics,
          slivers: [
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: SharedNotice.buildNoticeView(context, "📭", "暂无通知", "这里会显示回复、提及和系统消息"),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: NotifyCard(item: item, controller: controller),
                  );
                }, childCount: items.length),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLogin = controller.isLogin.value;

      return Scaffold(
        appBar: _buildAppBar(context),
        body: isLogin ? _buildView(context) : SharedNotice.onNotLogin(context, "你还没有登录", "登录后即可查看消息通知"),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("通知"),
      actions: [
        if (controller.isLogin.value)
          IconButton(
            onPressed: controller.isInvoking.value ? null : controller.readAll,
            icon: const Icon(Icons.checklist_outlined),
          ),
        const SizedBox(width: 10),
        if (controller.isLogin.value)
          IconButton(
            onPressed: controller.isInvoking.value ? null : controller.clearAll,
            icon: const Icon(Icons.delete),
          ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: controller.isInvoking.value
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsPage()),
                  );
                },
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 10),
      ],
      bottom: controller.isInvoking.value
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }
}
