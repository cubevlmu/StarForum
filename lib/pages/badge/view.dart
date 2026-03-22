/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/badge/controller.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:star_forum/widgets/two_column_loading_skeleton.dart';

class BadgePage extends StatefulWidget {
  const BadgePage({super.key});

  @override
  State<StatefulWidget> createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage>
    with AutomaticKeepAliveClientMixin {
  static const _tag = 'home_badges';
  late final BadgeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BadgeController>(tag: _tag)
        ? Get.find<BadgeController>(tag: _tag)
        : Get.put(BadgeController(), tag: _tag);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.ensureLoaded();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final showLoading = controller.isLoading.value;
      final categories = controller.categories;
      if (!controller.hasLoaded || (showLoading && categories.isEmpty)) {
        return const _BadgeLoadingSkeleton();
      }

      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onRefresh: controller.refresh,
        autoRefreshOnStart: false,
        loadEnabled: false,
        childBuilder: (context, physics) {
          return CustomScrollView(
            physics: physics,
            slivers: [
              if (categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: '🏅',
                    title: l10n.badgePageEmptyTitle,
                    tips: l10n.badgePageEmptyTips,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 132,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _BadgeCategoryCard(category: categories[index]);
                    }, childCount: categories.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      );
    });
  }
}

class _BadgeLoadingSkeleton extends StatelessWidget {
  const _BadgeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: TwoColumnLoadingSkeleton(
            cardHeight: 132,
            itemBuilder: (context, palette) => _BadgeSkeletonCard(
              lineDecoration: palette.line(radius: 999),
              blockDecoration: palette.block(radius: 10),
            ),
            reservedHeight: 120,
            maxRows: 5,
          ),
        ),
      ],
    );
  }
}

class _BadgeSkeletonCard extends StatelessWidget {
  const _BadgeSkeletonCard({
    required this.lineDecoration,
    required this.blockDecoration,
  });

  final Decoration lineDecoration;
  final Decoration blockDecoration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: 0.02),
            colorScheme.surfaceContainerLowest,
          )
        : Color.alphaBlend(
            Colors.white.withValues(alpha: 0.55),
            colorScheme.surfaceContainerLowest,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.2 : 0.32,
          ),
        ),
      ),
      child: SizedBox(
        height: 132,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 92, height: 28, decoration: lineDecoration),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: blockDecoration,
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.72,
                    alignment: Alignment.centerLeft,
                    child: Container(height: 12, decoration: blockDecoration),
                  ),
                ],
              ),
              FractionallySizedBox(
                widthFactor: 0.48,
                alignment: Alignment.centerLeft,
                child: Container(height: 12, decoration: blockDecoration),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeCategoryCard extends StatelessWidget {
  const _BadgeCategoryCard({required this.category});

  final BadgeCategory category;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badge = category.badges.isNotEmpty ? category.badges.first : null;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _badgeIconFor(badge?.icon),
                        size: 14,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          badge?.name.isNotEmpty == true
                              ? badge!.name
                              : category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              (badge?.description.isNotEmpty == true
                      ? badge!.description
                      : category.description)
                  .trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${badge?.earnedAmount ?? 0}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' ${l10n.badgePageEarnedSuffix}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

IconData _badgeIconFor(String? icon) {
  switch (icon) {
    case 'fas fa-star':
      return Icons.star_rounded;
    case 'fas fa-medal':
      return Icons.workspace_premium_rounded;
    case 'fas fa-crown':
      return Icons.emoji_events_rounded;
    case 'fas fa-award':
      return Icons.military_tech_rounded;
    case 'fas fa-shield-alt':
      return Icons.shield_rounded;
    default:
      return Icons.star_rounded;
  }
}
