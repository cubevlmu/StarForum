/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_list/controller.dart';
import 'package:star_forum/pages/post_list/create_discuss_util.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
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
      body: _PostListView(controller: controller),
      floatingActionButton: _PostListFloatBtn(onPressed: _onCreateDiscussion),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _onCreateDiscussion() {
    CreateDiscussUtil.showCreateDiscuss(
      context: context,
      updateWidget: () => controller.items.refresh(),
      scrollController: controller.scrollController,
    );
  }
}

class _PostListView extends StatelessWidget {
  final PostListController controller;

  const _PostListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showSkeleton =
          controller.isInitialLoading.value && controller.items.isEmpty;
      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        autoRefreshOnStart: false,
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
              if (showSkeleton)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: PostListLoadingSkeleton(),
                )
              else if (controller.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '🧐',
                    title: AppLocalizations.of(context)!.commonEmptyPostsTitle,
                    tips: AppLocalizations.of(context)!.commonPullToRefreshTips,
                  ),
                )
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),
              Obx(() {
                final items = controller.items;
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _PostListItem(item: items[index]);
                  }, childCount: items.length),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
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
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}

class _PostListItem extends StatelessWidget {
  final DiscussionItem item;

  const _PostListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PostCard(item: item),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
