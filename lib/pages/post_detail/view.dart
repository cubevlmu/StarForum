/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_detail/controller.dart';
import 'package:forum/pages/post_detail/widgets/post_item.dart';
import 'package:forum/pages/post_detail/widgets/post_main.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/shared_notice.dart';
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
    controller = Get.put(PostPageController(discussion: widget.item));
    super.initState();
  }

  @override
  void dispose() {
    try {
      Get.delete<PostPageController>();
    } catch (e, s) {
      LogUtil.errorE("[PostDetailPage] failed to dispose controller", e, s);
    }
    super.dispose();
  }

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
            SliverToBoxAdapter(child: PostMainWidget(content: widget.item)),

            SliverToBoxAdapter(
              child: SortReplyItemWidget(replyController: controller),
            ),

            if (!hasReply)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: NoticeWidget(
                  emoji: "💬",
                  title: "还没有回复",
                  tips: "成为第一个发表评论的人吧",
                ),
              )
            else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = controller.newReplyItems[index];
                  return PostItemWidget(reply: item);
                }, childCount: controller.newReplyItems.length),
              ),

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddReplySheet,
        tooltip: '发表评论',
        child: Icon(Icons.reply),
      ),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 12, right: 12),
        child: _buildView(controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("贴文: ${widget.item.title}"),
      shadowColor: Theme.of(context).shadowColor,
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
          onPressed: () {
            replyController.toggleSort();
          },
        ),
      ],
    );
  }
}
