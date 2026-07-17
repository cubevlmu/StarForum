/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/post_detail/widgets/post_main.dart';
import 'package:star_forum/widgets/desktop_scroll_accelerator.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fin_ui/fin_ui.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.item, this.embedded = false});
  final DiscussionSummary item;
  final bool embedded;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  _PostPageState();
  @override
  bool get wantKeepAlive => true;
  late final PostPageController controller;
  late final String controllerTag;

  @override
  void initState() {
    controllerTag = 'PostPage:${widget.item.id}:${identityHashCode(this)}';
    controller = Get.put(
      PostPageController(discussion: widget.item),
      tag: controllerTag,
    );
    super.initState();
  }

  @override
  void dispose() {
    if (Get.isRegistered<PostPageController>(tag: controllerTag)) {
      Get.delete<PostPageController>(tag: controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = _DetailPageReplies(
      controller: controller,
      item: widget.item,
      controllerTag: controllerTag,
      embedded: widget.embedded,
      onReply: () => controller.showAddReplySheet(context),
    );
    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButton: _ReplyFab(controller: controller),
      body: body,
    );
  }
}

class _ReplyFab extends StatelessWidget {
  const _ReplyFab({required this.controller});

  final PostPageController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => controller.showBackToTop.value
              ? Padding(
                  padding: const EdgeInsets.only(bottom: FUITokens.gap10),
                  child: FUIIconButton(
                    size: 48,
                    onPressed: controller.animateToTop,
                    tooltip: l10n.backToTopTooltip,
                    icon: ForumIcons.backToTop,
                    variant: FUIIconButtonVariant.outline,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        SizedBox.square(
          dimension: 48,
          child: Center(
            child: Transform.scale(
              scale: 1.2,
              child: FUIFloatingActionButton(
                heroTag: null,
                small: true,
                onPressed: () => controller.showAddReplySheet(context),
                tooltip: l10n.postActionComment,
                icon: ForumIcons.reply,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SortReplyItemWidget extends StatelessWidget {
  const _SortReplyItemWidget({required this.replyController});
  final PostPageController replyController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showSortLabels = MediaQuery.sizeOf(context).width >= 600;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap10,
        FUITokens.pagePadding,
        FUITokens.gap4,
      ),
      child: FUISurface(
        padding: const EdgeInsets.all(FUITokens.gap8),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  l10n.postReplyPrefix(replyController.replyCount.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: FUITokens.gap8),
            IntrinsicWidth(
              child: Obx(
                () => FUIButtonGroupTabBar(
                  selectedIndex: switch (replyController.replySort.value) {
                    ReplySort.hot => 0,
                    ReplySort.oldest => 1,
                    ReplySort.newest => 2,
                  },
                  showLabels: showSortLabels,
                  alignment: AlignmentDirectional.centerStart,
                  items: [
                    FUIButtonGroupTabItem(
                      icon: ForumIcons.hot,
                      label: l10n.postSortByHot,
                      tooltip: l10n.postSortByHot,
                    ),
                    FUIButtonGroupTabItem(
                      icon: ForumIcons.sortAscending,
                      label: l10n.postSortOldest,
                      tooltip: l10n.postSortOldest,
                    ),
                    FUIButtonGroupTabItem(
                      icon: ForumIcons.sortDescending,
                      label: l10n.postSortNewest,
                      tooltip: l10n.postSortNewest,
                    ),
                  ],
                  onSelected: (index) =>
                      replyController.updateReplySort(switch (index) {
                        0 => ReplySort.hot,
                        1 => ReplySort.oldest,
                        _ => ReplySort.newest,
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostDetailHeader extends StatelessWidget {
  final DiscussionSummary item;
  final int replyCount;
  final VoidCallback onReply;

  const _PostDetailHeader({
    required this.item,
    required this.replyCount,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap12,
        FUITokens.pagePadding,
        FUITokens.gap8,
      ),
      child: FuiPageHead(
        title: l10n.postTitlePrefix(item.title),
        subtitle: l10n.postCardReplyCount(replyCount),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FUIIconButton(
              onPressed: onReply,
              tooltip: l10n.postActionComment,
              icon: ForumIcons.reply,
              variant: FUIIconButtonVariant.ghost,
            ),
            if (Platform.isAndroid || Platform.isIOS) ...[
              const SizedBox(width: FUITokens.gap8),
              FUIIconButton(
                onPressed: _onShareClick,
                tooltip: MaterialLocalizations.of(context).shareButtonLabel,
                icon: ForumIcons.share,
                variant: FUIIconButtonVariant.ghost,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onShareClick() async {
    final forumRepo = getIt<ForumRepository>();
    await Share.shareUri(Uri.parse(forumRepo.discussionUrl(item.id)));
  }
}

class _DetailPageReplies extends StatelessWidget {
  final PostPageController controller;
  final DiscussionSummary item;
  final String controllerTag;
  final bool embedded;
  final VoidCallback onReply;

  const _DetailPageReplies({
    required this.controller,
    required this.item,
    required this.controllerTag,
    required this.embedded,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final replyItems = controller.replyItems;
      final newReplyItems = controller.newReplyItems;
      final hasReply = replyItems.isNotEmpty || newReplyItems.isNotEmpty;
      final showReplySkeleton = controller.isReplyLoading.value && !hasReply;
      final replyIndexes = <int, int>{
        for (var i = 0; i < newReplyItems.length; i += 1)
          newReplyItems[i].id: i,
        for (var i = 0; i < replyItems.length; i += 1)
          replyItems[i].id: newReplyItems.length + i,
      };

      return FUIRefresh(
        onLoad: controller.onReplyLoad,
        onRefresh: controller.onReplyRefresh,
        controller: controller.refreshController,
        refreshOnStart: false,
        refreshEnabled: !showReplySkeleton,
        loadEnabled: !showReplySkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showReplySkeleton
              ? const ClampingScrollPhysics()
              : physics;

          return DesktopScrollAccelerator(
            controller: controller.scrollController,
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: effectivePhysics,
              scrollCacheExtent: const ScrollCacheExtent.pixels(320),
              slivers: [
                SliverToBoxAdapter(
                  child: Obx(
                    () => _PostDetailHeader(
                      item: item,
                      replyCount: controller.replyCount.value,
                      onReply: onReply,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: PostMainWidget(content: item, controller: controller),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final totalNew = newReplyItems.length;
                        final reply = index < totalNew
                            ? newReplyItems[index]
                            : replyItems[index - totalNew];
                        return PostItemWidget(
                          key: ValueKey(reply.id),
                          reply: reply,
                          controllerTag: controllerTag,
                        );
                      },
                      childCount: newReplyItems.length + replyItems.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      addSemanticIndexes: false,
                      findChildIndexCallback: (key) =>
                          key is ValueKey<int> ? replyIndexes[key.value] : null,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }
}
