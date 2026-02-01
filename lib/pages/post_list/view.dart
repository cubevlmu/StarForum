/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_list/controller.dart';
import 'package:forum/pages/post_list/create_discuss_util.dart';
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

  Widget _buildFloatBtn() {
    return Padding(
      padding: MediaQuery.of(context).size.width >= 640
          ? EdgeInsetsGeometry.only(bottom: 20)
          : EdgeInsetsGeometry.only(bottom: 80),
      child: FloatingActionButton(
        onPressed: () => _onCreateDiscussion(),
        child: Icon(Icons.add_outlined),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatBtn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildBody() {
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      childBuilder: (context, physics) {
        return Obx(() {
          final items = controller.items;
          final bool hasData = items.isNotEmpty;

          return CustomScrollView(
            controller: controller.scrollController,
            physics: physics,
            slivers: [
              if (!hasData)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: "🧐",
                    title: "这里还没有任何帖子",
                    tips: "下拉刷新试试看",
                  ),
                )
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return _buildPostItem(item);
                  }, childCount: items.length),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          );
        });
      },
    );
  }

  Widget _buildPostItem(DiscussionItem item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PostCard(item: item),
        ),
        const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
      ],
    );
  }

  void _onCreateDiscussion() {
    CreateDiscussUtil.showCreateDiscuss(
      updateWidget: () => controller.items.refresh(),
      scrollController: controller.scrollController,
    );
  }
}
