part of '../view.dart';

class _UserTopicsSection extends StatelessWidget {
  const _UserTopicsSection({required this.controller});

  final UserTopicsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;
      final showSkeleton = controller.isLoading.value && items.isEmpty;

      return FUIRefresh(
        controller: controller.refreshController,
        onRefresh: controller.refresh,
        onLoad: controller.loadMore,
        refreshOnStart: false,
        refreshEnabled: !showSkeleton,
        loadEnabled: !showSkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showSkeleton
              ? const ClampingScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
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
                      final excerpt = discussion.excerpt.trim();
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
                            author: discussion.authorName,
                            avatarUrl: discussion.authorAvatar,
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
                              builder: (_) =>
                                  PostPage(item: discussion, embedded: true),
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
