/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/post_list/controller.dart';
import 'package:forum/widgets/post_card.dart';
import 'package:forum/widgets/shared_notice.dart';
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

  Widget _buildView(BuildContext context) {
    return Scaffold(
      body: SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        childBuilder: (context, physics) => Obx(() {
          final items = controller.items;

          return ListView.builder(
            controller: controller.scrollController,
            physics: physics,
            padding: EdgeInsets.zero,
            itemCount: items.isEmpty ? 1 : items.length,
            itemBuilder: (context, index) {
              if (items.isEmpty) {
                return _onEmptyView(context);
              }

              final item = items[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: PostCard(item: item),
                  ),
                  if (index != items.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 12,
                      endIndent: 12,
                    ),
                  if (index == items.length - 1)
                    const Padding(padding: EdgeInsets.only(bottom: 65)),
                ],
              );
            },
          );
        }),
      ),
      floatingActionButton: Padding(
        padding: MediaQuery.of(context).size.width >= 640
            ? EdgeInsetsGeometry.only(bottom: 20)
            : EdgeInsetsGeometry.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add_outlined),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _onEmptyView(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: SharedNotice.buildNoticeView(
        context,
        "🧐",
        "这里还没有任何帖子",
        "下拉刷新试试看",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildView(context);
  }
}
