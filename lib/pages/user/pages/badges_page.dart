part of '../view.dart';

class _UserBadgesSection extends StatelessWidget {
  const _UserBadgesSection({required this.controller});

  final UserPageController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final badges = controller.badges;
      if (controller.isBadgesLoading.value && badges.isEmpty) {
        return const _UserBadgeLoadingSkeleton();
      }

      if (badges.isEmpty) {
        return NoticeWidget(
          emoji: '🏅',
          title: l10n.badgePageEmptyTitle,
          tips: l10n.badgePageEmptyTips,
        );
      }

      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              FUITokens.pagePadding,
              FUITokens.gap8,
              FUITokens.pagePadding,
              MediaQuery.paddingOf(context).bottom + FUITokens.gap24,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: FUITokens.gap10,
                crossAxisSpacing: FUITokens.gap10,
                mainAxisExtent: 126,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _UserBadgeCard(userBadge: badges[index]),
                childCount: badges.length,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _UserBadgeLoadingSkeleton extends StatelessWidget {
  const _UserBadgeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return TwoColumnLoadingSkeleton(
      cardHeight: 126,
      itemBuilder: (context, palette) => SizedBox(
        height: 126,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(FUITokens.radiusLg),
            border: Border.all(color: context.colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FUITokens.gap12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 96,
                  height: 24,
                  decoration: palette.line(radius: 999),
                ),
                const SizedBox(height: FUITokens.gap32),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: palette.block(radius: FUITokens.radiusSm),
                ),
                const SizedBox(height: FUITokens.gap6),
                FractionallySizedBox(
                  widthFactor: 0.68,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 12,
                    decoration: palette.block(radius: FUITokens.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      reservedHeight: 126,
      maxRows: 4,
    );
  }
}

class _UserBadgeCard extends StatelessWidget {
  const _UserBadgeCard({required this.userBadge});

  final UserBadge userBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badge = userBadge.badge;
    final categoryName = userBadge.category?.name.trim() ?? '';
    final description = userBadge.description.trim().isNotEmpty
        ? userBadge.description.trim()
        : badge.description.trim();

    return FUISurface(
      padding: const EdgeInsets.all(FUITokens.gap12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FUITokens.gap10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(FUITokens.radiusFull),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _userBadgeIconFor(badge.icon),
                  size: 13,
                  color: colors.primary,
                ),
                const SizedBox(width: FUITokens.gap6),
                Flexible(
                  child: Text(
                    badge.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            description.isEmpty ? badge.name : description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          Text(
            categoryName.isEmpty ? '#${badge.id}' : categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _userBadgeIconFor(String? icon) {
  switch (icon) {
    case 'fas fa-star':
      return FluentIcons.star_24_regular;
    case 'fas fa-medal':
      return FluentIcons.premium_24_regular;
    case 'fas fa-crown':
      return FluentIcons.crown_24_regular;
    case 'fas fa-award':
      return FluentIcons.trophy_24_regular;
    case 'fas fa-shield-alt':
      return FluentIcons.shield_24_regular;
    default:
      return FluentIcons.ribbon_star_24_regular;
  }
}
