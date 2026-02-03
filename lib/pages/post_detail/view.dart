/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_detail/controller.dart';
import 'package:forum/pages/post_detail/widgets/post_item.dart';
import 'package:forum/pages/post_detail/widgets/post_main.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

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
    Get.delete<PostPageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddReplySheet,
        tooltip: '发表评论',
        child: Icon(Icons.reply_all_outlined),
      ),
      appBar: _DetailTitleBar(item: widget.item),
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 12, right: 12),
        child: _DetailPageReplies(controller: controller, item: widget.item),
      ),
    );
  }
}

class _SortReplyItemWidget extends StatelessWidget {
  const _SortReplyItemWidget({required this.replyController});
  final PostPageController replyController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Text(
            "回复: ${StringUtil.ensureNotNegative(replyController.discussion.commentCount-1)}",
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

class _DetailTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final DiscussionItem item;

  const _DetailTitleBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("贴文: ${item.title}"),
      shadowColor: Theme.of(context).shadowColor,
      actions: [
        if (Platform.isAndroid || Platform.isAndroid)
          IconButton(
            onPressed: _onShareClick,
            icon: Icon(Icons.share_outlined),
          ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _onShareClick() async {
    await Share.shareUri(Uri.parse("${Api.getBaseUrl}/d/${item.id}"));
  }
}

class _DetailPageReplies extends StatelessWidget {
  final PostPageController controller;
  final DiscussionItem item;

  const _DetailPageReplies({required this.controller, required this.item});

  @override
  Widget build(BuildContext context) {
    return SimpleEasyRefresher(
      onLoad: controller.onReplyLoad,
      onRefresh: controller.onReplyRefresh,
      easyRefreshController: controller.refreshController,
      childBuilder: (context, physics) {
        return Obx(() {
          final hasReply =
              controller.replyItems.isNotEmpty ||
              controller.newReplyItems.isNotEmpty;

          return CustomScrollView(
            controller: controller.scrollController,
            physics: physics,
            slivers: [
              SliverToBoxAdapter(
                child: Obx(
                  () => PostMainWidget(
                    content: item,
                    info: controller.firstPost.value,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _SortReplyItemWidget(replyController: controller),
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
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final totalNew = controller.newReplyItems.length;

                      if (index < totalNew) {
                        return PostItemWidget(
                          reply: controller.newReplyItems[index],
                        );
                      }

                      final i = index - totalNew;
                      return PostItemWidget(reply: controller.replyItems[i]);
                    },
                    childCount:
                        controller.newReplyItems.length +
                        controller.replyItems.length,
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}
