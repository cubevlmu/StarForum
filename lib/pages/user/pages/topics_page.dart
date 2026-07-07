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
            scrollCacheExtent: const ScrollCacheExtent.pixels(320),
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
                      emoji: '📝',
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
                      final excerpt = htmlToPlainText(
                        discussion.firstPost?.contentHtml ?? '',
                      ).trim();
                      final tags = discussion.tags
                          .take(3)
                          .map((t) => t.name)
                          .toList();
                      return RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ForumLayout.edge,
                            ForumLayout.cardGap,
                            ForumLayout.edge,
                            ForumLayout.cardGap,
                          ),
                          child: ForumDiscussionTile(
                            title: discussion.title,
                            excerpt: excerpt.isEmpty ? null : excerpt,
                            author: discussion.user?.displayName,
                            avatarUrl: discussion.user?.avatarUrl,
                            tags: tags,
                            meta: [
                              ForumMetaItem(
                                icon: Icons.schedule_outlined,
                                label: StringUtil.dateTimeToAgoDate(
                                  discussion.lastPostedAt,
                                ),
                              ),
                            ],
                            replyCount: discussion.commentCount > 0
                                ? discussion.commentCount - 1
                                : 0,
                            onTap: () => FuiNavigation.openDetail(
                              context,
                              builder: (_) => PostPage(
                                item: discussion.toItem(),
                                embedded: true,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: items.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      );
    });
  }
}
