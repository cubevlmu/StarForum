/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/search_result/view.dart';
import 'package:star_forum/pages/settings/about_page.dart';
import 'package:star_forum/pages/settings/settings_page.dart';
import 'package:star_forum/pages/setup/view.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/pages/login/view.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/widgets/image_view.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const double _railBreakPoint = 640;
  static const List<int> _backgroundPrewarmIndexes = <int>[2];
  late MainController controller;
  late final List<Widget?> _rootPages;
  bool _wasThreePane = false;
  bool _didScheduleAutoUpdateCheck = false;

  @override
  void initState() {
    controller = Get.put(MainController());
    _rootPages = List<Widget?>.filled(
      controller.pageBuilders.length,
      null,
      growable: false,
    );
    _ensureRootPageCreated(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CacheUtils.deleteAllCacheImage();
      _prewarmBackgroundPages();
      _scheduleAutoUpdateCheck();
    });
    super.initState();
  }

  Future<void> _scheduleAutoUpdateCheck() async {
    if (_didScheduleAutoUpdateCheck) {
      return;
    }
    _didScheduleAutoUpdateCheck = true;

    final enabled =
        SettingsUtil.getValue(
              SettingsStorageKeys.autoCheckUpdate,
              defaultValue: true,
            )
            as bool;
    if (!enabled) {
      LogUtil.info('[Update] Auto update check disabled.');
      return;
    }

    LogUtil.info('[Update] Schedule automatic GitHub update check.');
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    await runGithubUpdateCheckFlow(context, silentIfLatest: true);
  }

  Future<void> _prewarmBackgroundPages() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (final index in _backgroundPrewarmIndexes) {
      if (!mounted) {
        return;
      }
      _ensureRootPageCreated(index, notify: true);
      await Future<void>.delayed(const Duration(milliseconds: 240));
    }
  }

  void _ensureRootPageCreated(int index, {bool notify = false}) {
    if (_rootPages[index] != null) {
      return;
    }
    final page = RepaintBoundary(
      child: KeyedSubtree(
        key: PageStorageKey<String>("main_root_page_$index"),
        child: controller.pageBuilders[index](),
      ),
    );
    if (!notify) {
      _rootPages[index] = page;
      return;
    }
    setState(() {
      _rootPages[index] = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useRail = width >= _railBreakPoint;
        final useThreePane = width >= kThreePaneBreakPoint;
        final currentDetail = controller.currentDetail;
        _handleLayoutTransition(
          useThreePane: useThreePane,
          currentDetail: currentDetail,
        );

        return Scaffold(
          primary: true,
          body: Row(
            children: [
              if (useRail)
                Obx(() {
                  final selectedIndex = controller.selectedIndex.value;
                  final hasUnreadNotifications =
                      Get.isRegistered<NotificationPageController>() &&
                      Get.find<NotificationPageController>().hasUnreadItems;
                  return _MainRail(
                    controller: controller,
                    l10n: l10n,
                    selectedIndex: selectedIndex,
                    hasUnreadNotifications: hasUnreadNotifications,
                  );
                }),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: useThreePane ? 4 : 1,
                      child: Obx(() {
                        final selectedIndex = controller.selectedIndex.value;
                        final isHomeSearchActive =
                            controller.isHomeSearchActive.value;
                        final homeSearchKeyword =
                            controller.homeSearchKeyword.value;
                        final showHomeSearch =
                            useThreePane &&
                            selectedIndex == 0 &&
                            isHomeSearchActive;

                        _ensureRootPageCreated(selectedIndex);

                        return Stack(
                          children: [
                            IndexedStack(
                              index: selectedIndex,
                              children: List<Widget>.generate(
                                _rootPages.length,
                                (index) =>
                                    _rootPages[index] ??
                                    const SizedBox.shrink(),
                                growable: false,
                              ),
                            ),
                            if (showHomeSearch)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  child: _HomeSearchPane(
                                    keyword: homeSearchKeyword,
                                    controller: controller,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                    if (useThreePane)
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    if (useThreePane)
                      Expanded(
                        flex: 6,
                        child: Obx(() {
                          final detailStack = List<DetailPaneEntry>.from(
                            controller.detailStack,
                          );
                          return _DetailPane(
                            controller: controller,
                            l10n: l10n,
                            detailStack: detailStack,
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : Obx(() {
                  final selectedIndex = controller.selectedIndex.value;
                  final hasUnreadNotifications =
                      Get.isRegistered<NotificationPageController>() &&
                      Get.find<NotificationPageController>().hasUnreadItems;
                  return NavigationBar(
                    height: 64,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    animationDuration: const Duration(milliseconds: 260),
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: const Icon(Icons.home),
                        label: l10n.mainHomePage,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.sell_outlined),
                        selectedIcon: const Icon(Icons.sell),
                        label: l10n.mainTagsPage,
                      ),
                      NavigationDestination(
                        icon: hasUnreadNotifications
                            ? const Badge(
                                child: Icon(Icons.notifications_outlined),
                              )
                            : const Icon(Icons.notifications_outlined),
                        selectedIcon: hasUnreadNotifications
                            ? const Badge(child: Icon(Icons.notifications))
                            : const Icon(Icons.notifications),
                        label: l10n.mainNotiPage,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.account_circle_outlined),
                        selectedIcon: const Icon(Icons.account_circle),
                        label: l10n.mainUserPage,
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: controller.onDestinationSelected,
                  );
                }),
        );
      },
    );
  }

  void _handleLayoutTransition({
    required bool useThreePane,
    required DetailPaneEntry? currentDetail,
  }) {
    if (_wasThreePane && !useThreePane && currentDetail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (currentDetail.type) {
          case DetailPaneEntryType.discussion:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PostPage(item: currentDetail.discussion!),
              ),
            );
            break;
          case DetailPaneEntryType.user:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserPage(userId: currentDetail.userId!),
              ),
            );
            break;
          case DetailPaneEntryType.settings:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            break;
          case DetailPaneEntryType.login:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
            break;
          case DetailPaneEntryType.setup:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SetupPage(isSetup: false),
              ),
            );
            break;
          case DetailPaneEntryType.image:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ImagePreviewWidget(url: currentDetail.imageUrl!),
              ),
            );
            break;
        }
        controller.closeDetail();
      });
    }
    _wasThreePane = useThreePane;
  }
}

class _MainRail extends StatelessWidget {
  const _MainRail({
    required this.controller,
    required this.l10n,
    required this.selectedIndex,
    required this.hasUnreadNotifications,
  });

  final MainController controller;
  final AppLocalizations l10n;
  final int selectedIndex;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: false,
      groupAlignment: 0,
      labelType: NavigationRailLabelType.selected,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.mainHomePage),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.sell_outlined),
          selectedIcon: const Icon(Icons.sell),
          label: Text(l10n.mainTagsPage),
        ),
        NavigationRailDestination(
          icon: hasUnreadNotifications
              ? const Badge(child: Icon(Icons.notifications_outlined))
              : const Icon(Icons.notifications_outlined),
          selectedIcon: hasUnreadNotifications
              ? const Badge(child: Icon(Icons.notifications))
              : const Icon(Icons.notifications),
          label: Text(l10n.mainNotiPage),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.account_circle_outlined),
          selectedIcon: const Icon(Icons.account_circle),
          label: Text(l10n.mainUserPage),
        ),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: controller.onDestinationSelected,
    );
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.controller,
    required this.l10n,
    required this.detailStack,
  });

  final MainController controller;
  final AppLocalizations l10n;
  final List<DetailPaneEntry> detailStack;

  @override
  Widget build(BuildContext context) {
    if (detailStack.isEmpty) {
      return _DetailPlaceholder(
        icon: Icons.touch_app_outlined,
        title: l10n.mainDetailPlaceholderTitle,
        tips: l10n.mainDetailPlaceholderTips,
      );
    }

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return IndexedStack(
      index: detailStack.length - 1,
      children: [
        for (final detail in detailStack)
          ColoredBox(
            key: ValueKey("DetailEntry:${detail.entryId}"),
            color: backgroundColor,
            child: _buildDetailEntry(detail),
          ),
      ],
    );
  }

  Widget _buildDetailEntry(DetailPaneEntry detail) {
    switch (detail.type) {
      case DetailPaneEntryType.user:
        return UserPage(
          key: ValueKey("DetailUser:${detail.entryId}:${detail.userId}"),
          userId: detail.userId!,
          embedded: true,
        );
      case DetailPaneEntryType.settings:
        return SettingsPaneNavigator(
          key: ValueKey("DetailSettings:${detail.entryId}"),
          onClose: controller.closeDetail,
          onBack: controller.popDetail,
          canPopDetail: controller.canPopDetail,
        );
      case DetailPaneEntryType.discussion:
        return PostPage(
          key: ValueKey(
            "DetailPost:${detail.entryId}:${detail.discussion!.id}",
          ),
          item: detail.discussion!,
          embedded: true,
        );
      case DetailPaneEntryType.login:
        return LoginPaneNavigator(
          key: ValueKey("DetailLogin:${detail.entryId}"),
          onClose: controller.closeDetail,
          onBack: controller.popDetail,
          canPopDetail: controller.canPopDetail,
          onLoginSuccess: (_) async {
            controller.selectedIndex.value = 3;
            controller.closeDetail();
          },
        );
      case DetailPaneEntryType.setup:
        return SetupPage(
          key: ValueKey("DetailSetup:${detail.entryId}"),
          isSetup: false,
          embedded: true,
          showEmbeddedBack: controller.canPopDetail,
          onEmbeddedLeadingPressed: controller.canPopDetail
              ? controller.popDetail
              : controller.closeDetail,
          onFinish: controller.closeDetail,
        );
      case DetailPaneEntryType.image:
        return ImagePreviewWidget(
          key: ValueKey("DetailImage:${detail.entryId}:${detail.imageUrl}"),
          url: detail.imageUrl!,
          embedded: true,
          onClose: controller.closeDetail,
          onBack: controller.popDetail,
          canPopDetail: controller.canPopDetail,
        );
    }
  }
}

class _HomeSearchPane extends StatelessWidget {
  const _HomeSearchPane({required this.keyword, required this.controller});

  final String? keyword;
  final MainController controller;

  @override
  Widget build(BuildContext context) {
    if (keyword == null || keyword!.isEmpty) {
      return SearchPage(
        embedded: true,
        onClose: controller.closeHomeSearch,
        onSearchRequested: controller.submitHomeSearch,
      );
    }

    return SearchResultPage(
      key: ValueKey("MainEmbeddedSearch:$keyword"),
      keyWord: keyword!,
      embedded: true,
      onBack: controller.editHomeSearch,
      onEditSearch: controller.editHomeSearch,
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder({
    required this.icon,
    required this.title,
    required this.tips,
  });

  final IconData icon;
  final String title;
  final String tips;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              tips,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
