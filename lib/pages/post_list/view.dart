/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/post_list/controller.dart';
import 'package:forum/widgets/post_card.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late PostListController controller;

  @override
  void initState() {
    controller = Get.put(PostListController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<PostListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleEasyRefresher(
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
                  padding: EdgeInsetsGeometry.only(left: 8, right: 8),
                  child: PostCard(item: item),
                ),
                if (index != controller.items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 12,
                    endIndent: 12,
                  ),
                if (index == controller.items.length - 1)
                  const Padding(padding: EdgeInsetsGeometry.only(bottom: 65))
              ],
            );
          },
        );
      }),
    );
  }
}
