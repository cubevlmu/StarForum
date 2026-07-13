/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/subscription/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/widgets/forum/forum_discussion_tile.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shared_notice.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  static const _tag = 'home_following';
  late final HomeController homeController;
  SubscriptionController? _controller;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    if (homeController.isLogin.value) _ensureController();
  }

  SubscriptionController _ensureController() {
    final existing = _controller;
    if (existing != null) return existing;
    final created = Get.isRegistered<SubscriptionController>(tag: _tag)
        ? Get.find<SubscriptionController>(tag: _tag)
        : Get.put(SubscriptionController(), tag: _tag);
    _controller = created;
    return created;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      if (!homeController.isLogin.value) {
        return NotLoginNotice(
          title: l10n.commonNotLoggedInTitle,
          tipsText: l10n.homeFollowingNotLoginTips,
        );
      }

      final controller = _ensureController();
      final showSkeleton =
          (controller.isInitialLoading.value ||
              controller.isCriteriaLoading.value) &&
          controller.items.isEmpty;

      return FUIRefresh(
        controller: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        refreshOnStart: false,
        refreshEnabled: !showSkeleton,
        loadEnabled: !showSkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showSkeleton
              ? const NeverScrollableScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              SliverToBoxAdapter(child: _SortBar(controller: controller)),
              if (showSkeleton)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: PostListLoadingSkeleton(),
                )
              else if (controller.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '⭐',
                    title: l10n.homeSectionFollowing,
                    tips: l10n.commonPullToRefreshTips,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _FollowingItem(item: controller.items[index]),
                    childCount: controller.items.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      );
    });
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.controller});

  final SubscriptionController controller;

  static const _options = [
    DiscussionFollowingSort.hottest,
    DiscussionFollowingSort.latestReply,
    DiscussionFollowingSort.newest,
    DiscussionFollowingSort.oldest,
    DiscussionFollowingSort.mostViews,
  ];

  String _label(BuildContext context, DiscussionFollowingSort s) {
    final l10n = AppLocalizations.of(context)!;
    return switch (s) {
      DiscussionFollowingSort.hottest => l10n.homeFollowingSortHottest,
      DiscussionFollowingSort.latestReply => l10n.homeFollowingSortLatestReply,
      DiscussionFollowingSort.newest => l10n.homeFollowingSortNewest,
      DiscussionFollowingSort.oldest => l10n.homeFollowingSortOldest,
      DiscussionFollowingSort.mostViews => l10n.homeFollowingSortMostViews,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ForumLayout.edge,
        FUITokens.gap10,
        ForumLayout.edge,
        FUITokens.gap4,
      ),
      child: FUISurface(
        padding: const EdgeInsets.symmetric(
          horizontal: FUITokens.gap14,
          vertical: FUITokens.gap8,
        ),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.homeFollowingSort,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Obx(
              () => _PopupPicker<DiscussionFollowingSort>(
                value: controller.sort.value,
                options: _options,
                labelOf: (s) => _label(context, s),
                onChanged: controller.updateSort,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupPicker<T> extends StatelessWidget {
  const _PopupPicker({
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FUITokens.radiusLg),
        side: BorderSide(color: colors.border),
      ),
      color: colors.surface,
      elevation: 2,
      itemBuilder: (_) => [
        for (final opt in options)
          PopupMenuItem<T>(
            value: opt,
            child: Text(
              labelOf(opt),
              style: TextStyle(
                color: opt == value ? colors.primary : colors.textPrimary,
                fontWeight: opt == value ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelOf(value),
            style: TextStyle(
              color: colors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: FUITokens.gap4),
          Icon(Icons.expand_more_rounded, size: 16, color: colors.primary),
        ],
      ),
    );
  }
}

class _FollowingItem extends StatelessWidget {
  const _FollowingItem({required this.item});

  final DiscussionSummary item;

  @override
  Widget build(BuildContext context) {
    final excerpt = item.excerpt.trim();
    final tags = item.tags.take(3).map((t) => t.name).toList();
    return RepaintBoundary(
      child: Padding(
        padding: ForumLayout.listItemPadding,
        child: ForumDiscussionTile(
          title: item.title,
          excerpt: excerpt.isEmpty ? null : excerpt,
          author: item.authorName,
          avatarUrl: item.authorAvatar,
          tags: tags,
          meta: [
            ForumMetaItem(
              icon: Icons.schedule_outlined,
              label: StringUtil.dateTimeToAgoDate(item.lastPostedAt),
            ),
          ],
          replyCount: item.commentCount > 0 ? item.commentCount - 1 : 0,
          unread: item.subscription == 1,
          onTap: () => FuiNavigation.openDetail(
            context,
            builder: (_) => PostPage(item: item, embedded: true),
          ),
        ),
      ),
    );
  }
}
