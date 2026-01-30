/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/user/controller.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:forum/widgets/cached_network_image.dart';
import 'package:get/get.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.userId})
    : tag = "user_space:$userId";

  final int userId;
  final String tag;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  late final UserPageController controller;

  @override
  void initState() {
    controller = Get.put(
      UserPageController(userId: widget.userId),
      tag: widget.tag,
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<UserPageController>(tag: widget.tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Text("用户:")),
      body: SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        childBuilder: (context, physics) {
          return ListView(
            physics: physics,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _UserHeader(controller: controller),
              const SizedBox(height: 8),
              _UserStats(controller: controller),
              const SizedBox(height: 8),
              Divider(
                height: 1,
                indent: 25,
                endIndent: 25,
                color: Theme.of(context).highlightColor,
              ),

              /// TODO: 投稿列表
              // _UserPostList(controller: controller),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 头像
          MaterialButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              width: 45,
              height: 45,
              imageUrl: "",
              cacheManager: controller.cacheManager,
              placeholder: () => const SizedBox(width: 45, height: 45),
            ),
          ),

          const SizedBox(width: 12),

          /// 🔴 关键：Expanded
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Obx(
                  // () => 
                  Text(
                    // controller.name.value,
                    "xxx",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                // ),

                const SizedBox(height: 4),

                // 等级 / 经验（以后加也安全）
                // Obx(() => Text("LV${controller.level.value}")),
              ],
            ),
          ),

          /// 登录按钮（可选）
          // IconButton(
          //   icon: const Icon(Icons.login),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }
}

class _UserStats extends StatelessWidget {
  const _UserStats({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.labelMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(title: "动态", value: "0", color: textColor, onTap: () {}),
          _StatItem(title: "关注", value: "0", color: textColor, onTap: () {}),
          _StatItem(title: "粉丝", value: "0", color: textColor, onTap: () {}),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
    this.onTap,
    this.color,
  });

  final String title;
  final String value;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}
