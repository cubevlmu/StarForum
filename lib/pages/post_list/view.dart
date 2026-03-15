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
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage>
    with AutomaticKeepAliveClientMixin {
  late final PostListController controller;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);

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
              ? const ClampingScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              if (showSkeleton)
                const SliverToBoxAdapter(child: _PostListLoadingSkeleton())
              else if (controller.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '🧐',
                    title: AppLocalizations.of(context)!.postListEmptyTitle,
                    tips: AppLocalizations.of(context)!.postListEmptyTips,
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

class _PostListLoadingSkeleton extends StatelessWidget {
  const _PostListLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1450),
      highlightStrength: 0.18,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            4,
            (index) => _PostListLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _PostListLoadingCard extends StatelessWidget {
  const _PostListLoadingCard({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: circleDecoration,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBar(
                            decoration: pillDecoration,
                            widthFactor: 0.28,
                            height: 12,
                          ),
                          const SizedBox(height: 8),
                          SkeletonBar(
                            decoration: pillDecoration,
                            widthFactor: 0.18,
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SkeletonBar(
                  decoration: pillDecoration,
                  widthFactor: 0.9,
                  height: 16,
                ),
                const SizedBox(height: 10),
                SkeletonBar(
                  decoration: pillDecoration,
                  widthFactor: 0.82,
                  height: 12,
                ),
                const SizedBox(height: 8),
                SkeletonBar(
                  decoration: pillDecoration,
                  widthFactor: 0.68,
                  height: 12,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 28,
                      decoration: pillDecoration,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 54,
                      height: 28,
                      decoration: pillDecoration,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
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
