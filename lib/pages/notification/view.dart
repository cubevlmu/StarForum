/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/notification/widgets/notify_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
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
            Obx(() {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: "📭",
                    title: AppLocalizations.of(context)!.notificationEmptyTitle,
                    tips: AppLocalizations.of(context)!.notificationEmptyTips,
                  ),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: NotifyCard(item: item, controller: controller),
                    );
                  }, childCount: items.length),
                );
              }
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: controller.isLogin.value
            ? _buildView(context)
            : NotLoginNotice(
                title: AppLocalizations.of(context)!.notificationNotLoginTitle,
                tipsText: AppLocalizations.of(
                  context,
                )!.notificationNotLoginTips,
              ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.notificationTitle),
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
                  openSettingsAdaptive(context);
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
