/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/notification/widgets/notify_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationPageController controller;

  @override
  void initState() {
    controller = Get.put(NotificationPageController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.repo.isLogin && controller.items.isEmpty) {
        controller.onRefresh();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildView(BuildContext context) {
    final items = controller.items;

    return Obx(() {
      final showSkeleton = controller.isInitialLoading.value && items.isEmpty;
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
              if (showSkeleton)
                const SliverToBoxAdapter(child: _NotificationLoadingSkeleton())
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoticeWidget(
                    emoji: "📭",
                    title: AppLocalizations.of(context)!.notificationEmptyTitle,
                    tips: AppLocalizations.of(context)!.notificationEmptyTips,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: NotifyCard(item: item, controller: controller),
                    );
                  }, childCount: items.length),
                ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: controller.isLogin.value
            ? _buildView(context)
            : NotLoginNotice(
                title: AppLocalizations.of(context)!.notificationNotLoginTitle,
                tipsText: AppLocalizations.of(
                  context,
                )!.notificationNotLoginTips,
              ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.notificationTitle),
      actions: [
        if (controller.isLogin.value)
          IconButton(
            onPressed: controller.isInvoking.value ? null : controller.readAll,
            icon: const Icon(Icons.checklist_outlined),
          ),
        const SizedBox(width: 10),
        if (controller.isLogin.value)
          IconButton(
            onPressed: controller.isInvoking.value ? null : controller.clearAll,
            icon: const Icon(Icons.delete),
          ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: controller.isInvoking.value
              ? null
              : () {
                  openSettingsAdaptive(context);
                },
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 10),
      ],
      bottom: controller.isInvoking.value
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }
}

class _NotificationLoadingSkeleton extends StatelessWidget {
  const _NotificationLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1450),
      highlightStrength: 0.18,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            4,
            (index) => _NotificationLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationLoadingCard extends StatelessWidget {
  const _NotificationLoadingCard({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 44, height: 44, decoration: circleDecoration),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.44,
                      height: 14,
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
                      widthFactor: 0.72,
                      height: 12,
                    ),
                    const SizedBox(height: 12),
                    SkeletonBar(
                      decoration: pillDecoration,
                      widthFactor: 0.36,
                      height: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 24, height: 24, decoration: circleDecoration),
            ],
          ),
        ),
      ),
    );
  }
}
