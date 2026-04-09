/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/theme_list/controller.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage>
    with AutomaticKeepAliveClientMixin {
  late final TagListController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<TagListController>()) {
      controller = Get.find<TagListController>();
      LogUtil.debug('[TagPage] Controller reused');
    } else {
      controller = Get.put(TagListController());
      LogUtil.debug('[TagPage] Controller created');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.mainTagsPage)),
      body: _TagListView(controller: controller),
    );
  }
}

class _TagListView extends StatelessWidget {
  final TagListController controller;

  const _TagListView({required this.controller});

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
              ? const NeverScrollableScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              SliverToBoxAdapter(child: _TagListTopBar(controller: controller)),
              if (showSkeleton)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: PostListLoadingSkeleton(),
                )
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
                    title: l10n.commonEmptyPostsTitle,
                    tips: l10n.commonPullToRefreshTips,
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
                    return _TagListItem(item: items[index].toItem());
                  }, childCount: items.length),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      );
    });
  }
}

class _TagListItem extends StatelessWidget {
  final DiscussionItem item;

  const _TagListItem({required this.item});

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

class _TagListTopBar extends StatelessWidget {
  final TagListController controller;

  const _TagListTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        height: 53,
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          child: Obx(
            () => ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
      ),
    );
  }
}
