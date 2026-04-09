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
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
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
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => controller.showAddReplySheet(context),
        tooltip: AppLocalizations.of(context)!.postActionComment,
        child: Icon(Icons.reply_all_outlined),
      ),
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
      final hasReply =
          controller.replyItems.isNotEmpty ||
          controller.newReplyItems.isNotEmpty;
      final showReplySkeleton = controller.isReplyLoading.value && !hasReply;
      final showInitialSkeleton =
          showReplySkeleton || controller.firstPost.value == null;

      return SimpleEasyRefresher(
        onLoad: controller.onReplyLoad,
        onRefresh: controller.onReplyRefresh,
        easyRefreshController: controller.refreshController,
        autoRefreshOnStart: false,
        refreshEnabled: !showInitialSkeleton,
        loadEnabled: !showInitialSkeleton,
        childBuilder: (context, physics) {
          final hasReply =
              controller.replyItems.isNotEmpty ||
              controller.newReplyItems.isNotEmpty;
          final showReplySkeleton =
              controller.isReplyLoading.value && !hasReply;
          final effectivePhysics = showInitialSkeleton
              ? const ClampingScrollPhysics()
              : physics;

          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
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

              if (showReplySkeleton)
                const SliverToBoxAdapter(child: _ReplyListLoadingSkeleton())
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
        },
      );
    });
  }
}

class _ReplyListLoadingSkeleton extends StatelessWidget {
  const _ReplyListLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1420),
      highlightStrength: 0.22,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            3,
            (index) => _ReplyLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

@immutable
class _ReplyLoadingCard extends StatelessWidget {
  const _ReplyLoadingCard({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 44, height: 44, decoration: circleDecoration),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.32,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.22,
                      height: 12,
                    ),
                    const SizedBox(height: 14),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.96,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.84,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.58,
                      height: 12,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 74,
                          height: 32,
                          decoration: pillDecoration,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 44,
                          height: 32,
                          decoration: pillDecoration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
