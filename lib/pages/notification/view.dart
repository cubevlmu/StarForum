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

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  late final NotificationPageController controller;
  late final TabController tabController;

  @override
  void initState() {
    controller = Get.put(NotificationPageController());
    tabController = TabController(
      length: NotificationTab.values.length,
      vsync: this,
      initialIndex: controller.currentTab.value.index,
    );
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
    tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged(int index) {
    controller.selectTab(NotificationTab.values[index]);
    if (controller.scrollController.hasClients) {
      controller.scrollController.jumpTo(0);
    }
  }

  Widget _buildView(BuildContext context) {
    return Obx(() {
      final items = controller.filteredItems;
      final showSkeleton =
          controller.isInitialLoading.value && controller.items.isEmpty;
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
              SliverToBoxAdapter(
                child: _NotificationTabs(
                  controller: controller,
                  tabController: tabController,
                  onTap: _handleTabChanged,
                ),
              ),
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _NotificationBody(controller: controller, buildView: _buildView),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.notificationTitle),
      actions: [
        const SizedBox(width: 4),
        _NotificationActions(controller: controller),
      ],
    );
  }
}

class _NotificationTabs extends StatelessWidget {
  const _NotificationTabs({
    required this.controller,
    required this.tabController,
    required this.onTap,
  });

  final NotificationPageController controller;
  final TabController tabController;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final tabs = <({NotificationTab tab, String label})>[
        (tab: NotificationTab.likes, label: l10n.notificationTabLikes),
        (tab: NotificationTab.replies, label: l10n.notificationTabReplies),
        (tab: NotificationTab.notices, label: l10n.notificationTabNotices),
      ];

      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: onTap,
            tabs: [
              for (final item in tabs)
                Tab(
                  child: _NotificationTabLabel(
                    label: item.label,
                    unreadCount: controller.unreadCountForTab(item.tab),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _NotificationTabLabel extends StatelessWidget {
  const _NotificationTabLabel({required this.label, required this.unreadCount});

  final String label;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final badgeText = unreadCount > 99 ? '99+' : unreadCount.toString();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (unreadCount > 0) ...[
          const SizedBox(width: 6),
          Badge(label: Text(badgeText)),
        ],
      ],
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({required this.controller, required this.buildView});

  final NotificationPageController controller;
  final Widget Function(BuildContext context) buildView;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLogin.value) {
        return buildView(context);
      }
      return NotLoginNotice(
        title: AppLocalizations.of(context)!.commonNotLoggedInTitle,
        tipsText: AppLocalizations.of(context)!.notificationNotLoginTips,
      );
    });
  }
}

class _NotificationActions extends StatelessWidget {
  const _NotificationActions({required this.controller});

  final NotificationPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLogin = controller.isLogin.value;
      final isInvoking = controller.isInvoking.value;
      final activeToolbarAction = controller.activeToolbarAction.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLogin)
            _ActionIconButton(
              onPressed: isInvoking ? null : controller.readAll,
              icon: Icons.checklist_outlined,
              isLoading:
                  activeToolbarAction == NotificationToolbarAction.readAll,
            ),
          if (isLogin) const SizedBox(width: 10),
          if (isLogin)
            _ActionIconButton(
              onPressed: isInvoking ? null : controller.clearAll,
              icon: Icons.delete,
              isLoading:
                  activeToolbarAction == NotificationToolbarAction.clearAll,
            ),
          if (isLogin) const SizedBox(width: 10),
          _ActionIconButton(
            onPressed: isInvoking
                ? null
                : () {
                    openSettingsAdaptive(context);
                  },
            icon: Icons.settings_outlined,
          ),
        ],
      );
    });
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Icon(icon),
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
