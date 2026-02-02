/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_list/controller.dart';
import 'package:forum/pages/post_list/create_discuss_util.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/widgets/post_card.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage>
    with AutomaticKeepAliveClientMixin {
  late final PostListController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PostListController>()) {
      controller = Get.find<PostListController>();
      LogUtil.debug('[PostList] Controller reused');
    } else {
      controller = Get.put(PostListController());
      LogUtil.debug('[PostList] Controller created');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: _PostListView(controller: controller),
      floatingActionButton: _PostListFloatBtn(onPressed: _onCreateDiscussion),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _onCreateDiscussion() {
    CreateDiscussUtil.showCreateDiscuss(
      updateWidget: () => controller.items.refresh(),
      scrollController: controller.scrollController,
    );
  }
}

class _PostListView extends StatelessWidget {
  final PostListController controller;

  const _PostListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      autoRefreshOnStart: false,
      childBuilder: (context, physics) {
        return CustomScrollView(
          controller: controller.scrollController,
          physics: physics,
          slivers: [
            Obx(() {
              if (controller.items.isNotEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return const SliverFillRemaining(
                hasScrollBody: false,
                child: NoticeWidget(
                  emoji: '🧐',
                  title: '这里还没有任何帖子',
                  tips: '下拉刷新试试看',
                ),
              );
            }),

            Obx(() {
              final items = controller.items;
              if (items.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverPrototypeExtentList(
                prototypeItem: _PostListItem(item: items.first),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _PostListItem(item: items[index]);
                }, childCount: items.length),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

class _PostListFloatBtn extends StatelessWidget {
  final VoidCallback? onPressed;

  const _PostListFloatBtn({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).size.width >= 640
          ? const EdgeInsets.only(bottom: 20)
          : const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}

class _PostListItem extends StatelessWidget {
  final DiscussionItem item;

  const _PostListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PostCard(item: item),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
