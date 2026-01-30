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

  // 主视图
  Widget _buildView(PostPageController controller) {
    controller.updateWidget = () => setState(() => ());
    return SimpleEasyRefresher(
      childBuilder: (context, physics) => ListView.builder(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        controller: controller.scrollController,
        physics: physics,
        padding: const EdgeInsets.all(0),
        itemCount: controller.replyItems.length + controller.newReplyItems.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return PostMainWidget(content: widget.item);
          } else if (index == 1) {
            //在首个元素前放置排列方式切换控件
            return Column(
              children: [SortReplyItemWidget(replyController: controller)],
            );
          } else {
            if (index < controller.newReplyItems.length + 2) {
              final item = controller.newReplyItems[index - 2];
              return PostItemWidget(reply: item);
            }
            final item = controller.replyItems[index - 2 - controller.newReplyItems.length];
            return PostItemWidget(reply: item);
          }
        },
      ),
      onLoad: controller.onReplyLoad,
      onRefresh: controller.onReplyRefresh,
      easyRefreshController: controller.refreshController,
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
