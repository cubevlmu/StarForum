/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
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
import 'package:star_forum/widgets/simple_easy_refresher.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.onRefresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _PostListView(controller: controller),
      floatingActionButton: _PostListFloatBtn(onPressed: _onCreateDiscussion),
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
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      autoRefreshOnStart: false,
      childBuilder: (context, physics) {
        return CustomScrollView(
          controller: controller.scrollController,
          physics: physics,
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: ForumLayout.cardGap),
            ),
            const SliverToBoxAdapter(child: _SyncStatusBanner()),
            Obx(() {
              final showSkeleton =
                  controller.isInitialLoading.value && controller.items.isEmpty;
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
                    title: AppLocalizations.of(context)!.commonEmptyPostsTitle,
                    tips: AppLocalizations.of(context)!.commonPullToRefreshTips,
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
                  addRepaintBoundaries: true,
                  addSemanticIndexes: false,
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

class _SyncStatusBanner extends StatelessWidget {
  const _SyncStatusBanner();

  @override
  Widget build(BuildContext context) {
    final syncStatus = getIt<SyncStatusService>();
    return Obx(() {
      if (!syncStatus.isBusy) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          FUITokens.pagePadding,
          0,
          FUITokens.pagePadding,
          ForumLayout.cardGap,
        ),
        child: FUISurface(
          padding: const EdgeInsets.symmetric(
            horizontal: FUITokens.gap12,
            vertical: FUITokens.gap8,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              Expanded(
                child: Text(
                  syncStatus.message.value,
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
    });
  }
}

class _PostListFloatBtn extends StatelessWidget {
  final VoidCallback? onPressed;

  const _PostListFloatBtn({required this.onPressed});

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
      child: FloatingActionButton(
        heroTag: null,
        onPressed: onPressed,
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
        child: const Icon(ForumIcons.compose),
      ),
    );
  }
}

class _PostListItem extends StatelessWidget {
  final DiscussionItem item;

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
