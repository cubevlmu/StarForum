part of '../view.dart';

class _UserCommentsSection extends StatelessWidget {
  const _UserCommentsSection({required this.controller});

  final UserRepliesController controller;

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
                const SliverToBoxAdapter(child: _UserPostListLoadingSkeleton())
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    child: NoticeWidget(
                      emoji: '🧐',
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
                      final item = items[index];
                      final discussion =
                          controller.discussions[item.discussion];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DiscussionHint(
                            title: discussion?.title ?? '',
                            onTap: () async {
                              if (controller.isOpeningDiscussion.value) return;
                              final result = await controller.openDiscussion(
                                item.discussion,
                              );
                              if (result == null) return;
                              if (!context.mounted) return;
                              FuiNavigation.openDetail(
                                context,
                                builder: (_) =>
                                    PostPage(item: result, embedded: true),
                              );
                            },
                          ),
                          PostItemWidget(reply: item, isUserPage: true),
                        ],
                      );
                    },
                    childCount: items.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
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

class _DiscussionHint extends StatelessWidget {
  const _DiscussionHint({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap10,
        FUITokens.pagePadding,
        FUITokens.gap4,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(ForumIcons.reply, size: 13, color: colors.textTertiary),
            const SizedBox(width: FUITokens.gap6),
            Text(
              AppLocalizations.of(context)!.userDiscussionHintPrefix,
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
            const SizedBox(width: FUITokens.gap4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserPostListLoadingSkeleton extends StatelessWidget {
  const _UserPostListLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1420),
      highlightStrength: 0.2,
      builder: (context, palette) {
        return Column(
          children: List.generate(
            3,
            (_) => _UserPostLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _UserPostLoadingCard extends StatelessWidget {
  const _UserPostLoadingCard({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FUITokens.pagePadding,
            FUITokens.gap10,
            FUITokens.pagePadding,
            FUITokens.gap4,
          ),
          child: SkeletonBar(
            decoration: pillDecoration,
            widthFactor: 0.42,
            height: 12,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FUITokens.pagePadding,
            FUITokens.gap4,
            FUITokens.pagePadding,
            FUITokens.gap4,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(FUITokens.radiusLg),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.all(FUITokens.gap12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 36, height: 36, decoration: circleDecoration),
                const SizedBox(width: FUITokens.gap10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBar(
                        decoration: pillDecoration,
                        widthFactor: 0.3,
                        height: 13,
                      ),
                      const SizedBox(height: FUITokens.gap8),
                      SkeletonBar(
                        decoration: pillDecoration,
                        widthFactor: 0.95,
                        height: 12,
                      ),
                      const SizedBox(height: 6),
                      SkeletonBar(
                        decoration: pillDecoration,
                        widthFactor: 0.8,
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
