/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/theme_list/controller.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/widgets/post_card.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
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
            Obx(() {
              if (!controller.onLoading.value) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RefreshProgressIndicator(),
                      SizedBox(height: 8),
                      Text('正在加载...'),
                    ],
                  ),
                ),
              );
            }),

            Obx(() {
              if (controller.onLoading.value ||
                  controller.searchItems.isNotEmpty ||
                  controller.isSearching.value) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return const SliverFillRemaining(
                hasScrollBody: false,
                child: NoticeWidget(
                  emoji: '🧐',
                  title: '这里还没有任何帖子',
                  tips: '下拉刷新试试看',
                ),
              );
            }),

            Obx(() {
              final items = controller.searchItems;
              if (items.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverPrototypeExtentList(
                prototypeItem: _ThemeListItem(item: items.first.toItem()),
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
