/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/data/sync/sync_status.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/editor/view.dart';
import 'package:star_forum/pages/post_list/controller.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:get/get.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late final PostListController controller;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PostListController>()) {
      controller = Get.find<PostListController>();
      LogUtil.debug('[PostList] Controller reused');
    } else {
      controller = Get.put(PostListController());
      LogUtil.debug('[PostList] Controller created');
    }

    if (controller.items.isEmpty) {
      controller.prepareInitialSync();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.loadInitial();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _PostListView(controller: controller),
      floatingActionButton: _PostListFloatBtn(
        controller: controller,
        onPressed: _onCreateDiscussion,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _onCreateDiscussion() {
    final repo = getIt<UserRepo>();
    if (!repo.isLogin) {
      SnackbarUtils.showError(
        msg: AppLocalizations.of(context)!.authLoginRequired,
      );
      return;
    }
    FuiNavigation.openDetail(
      context,
      builder: (_) => const EditorPage(embedded: true),
    );
  }
}

class _PostListView extends StatelessWidget {
  final PostListController controller;

  const _PostListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final initialSyncing = controller.isInitialSyncing.value;
      return FUIRefresh(
        controller: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        refreshOnStart: false,
        refreshEnabled: !initialSyncing,
        loadTriggerOffset: FUITokens.gap32,
        childBuilder: (context, physics) {
          return CustomScrollView(
            controller: controller.scrollController,
            physics: physics,
            scrollCacheExtent: const ScrollCacheExtent.pixels(320),
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: ForumLayout.cardGap),
              ),
              if (initialSyncing)
                SliverToBoxAdapter(
                  child: _InitialSyncBanner(phase: controller.syncStatus.phase),
                ),
              Obx(() {
                final showSkeleton =
                    controller.isInitialLoading.value &&
                    controller.items.isEmpty;
                if (showSkeleton) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: PostListLoadingSkeleton(),
                  );
                }
                if (controller.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: NoticeWidget(
                      emoji: '🧐',
                      title: AppLocalizations.of(
                        context,
                      )!.commonEmptyPostsTitle,
                      tips: AppLocalizations.of(
                        context,
                      )!.commonPullToRefreshTips,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }),
              Obx(() {
                final items = controller.items;
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return _PostListItem(key: ValueKey(item.id), item: item);
                    },
                    childCount: items.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    addSemanticIndexes: false,
                  ),
                );
              }),
              const SliverToBoxAdapter(
                child: SizedBox(height: FUITokens.gap32),
              ),
            ],
          );
        },
      );
    });
  }
}

class _InitialSyncBanner extends StatelessWidget {
  const _InitialSyncBanner({required this.phase});

  final ValueListenable<SyncPhase> phase;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncPhase>(
      valueListenable: phase,
      builder: (context, value, _) {
        final l10n = AppLocalizations.of(context)!;
        final message = value == SyncPhase.hydrating
            ? l10n.homeFeedSyncingExcerpts
            : l10n.homeFeedSyncingDiscussions;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            ForumLayout.edge,
            0,
            ForumLayout.edge,
            ForumLayout.cardGap,
          ),
          child: FUISurface(
            padding: const EdgeInsets.symmetric(
              horizontal: FUITokens.gap12,
              vertical: FUITokens.gap10,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: FUITokens.gap10),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostListFloatBtn extends StatelessWidget {
  final PostListController controller;
  final VoidCallback? onPressed;

  const _PostListFloatBtn({required this.controller, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWide = mediaQuery.size.width >= 640;
    final bottomInset = mediaQuery.padding.bottom;
    final bottomOffset = isWide
        ? 10.0
        : (bottomInset + 16).clamp(16.0, 40.0).toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: bottomOffset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => controller.showBackToTop.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: FUITokens.gap10),
                    child: FUIIconButton(
                      size: 48,
                      onPressed: controller.animateToTop,
                      tooltip: AppLocalizations.of(context)!.backToTopTooltip,
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
                  onPressed: onPressed,
                  icon: ForumIcons.compose,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostListItem extends StatelessWidget {
  final DiscussionSummary item;

  const _PostListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: ForumLayout.listItemPadding,
        child: PostCard(item: item),
      ),
    );
  }
}
