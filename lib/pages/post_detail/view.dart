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
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/post_detail/widgets/post_main.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
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
  late final bool _shouldDeleteControllerOnDispose;

  @override
  void initState() {
    controllerTag = "PostPage:${widget.item.id}:${widget.embedded}";
    if (Get.isRegistered<PostPageController>(tag: controllerTag)) {
      controller = Get.find<PostPageController>(tag: controllerTag);
    } else {
      controller = Get.put(
        PostPageController(discussion: widget.item),
        tag: controllerTag,
      );
    }
    _shouldDeleteControllerOnDispose = !widget.embedded;
    if (controller.replyItems.isEmpty && controller.newReplyItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.onReplyLoad();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_shouldDeleteControllerOnDispose &&
        Get.isRegistered<PostPageController>(tag: controllerTag)) {
      Get.delete<PostPageController>(tag: controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: _ReplyFab(controller: controller),
      appBar: _DetailTitleBar(
        item: widget.item,
        embedded: widget.embedded,
        onReply: () => controller.showAddReplySheet(context),
      ),
      body: _DetailPageReplies(
        controller: controller,
        item: widget.item,
        controllerTag: controllerTag,
      ),
    );
  }
}

class _ReplyFab extends StatelessWidget {
  const _ReplyFab({required this.controller});

  final PostPageController controller;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () => controller.showAddReplySheet(context),
      tooltip: AppLocalizations.of(context)!.postActionComment,
      child: const Icon(Icons.reply_all_outlined),
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
  final bool embedded;
  final VoidCallback onReply;

  const _DetailTitleBar({
    required this.item,
    required this.onReply,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainController = embedded && Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : null;

    return AppBar(
      automaticallyImplyLeading: !embedded,
      leading: embedded
          ? IconButton(
              onPressed: () {
                if (mainController == null) return;
                if (mainController.canPopDetail) {
                  mainController.popDetail();
                  return;
                }
                mainController.closeDetail();
              },
              icon: Icon(
                mainController?.canPopDetail == true
                    ? Icons.arrow_back_rounded
                    : Icons.close_rounded,
              ),
            )
          : null,
      title: Text(AppLocalizations.of(context)!.postTitlePrefix(item.title)),
      shadowColor: Theme.of(context).shadowColor,
      actions: [
        if (embedded)
          IconButton(
            onPressed: onReply,
            tooltip: AppLocalizations.of(context)!.postActionComment,
            icon: const Icon(Icons.reply_all_outlined),
          ),
        if (Platform.isAndroid || Platform.isAndroid)
          IconButton(
            onPressed: _onShareClick,
            icon: const Icon(Icons.share_outlined),
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
    return Obx(() {
      final replyItems = controller.replyItems;
      final newReplyItems = controller.newReplyItems;
      final hasReply = replyItems.isNotEmpty || newReplyItems.isNotEmpty;
      final showReplySkeleton = controller.isReplyLoading.value && !hasReply;

      return SimpleEasyRefresher(
        onLoad: controller.onReplyLoad,
        onRefresh: controller.onReplyRefresh,
        easyRefreshController: controller.refreshController,
        autoRefreshOnStart: false,
        refreshEnabled: !showReplySkeleton,
        loadEnabled: !showReplySkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showReplySkeleton
              ? const ClampingScrollPhysics()
              : physics;

          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              SliverToBoxAdapter(
                child: PostMainWidget(
                  content: item,
                  controllerTag: controllerTag,
                ),
              ),

              SliverToBoxAdapter(
                child: _SortReplyItemWidget(replyController: controller),
              ),

              if (showReplySkeleton)
                const SliverToBoxAdapter(
                  child: PostListLoadingSkeleton(minItems: 3, maxItems: 6),
                )
              else if (!hasReply)
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final totalNew = newReplyItems.length;

                    if (index < totalNew) {
                      return PostItemWidget(
                        reply: newReplyItems[index],
                        controllerTag: controllerTag,
                      );
                    }

                    final i = index - totalNew;
                    return PostItemWidget(
                      reply: replyItems[i],
                      controllerTag: controllerTag,
                    );
                  }, childCount: newReplyItems.length + replyItems.length),
                ),
            ],
          );
        },
      );
    });
  }
}
