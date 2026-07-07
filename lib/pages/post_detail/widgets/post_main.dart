/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/content_view.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:get/get.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/widgets/forum/forum_user_avatar.dart';

class PostMainWidget extends StatelessWidget {
  final DiscussionItem content;
  final PostPageController controller;

  const PostMainWidget({
    super.key,
    required this.content,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap6,
        FUITokens.pagePadding,
        FUITokens.gap2,
      ),
      child: FUISurface(
        borderRadius: FUITokens.radiusXl,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: FUITokens.gap10),
                  // Author info
                  _UserBox(item: content, controller: controller),
                  const SizedBox(height: FUITokens.gap10),
                  // Content
                  _MainContent(item: content, controller: controller),
                ],
              ),
            ),
            // Divider + action bar
            Obx(() {
              final info = controller.firstPost.value;
              final like = info?.likes ?? -1;
              final canInteract = controller.canUseInteractiveActions;
              if (like == -1) return const SizedBox.shrink();
              return Column(
                children: [
                  Container(height: 1, color: colors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FUITokens.gap8,
                      vertical: FUITokens.gap6,
                    ),
                    child: Row(
                      children: [
                        _LikeButton(
                          enabled: canInteract,
                          likeCount: info?.likes ?? 0,
                          isLiked: info?.isLiked ?? false,
                          onPressed: info == null
                              ? null
                              : () async {
                                  final r = await ReplyUtil.addLikeToPost(info);
                                  if (r != null) {
                                    info.likes = r.likes;
                                    info.isLiked = r.isLiked;
                                    controller.firstPost.refresh();
                                  }
                                },
                        ),
                        const SizedBox(width: FUITokens.gap8),
                        _FollowButton(controller: controller),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _UserBox extends StatelessWidget {
  const _UserBox({required this.item, required this.controller});
  final DiscussionItem item;
  final PostPageController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final firstPost = controller.firstPost.value;
      final user = firstPost?.user;
      final userId = firstPost?.userId ?? item.userId;
      final authorName = UserInfo.displayLabel(
        user,
        fallbackId: userId,
        fallback: item.authorName.trim(),
      );
      final avatarUrl = (user?.avatarUrl.trim().isNotEmpty == true)
          ? user!.avatarUrl
          : item.authorAvatar;
      final canOpenUser = userId > 0;

      return GestureDetector(
        onTap: canOpenUser
            ? () => FuiNavigation.openDetail(
                context,
                builder: (_) => UserPage(userId: userId, embedded: true),
              )
            : null,
        child: MouseRegion(
          cursor: canOpenUser
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Row(
            children: [
              ForumUserAvatar(name: authorName, avatarUrl: avatarUrl, size: 40),
              const SizedBox(width: FUITokens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: TextStyle(
                        color: canOpenUser
                            ? colors.primary
                            : colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ForumMetaRow(
                      items: [
                        ForumMetaItem(
                          icon: FUIIcons.schedule,
                          label: StringUtil.dateTimeToAgoDate(
                            item.lastPostedAt,
                          ),
                        ),
                        ForumMetaItem(
                          icon: Icons.visibility_outlined,
                          label: StringUtil.numFormat(
                            controller.viewCount.value == 0
                                ? item.viewCount
                                : controller.viewCount.value,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({required this.item, required this.controller});
  final DiscussionItem item;
  final PostPageController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SelectionArea(
      child: RepaintBoundary(
        child: Obx(() {
          final content = controller.content.value;
          final isLoading = content == l10n.postContentLoadingHtml;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isLoading
                ? const _MainContentLoadingSkeleton()
                : ContentView(
                    key: ValueKey(content.hashCode),
                    content: content,
                  ),
          );
        }),
      ),
    );
  }
}

class _MainContentLoadingSkeleton extends StatelessWidget {
  const _MainContentLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('main-content-loading'),
      constraints: const BoxConstraints(minHeight: 228),
      child: SkeletonShimmer(
        duration: const Duration(milliseconds: 1350),
        highlightStrength: 0.36,
        builder: (context, palette) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.92,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.88,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.95,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.66,
                height: 14,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                height: 110,
                decoration: palette.block(),
              ),
              const SizedBox(height: 16),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.9,
                height: 14,
              ),
              const SizedBox(height: 10),
              SkeletonBar(
                decoration: palette.line(),
                widthFactor: 0.58,
                height: 14,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton({
    required this.enabled,
    required this.likeCount,
    required this.isLiked,
    this.onPressed,
  });
  final bool enabled;
  final int likeCount;
  final bool isLiked;
  final Future<void> Function()? onPressed;

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _loading = false;

  Future<void> _handlePressed() async {
    if (!widget.enabled || widget.onPressed == null || _loading) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liked = widget.isLiked;
    final count = widget.likeCount;
    final label = count > 0
        ? '${AppLocalizations.of(context)!.commonLike}  $count'
        : AppLocalizations.of(context)!.commonLike;
    return FUIButton(
      label: label,
      icon: liked ? ForumIcons.likeFilled : ForumIcons.like,
      variant: liked ? FUIButtonVariant.primary : FUIButtonVariant.secondary,
      small: true,
      loading: _loading,
      onPressed: widget.enabled ? _handlePressed : null,
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.controller});
  final PostPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.subscription.value == 1;
      final updating = controller.isFollowUpdating.value;
      final enabled = controller.canUseInteractiveActions;
      return FUIButton(
        label: selected
            ? AppLocalizations.of(context)!.postActionUnfollow
            : AppLocalizations.of(context)!.postActionFollow,
        icon: selected ? ForumIcons.bookmarkFilled : ForumIcons.bookmark,
        variant: selected
            ? FUIButtonVariant.primary
            : FUIButtonVariant.secondary,
        small: true,
        loading: updating,
        onPressed: (!enabled || updating)
            ? null
            : controller.toggleDiscussionFollow,
      );
    });
  }
}
