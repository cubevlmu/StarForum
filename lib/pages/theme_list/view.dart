import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/theme_list/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';

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
    controller = Get.isRegistered<TagListController>()
        ? Get.find<TagListController>()
        : Get.put(TagListController());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: ColoredBox(
        color: context.colors.background,
        child: Obx(() {
          if (controller.isLoading.value && controller.tags.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.tags.isEmpty) {
            return FUIEmptyState(
              title: l10n.mainTagsPage,
              message: l10n.commonPullToRefreshTips,
              icon: ForumIcons.tags,
              actionLabel: l10n.refreshPullToRefresh,
              onAction: controller.reloadTags,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.reloadTags,
            child: CustomScrollView(
              key: const PageStorageKey('tag-directory'),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ForumLayout.pageHeadPadding,
                    child: FuiPageHead(
                      showNavigation: false,
                      title: l10n.mainTagsPage,
                      subtitle: '浏览全部标签，选择感兴趣的分类查看介绍和最新讨论。',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    ForumLayout.edge,
                    ForumLayout.cardGap,
                    ForumLayout.edge,
                    FUITokens.gap24,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 142,
                          mainAxisSpacing: ForumLayout.sectionGap,
                          crossAxisSpacing: ForumLayout.sectionGap,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TagDirectoryCard(
                        tag: controller.tags[index],
                        color: _tagColor(
                          controller.tags[index],
                          context,
                          index,
                        ),
                        onTap: () => FuiNavigation.openDetail(
                          context,
                          builder: (_) => TagDetailPage(
                            tag: controller.tags[index],
                            embedded: true,
                          ),
                        ),
                      ),
                      childCount: controller.tags.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TagDirectoryCard extends StatelessWidget {
  const _TagDirectoryCard({
    required this.tag,
    required this.color,
    required this.onTap,
  });

  final TagInfo tag;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(FUITokens.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FUITokens.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FUITokens.radiusXl),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(FUITokens.radiusSm),
                    ),
                    child: Icon(Icons.tag_rounded, color: color, size: 20),
                  ),
                  const Spacer(),
                  Icon(FUIIcons.chevronRight, color: color, size: 20),
                ],
              ),
              const Spacer(),
              Text(
                tag.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tag.description.trim().isEmpty
                    ? '${tag.discussionCount} 个讨论'
                    : tag.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagDetailPage extends StatefulWidget {
  const TagDetailPage({
    super.key,
    required this.tag,
    this.embedded = false,
    this.onBack,
  });

  final TagInfo tag;
  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  late final String _controllerTag;
  late final TagDetailController controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'TagDetail:${widget.tag.id}:${identityHashCode(this)}';
    controller = Get.put(TagDetailController(widget.tag), tag: _controllerTag);
  }

  @override
  void dispose() {
    if (Get.isRegistered<TagDetailController>(tag: _controllerTag)) {
      Get.delete<TagDetailController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _tagColor(widget.tag, context, widget.tag.id);
    final body = SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      autoRefreshOnStart: false,
      childBuilder: (context, physics) => Obx(() {
        final loading =
            controller.isInitialLoading.value && controller.items.isEmpty;
        return CustomScrollView(
          controller: controller.scrollController,
          physics: loading ? const NeverScrollableScrollPhysics() : physics,
          slivers: [
            SliverToBoxAdapter(
              child: _TagDetailHeader(
                tag: widget.tag,
                color: color,
                onBack: widget.onBack ?? () => Navigator.maybePop(context),
              ),
            ),
            if (loading)
              const SliverToBoxAdapter(child: PostListLoadingSkeleton())
            else if (controller.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: NoticeWidget(
                  emoji: '🏷️',
                  title: l10n.commonEmptyPostsTitle,
                  tips: l10n.commonPullToRefreshTips,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: ForumLayout.listItemPadding,
                    child: PostCard(item: controller.items[index].toItem()),
                  ),
                  childCount: controller.items.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
    return Scaffold(
      backgroundColor: context.colors.background,
      body: widget.embedded ? body : SafeArea(bottom: false, child: body),
    );
  }
}

class _TagDetailHeader extends StatelessWidget {
  const _TagDetailHeader({
    required this.tag,
    required this.color,
    required this.onBack,
  });

  final TagInfo tag;
  final Color color;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ForumLayout.pageHeadPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FuiPageHead(
            title: tag.name,
            subtitle: '${tag.discussionCount} 个讨论',
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(FUITokens.radiusMd),
              ),
              child: Icon(Icons.tag_rounded, color: color),
            ),
          ),
          if (tag.description.trim().isNotEmpty) ...[
            const SizedBox(height: FUITokens.gap8),
            Text(
              tag.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _tagColor(TagInfo tag, BuildContext context, int index) {
  final raw = tag.color.trim().replaceFirst('#', '');
  if (raw.length == 6 || raw.length == 8) {
    final parsed = int.tryParse(raw, radix: 16);
    if (parsed != null) {
      return Color(raw.length == 6 ? 0xFF000000 | parsed : parsed);
    }
  }
  final palette = <Color>[
    context.colors.primary,
    context.colors.success,
    context.colors.warning,
    context.colors.danger,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.orange,
  ];
  return palette[index.abs() % palette.length];
}
