part of '../view.dart';

class _UserTopicsSection extends StatelessWidget {
  const _UserTopicsSection({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.topics;
      final showSkeleton = controller.isTopicsLoading.value && items.isEmpty;

      return SimpleEasyRefresher(
        easyRefreshController: controller.topicsRefreshController,
        onRefresh: controller.onTopicsRefresh,
        onLoad: controller.onTopicsLoad,
        autoRefreshOnStart: false,
        refreshEnabled: !showSkeleton,
        loadEnabled: !showSkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showSkeleton
              ? const ClampingScrollPhysics()
              : physics;

          return CustomScrollView(
            controller: controller.topicsScrollController,
            physics: effectivePhysics,
            cacheExtent: 320,
            slivers: [
              if (showSkeleton)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: PostListLoadingSkeleton(minItems: 3, maxItems: 6),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    child: NoticeWidget(
                      emoji: "📝",
                      title: AppLocalizations.of(
                        context,
                      )!.commonEmptyPostsTitle,
                      tips: AppLocalizations.of(
                        context,
                      )!.commonPullToRefreshTips,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final discussion = items[index];
                      return RepaintBoundary(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => openDiscussionAdaptive(
                                context,
                                discussion.toItem(),
                              ),
                              child: DiscussionListItemCard(
                                discussion: discussion,
                              ),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 12,
                              endIndent: 12,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: items.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
            ],
          );
        },
      );
    });
  }
}
