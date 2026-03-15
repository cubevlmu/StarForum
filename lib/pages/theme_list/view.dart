/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/theme_list/controller.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class ThemeListPage extends StatefulWidget {
  const ThemeListPage({super.key});

  @override
  State<ThemeListPage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemeListPage>
    with AutomaticKeepAliveClientMixin {
  late final ThemeListController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<ThemeListController>()) {
      controller = Get.find<ThemeListController>();
      LogUtil.debug('[ThemePage] Controller reused');
    } else {
      controller = Get.put(ThemeListController());
      LogUtil.debug('[ThemePage] Controller created');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: _ThemeListView(controller: controller),
      bottomNavigationBar: _ThemeListBottomBar(controller: controller),
    );
  }
}

class _ThemeListView extends StatelessWidget {
  final ThemeListController controller;

  const _ThemeListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final showSkeleton =
          controller.onLoading.value && controller.searchItems.isEmpty;
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
                const SliverToBoxAdapter(child: _ThemeListLoadingSkeleton())
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),

              Obx(() {
                if (controller.searchItems.isNotEmpty ||
                    controller.isSearching.value ||
                    controller.onLoading.value) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '🧐',
                    title: l10n.postListEmptyTitle,
                    tips: l10n.postListEmptyTips,
                  ),
                );
              }),

              Obx(() {
                final items = controller.searchItems;
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _ThemeListItem(item: items[index].toItem());
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

class _ThemeListLoadingSkeleton extends StatelessWidget {
  const _ThemeListLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1450),
      highlightStrength: 0.18,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            4,
            (index) => _ThemeListLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeListLoadingCard extends StatelessWidget {
  const _ThemeListLoadingCard({
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

class _ThemeListItem extends StatelessWidget {
  final DiscussionItem item;

  const _ThemeListItem({required this.item});

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

class _ThemeListBottomBar extends StatelessWidget {
  final ThemeListController controller;

  const _ThemeListBottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 45,
        child: Obx(
          () => ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.primayTag.length + controller.tags.length,
            itemBuilder: (context, index) {
              final item = index < controller.primayTag.length
                  ? controller.primayTag[index]
                  : controller.tags[index - controller.primayTag.length];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Obx(
                  () => ChoiceChip(
                    label: Text(item.name),
                    selected: controller.selectId.value == item.id,
                    onSelected: controller.onLoading.value
                        ? null
                        : (selected) {
                            if (selected) {
                              controller.onTagSelectChange(item.id);
                            }
                          },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
