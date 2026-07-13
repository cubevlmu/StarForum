/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/badge/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/shared_notice.dart';
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

      return FUIRefresh(
        controller: controller.refreshController,
        onRefresh: controller.refresh,
        refreshOnStart: false,
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
                  padding: const EdgeInsets.fromLTRB(
                    FUITokens.pagePadding,
                    FUITokens.gap8,
                    FUITokens.pagePadding,
                    FUITokens.gap8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: FUITokens.gap10,
                          crossAxisSpacing: FUITokens.gap10,
                          mainAxisExtent: 120,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _BadgeCategoryCard(category: categories[index]),
                      childCount: categories.length,
                    ),
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
            cardHeight: 120,
            itemBuilder: (context, palette) => _BadgeSkeletonCard(
              lineDecoration: palette.line(radius: 999),
              blockDecoration: palette.block(radius: FUITokens.radiusSm),
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
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(FUITokens.radiusLg),
        border: Border.all(color: colors.border),
      ),
      child: SizedBox(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(FUITokens.gap12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 92, height: 24, decoration: lineDecoration),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: blockDecoration,
                  ),
                  const SizedBox(height: FUITokens.gap6),
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
    final colors = context.colors;
    final badge = category.badges.isNotEmpty ? category.badges.first : null;
    final l10n = AppLocalizations.of(context)!;

    return FUISurface(
      padding: const EdgeInsets.all(FUITokens.gap12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // badge pill
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
                  _badgeIconFor(badge?.icon),
                  size: 13,
                  color: colors.primary,
                ),
                const SizedBox(width: FUITokens.gap6),
                Flexible(
                  child: Text(
                    badge?.name.isNotEmpty == true
                        ? badge!.name
                        : category.name,
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
          // description
          Text(
            (badge?.description.isNotEmpty == true
                    ? badge!.description
                    : category.description)
                .trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          // earned count
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${badge?.earnedAmount ?? 0}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' ${l10n.badgePageEarnedSuffix}',
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

IconData _badgeIconFor(String? icon) {
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
