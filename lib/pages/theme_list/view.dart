/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/theme_list/controller.dart';
import 'package:forum/widgets/post_card.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class ThemeListPage extends StatefulWidget {
  const ThemeListPage({super.key});

  @override
  State<ThemeListPage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemeListPage> {
  late final ThemeListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ThemeListController());
  }

  @override
  void dispose() {
    Get.delete<ThemeListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.onRefresh,
        onLoad: controller.onLoad,
        childBuilder: (context, physics) {
          return CustomScrollView(
            controller: controller.scrollController,
            physics: physics,
            slivers: [_buildPostListSliver()],
          );
        },
      ),
      bottomNavigationBar: _buildBadgeBar(),
    );
  }

  Widget _buildBadgeBar() {
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

  Widget _buildPostListSliver() {
    return Obx(() {
      if (controller.onLoading.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RefreshProgressIndicator(),
                SizedBox(height: 8),
                Text("正在加载..."),
              ],
            ),
          ),
        );
      }
      if (controller.searchItems.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Obx(() {
            return controller.isSearching.value
                ? const SizedBox.shrink()
                : const NoticeWidget(
                    emoji: "🧐",
                    title: "这里还没有任何帖子",
                    tips: "下拉刷新试试看",
                  );
          }),
        );
      } else {
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final i = controller.searchItems[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PostCard(item: i.toItem()),
                ),
                if (index != controller.searchItems.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 12,
                    endIndent: 12,
                  ),
              ],
            );
          }, childCount: controller.searchItems.length),
        );
      }
    });
  }
}
