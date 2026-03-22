part of '../view.dart';

class _UserCommentsSection extends StatelessWidget {
  const _UserCommentsSection({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.comments;
      final showSkeleton = controller.isCommentsLoading.value && items.isEmpty;

      return SimpleEasyRefresher(
        easyRefreshController: controller.commentsRefreshController,
        onRefresh: controller.onCommentsRefresh,
        onLoad: controller.onCommentsLoad,
        autoRefreshOnStart: false,
        refreshEnabled: !showSkeleton,
        loadEnabled: !showSkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showSkeleton
              ? const ClampingScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.commentsScrollController,
            physics: effectivePhysics,
            cacheExtent: 320,
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
                      emoji: "🧐",
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
                          controller.commentDiscussions[item.discussion];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
                            child: _DiscussionHint(
                              title: discussion?.title ?? "",
                              onTap: () async {
                                if (controller.isLoading.value) return;
                                final result = await controller.naviToDisPage(
                                  item.discussion,
                                );
                                if (result == null) return;
                                if (!context.mounted) return;
                                openDiscussionAdaptive(context, result);
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: PostItemWidget(reply: item, isUserPage: true),
                          ),
                          const SizedBox(height: 5),
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 12,
                            endIndent: 12,
                          ),
                        ],
                      );
                    },
                    childCount: items.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
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

class _DiscussionHint extends StatelessWidget {
  const _DiscussionHint({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.userDiscussionHintPrefix,
            style: style?.copyWith(color: Colors.grey),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
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
          children: List<Widget>.generate(
            3,
            (index) => _UserPostLoadingCard(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
          child: SkeletonBar(
            decoration: pillDecoration,
            widthFactor: 0.42,
            height: 12,
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 45, height: 45, decoration: circleDecoration),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.3,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.22,
                      height: 10,
                    ),
                    const SizedBox(height: 14),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.95,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.86,
                      height: 12,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.6,
                      height: 12,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 32,
                          decoration: pillDecoration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
      ],
    );
  }
}
