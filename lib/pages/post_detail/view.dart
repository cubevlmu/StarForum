/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/post_detail/widgets/post_main.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fin_ui/fin_ui.dart';

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
    if (Get.isRegistered<PostPageController>(tag: controllerTag)) {
      controller = Get.find<PostPageController>(tag: controllerTag);
    } else {
      controller = Get.put(
        PostPageController(discussion: widget.item),
        tag: controllerTag,
      );
    }
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
      body: SafeArea(bottom: false, child: body),
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
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.textInverse,
      focusColor: context.colors.primaryHover,
      hoverColor: context.colors.primaryHover,
      splashColor: context.colors.primaryPressed,
      elevation: 2,
      hoverElevation: 3,
      highlightElevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FUITokens.radiusLg),
      ),
      child: const Icon(ForumIcons.reply),
    );
  }
}

class _SortReplyItemWidget extends StatelessWidget {
  const _SortReplyItemWidget({required this.replyController});
  final PostPageController replyController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap10,
        FUITokens.pagePadding,
        FUITokens.gap4,
      ),
      child: FUISurface(
        padding: const EdgeInsets.symmetric(
          horizontal: FUITokens.gap14,
          vertical: FUITokens.gap8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.postReplyPrefix(
                  StringUtil.ensureNotNegative(
                    replyController.discussion.commentCount - 1,
                  ),
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Obx(
              () => Text(
                replyController.sortTypeText.value,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: FUITokens.gap6),
            FUIIconButton(
              icon: Icons.sort_rounded,
              variant: FUIIconButtonVariant.outline,
              onPressed: replyController.toggleSort,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostDetailHeader extends StatelessWidget {
  final DiscussionItem item;
  final VoidCallback onReply;

  const _PostDetailHeader({required this.item, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap12,
        FUITokens.pagePadding,
        FUITokens.gap8,
      ),
      child: FuiPageHead(
        title: AppLocalizations.of(context)!.postTitlePrefix(item.title),
        subtitle: '${StringUtil.ensureNotNegative(item.commentCount - 1)} 回复',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FUIIconButton(
              onPressed: onReply,
              tooltip: AppLocalizations.of(context)!.postActionComment,
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
  final DiscussionItem item;
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
                child: _PostDetailHeader(item: item, onReply: onReply),
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
