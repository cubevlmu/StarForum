/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_detail/controller.dart';
import 'package:forum/pages/post_detail/widgets/post_item.dart';
import 'package:forum/pages/post_detail/widgets/post_main.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.item});
  final DiscussionItem item;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  _PostPageState();
  @override
  bool get wantKeepAlive => true;
  late PostPageController controller;

  @override
  void initState() {
    controller = Get.put(PostPageController(postId: widget.item.id));
    super.initState();
  }

  @override
  void dispose() {
    try {
      Get.delete<PostPageController>();
    } catch (ex) {
      log("[PostDetailPage] failed to dispose controller ${ex.toString()}");
    }
    super.dispose();
  }

  // Main view
  Widget _buildView(PostPageController controller) {
    controller.updateWidget = () => setState(() => ());

    final bool hasReply =
        controller.replyItems.isNotEmpty || controller.newReplyItems.isNotEmpty;

    return SimpleEasyRefresher(
      onLoad: controller.onReplyLoad,
      onRefresh: controller.onReplyRefresh,
      easyRefreshController: controller.refreshController,
      childBuilder: (context, physics) {
        return CustomScrollView(
          controller: controller.scrollController,
          physics: physics,
          slivers: [
            /// Main post (first post)
            SliverToBoxAdapter(child: PostMainWidget(content: widget.item)),

            /// Order button
            SliverToBoxAdapter(
              child: SortReplyItemWidget(replyController: controller),
            ),

            /// Check if no reply
            if (!hasReply)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _onEmptyReply(context),
              )
            else ...[
              /// New reply
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = controller.newReplyItems[index];
                  return PostItemWidget(reply: item);
                }, childCount: controller.newReplyItems.length),
              ),

              /// Old reply
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = controller.replyItems[index];
                  return PostItemWidget(reply: item);
                }, childCount: controller.replyItems.length),
              ),
            ],
          ],
        );
      },
    );
  }

  // Empty reply view
  Widget _onEmptyReply(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("💬", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              "还没有回复",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "成为第一个发表评论的人吧",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddReplySheet,
        tooltip: '发表评论',
        child: Icon(Icons.reply),
      ),
      appBar: AppBar(
        title: Text("贴文: ${widget.item.title}"),
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 12, right: 12),
        child: _buildView(controller),
      ),
    );
  }
}

class SortReplyItemWidget extends StatelessWidget {
  const SortReplyItemWidget({super.key, required this.replyController});
  final PostPageController replyController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Obx(
            () => Text(
              "回复: ${StringUtil.numFormat(replyController.replyCount.value)}",
            ),
          ),
        ),
        const Spacer(),
        //排列方式按钮
        MaterialButton(
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                size: 16,
                color: Get.textTheme.bodyMedium!.color,
              ),
              Obx(
                () => Text(
                  replyController.sortTypeText.value,
                  style: TextStyle(color: Get.textTheme.bodyMedium!.color),
                ),
              ),
            ],
          ),
          //点击切换评论排列方式
          onPressed: () {
            replyController.toggleSort();
          },
        ),
      ],
    );
  }
}
