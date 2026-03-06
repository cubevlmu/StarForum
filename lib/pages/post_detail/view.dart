/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/post_detail/widgets/post_main.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.item, this.embedded = false});
  final DiscussionItem item;
  final bool embedded;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  _PostPageState();
  @override
  bool get wantKeepAlive => true;
  late PostPageController controller;
  late String controllerTag;

  @override
  void initState() {
    controllerTag = "PostPage:${widget.item.id}:${widget.embedded}";
    controller = Get.put(
      PostPageController(discussion: widget.item),
      tag: controllerTag,
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<PostPageController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.embedded) {
      return Column(
        children: [
          _EmbeddedDetailHeader(item: widget.item, controller: controller),
          const Divider(height: 1),
          Expanded(
            child: _DetailPageReplies(
              controller: controller,
              item: widget.item,
              controllerTag: controllerTag,
            ),
          ),
        ],
      );
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddReplySheet(context),
        tooltip: AppLocalizations.of(context)!.postActionComment,
        child: Icon(Icons.reply_all_outlined),
      ),
      appBar: _DetailTitleBar(item: widget.item),
      body: _DetailPageReplies(
        controller: controller,
        item: widget.item,
        controllerTag: controllerTag,
      ),
    );
  }
}

class _EmbeddedDetailHeader extends StatelessWidget {
  const _EmbeddedDetailHeader({required this.item, required this.controller});

  final DiscussionItem item;
  final PostPageController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.postTitlePrefix(item.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => controller.showAddReplySheet(context),
                tooltip: AppLocalizations.of(context)!.postActionComment,
                icon: const Icon(Icons.reply_all_outlined),
              ),
              IconButton(
                onPressed: () =>
                    Share.shareUri(Uri.parse("${Api.getBaseUrl}/d/${item.id}")),
                icon: const Icon(Icons.share_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortReplyItemWidget extends StatelessWidget {
  const _SortReplyItemWidget({required this.replyController});
  final PostPageController replyController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Text(
            l10n.postReplyPrefix(
              StringUtil.ensureNotNegative(
                replyController.discussion.commentCount - 1,
              ),
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

class _DetailTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final DiscussionItem item;

  const _DetailTitleBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.postTitlePrefix(item.title)),
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
  final String controllerTag;

  const _DetailPageReplies({
    required this.controller,
    required this.item,
    required this.controllerTag,
  });

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
                    controllerTag: controllerTag,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _SortReplyItemWidget(replyController: controller),
              ),

              if (!hasReply)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: "💬",
                    title: AppLocalizations.of(context)!.postNoReplyTitle,
                    tips: AppLocalizations.of(context)!.postNoReplyTips,
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
                          controllerTag: controllerTag,
                        );
                      }

                      final i = index - totalNew;
                      return PostItemWidget(
                        reply: controller.replyItems[i],
                        controllerTag: controllerTag,
                      );
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
