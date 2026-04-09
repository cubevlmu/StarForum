import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/subscription/controller.dart';
import 'package:star_forum/widgets/discussion_list_item_card.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';

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
    if (homeController.isLogin.value) {
      _ensureController();
    }
  }

  SubscriptionController _ensureController() {
    final existing = _controller;
    if (existing != null) {
      return existing;
    }
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
              SliverToBoxAdapter(
                child: _SubscriptionToolbar(controller: controller),
              ),
              const SliverToBoxAdapter(child: Divider(height: 1)),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = controller.items[index];
                    return _FollowingListItem(item: item);
                  }, childCount: controller.items.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      );
    });
  }
}

class _SubscriptionToolbar extends StatelessWidget {
  const _SubscriptionToolbar({required this.controller});

  final SubscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<FollowingSort>(
              initialValue: controller.sort.value,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: l10n.homeFollowingSort,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: FollowingSort.hottest,
                  child: Text(
                    l10n.homeFollowingSortHottest,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: FollowingSort.latestReply,
                  child: Text(
                    l10n.homeFollowingSortLatestReply,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: FollowingSort.newest,
                  child: Text(
                    l10n.homeFollowingSortNewest,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: FollowingSort.oldest,
                  child: Text(
                    l10n.homeFollowingSortOldest,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: FollowingSort.mostViews,
                  child: Text(
                    l10n.homeFollowingSortMostViews,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (next) {
                if (next != null) {
                  controller.updateSort(next);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: 'posts',
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: l10n.homeFollowingFilter,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'posts',
                  child: Text(
                    l10n.homeFollowingFilterPosts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'tags',
                  enabled: false,
                  child: Text(
                    l10n.homeFollowingFilterTags,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowingListItem extends StatelessWidget {
  const _FollowingListItem({required this.item});

  final DiscussionInfo item;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openDiscussionAdaptive(context, item.toItem()),
            child: DiscussionListItemCard(discussion: item),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
