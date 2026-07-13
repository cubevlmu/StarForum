/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: khfahqp khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/settings_page.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/notification/widgets/notify_card.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/utils/setting_util.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<NotificationPageController>()
        ? Get.find<NotificationPageController>()
        : Get.put(NotificationPageController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.repo.isLogin && controller.items.isEmpty) {
        controller.onRefresh();
      }
    });
  }

  void _handleTabChanged(NotificationTab tab) {
    if (tab == controller.currentTab.value) return;
    controller.selectTab(tab);
    if (controller.scrollController.hasClients) {
      controller.scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // Header
          Padding(
            padding: ForumLayout.pageHeadPadding,
            child: FuiPageHead(
              showNavigation: false,
              title: l10n.notificationTitle,
              subtitle: l10n.notificationSubtitle,
              actions: [
                Obx(() {
                  final isLogin = controller.isLogin.value;
                  final isInvoking = controller.isInvoking.value;
                  final action = controller.activeToolbarAction.value;
                  if (!isLogin) return const SizedBox.shrink();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionBtn(
                        icon: FUIIcons.checkmark,
                        tooltip: l10n.notificationMarkReadSuccess,
                        loading: action == NotificationToolbarAction.readAll,
                        onPressed: isInvoking ? null : controller.readAll,
                      ),
                      const SizedBox(width: FUITokens.gap4),
                      _ActionBtn(
                        icon: FUIIcons.delete,
                        tooltip: l10n.notificationClearAllSuccess,
                        loading: action == NotificationToolbarAction.clearAll,
                        onPressed: isInvoking
                            ? null
                            : () => _confirmClearAll(context, l10n),
                      ),
                      const SizedBox(width: FUITokens.gap4),
                      FUIIconButton(
                        icon: FUIIcons.settings,
                        tooltip: l10n.commonActionSettings,
                        variant: FUIIconButtonVariant.ghost,
                        onPressed: () => FuiNavigation.openDetail(
                          context,
                          builder: (_) => const SettingsPage(),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          _NotifButtonGroup(
            controller: controller,
            onSelected: _handleTabChanged,
            l10n: l10n,
          ),
          // Body
          Expanded(
            child: Obx(() {
              if (!controller.isLogin.value) {
                return NotLoginNotice(
                  title: l10n.commonNotLoggedInTitle,
                  tipsText: l10n.notificationNotLoginTips,
                );
              }
              final items = controller.filteredItems;
              final showSkeleton =
                  controller.isInitialLoading.value && controller.items.isEmpty;

              return FUIRefresh(
                controller: controller.refreshController,
                onRefresh: controller.onRefresh,
                onLoad: controller.onLoad,
                refreshOnStart: false,
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
                        const SliverToBoxAdapter(
                          child: _NotificationLoadingSkeleton(),
                        )
                      else if (items.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: NoticeWidget(
                            emoji: '📭',
                            title: l10n.notificationEmptyTitle,
                            tips: l10n.notificationEmptyTips,
                          ),
                        )
                      else
                        SliverMainAxisGroup(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    ForumLayout.edge,
                                    ForumLayout.cardGap,
                                    ForumLayout.edge,
                                    ForumLayout.cardGap,
                                  ),
                                  child: NotifyCard(
                                    item: items[index],
                                    controller: controller,
                                  ),
                                ),
                                childCount: items.length,
                              ),
                            ),
                          ],
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await shared.SharedDialog.showConfirmDialog(
      context,
      title: l10n.dialogConfirmTitle,
      content: l10n.notificationClearAllConfirm,
      cancelText: l10n.commonActionCancel,
      confirmText: l10n.commonActionConfirm,
      variant: shared.SharedDialogVariant.danger,
      icon: FUIIcons.delete,
    );
    if (confirmed) {
      controller.clearAll();
    }
  }
}

class _NotifButtonGroup extends StatelessWidget {
  const _NotifButtonGroup({
    required this.controller,
    required this.onSelected,
    required this.l10n,
  });

  final NotificationPageController controller;
  final ValueChanged<NotificationTab> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (
        tab: NotificationTab.likes,
        label: l10n.notificationTabLikes,
        icon: ForumIcons.like,
      ),
      (
        tab: NotificationTab.replies,
        label: l10n.notificationTabReplies,
        icon: ForumIcons.comments,
      ),
      (
        tab: NotificationTab.notices,
        label: l10n.notificationTabNotices,
        icon: ForumIcons.notifications,
      ),
    ];
    return Obx(
      () => FUIButtonGroupTabBar(
        padding: const EdgeInsets.fromLTRB(
          ForumLayout.edge,
          0,
          ForumLayout.edge,
          ForumLayout.cardGap,
        ),
        items: [
          for (final item in tabs)
            FUIButtonGroupTabItem(
              icon: item.icon,
              label: item.label,
              tooltip: _tabLabel(
                item.label,
                controller.unreadCountForTab(item.tab),
              ),
            ),
        ],
        selectedIndex: tabs.indexWhere(
          (item) => item.tab == controller.currentTab.value,
        ),
        onSelected: (index) => onSelected(tabs[index].tab),
        showLabels: !SettingsUtil.buttonGroupIconOnly,
        alignment: SettingsUtil.buttonGroupAlignment.alignment,
      ),
    );
  }

  String _tabLabel(String label, int unreadCount) {
    if (unreadCount <= 0) return label;
    return '$label $unreadCount';
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FUIIconButton(
      icon: icon,
      tooltip: tooltip,
      variant: FUIIconButtonVariant.ghost,
      onPressed: loading ? null : onPressed,
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
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.fromLTRB(
                ForumLayout.edge,
                ForumLayout.cardGap,
                ForumLayout.edge,
                ForumLayout.cardGap,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(FUITokens.radiusLg),
                  border: Border.all(color: context.colors.border),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: palette.circle(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBar(
                            decoration: palette.line(),
                            widthFactor: 0.44,
                            height: 13,
                          ),
                          const SizedBox(height: FUITokens.gap8),
                          SkeletonBar(
                            decoration: palette.line(),
                            widthFactor: 0.86,
                            height: 12,
                          ),
                          const SizedBox(height: FUITokens.gap6),
                          SkeletonBar(
                            decoration: palette.line(),
                            widthFactor: 0.72,
                            height: 12,
                          ),
                          const SizedBox(height: 10),
                          SkeletonBar(
                            decoration: palette.line(),
                            widthFactor: 0.36,
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
