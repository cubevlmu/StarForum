/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/search_result/view.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const double _railBreakPoint = 640;
  late MainController controller;
  late final List<Widget> _rootPages;
  bool _wasThreePane = false;

  @override
  void initState() {
    controller = Get.put(MainController());
    _rootPages = List<Widget>.generate(
      controller.pages.length,
      (index) => RepaintBoundary(
        child: KeyedSubtree(
          key: PageStorageKey<String>("main_root_page_$index"),
          child: controller.pages[index],
        ),
      ),
      growable: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CacheUtils.deleteAllCacheImage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useRail = width >= _railBreakPoint;
        final useThreePane = width >= kThreePaneBreakPoint;
        final selectedDiscussion = controller.selectedDiscussion.value;
        _handleLayoutTransition(
          useThreePane: useThreePane,
          selectedDiscussion: selectedDiscussion,
        );

        return Scaffold(
          primary: true,
          body: Row(
            children: [
              if (useRail)
                Obx(() {
                  final selectedIndex = controller.selectedIndex.value;
                  return _MainRail(
                    controller: controller,
                    l10n: l10n,
                    selectedIndex: selectedIndex,
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

                        return Stack(
                          children: [
                            _AnimatedIndexedStack(
                                index: selectedIndex,
                                vertical: useRail,
                                children: _rootPages,
                              ),
                            if (showHomeSearch)
                              Positioned.fill(
                                child: ColoredBox(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                          return _DetailPane(
                            controller: controller,
                            l10n: l10n,
                            selected: controller.selectedDiscussion.value,
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
                        icon: const Icon(Icons.notifications_outlined),
                        selectedIcon: const Icon(Icons.notifications),
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
    required DiscussionItem? selectedDiscussion,
  }) {
    if (_wasThreePane && !useThreePane && selectedDiscussion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostPage(item: selectedDiscussion)),
        );
        controller.selectedDiscussion.value = null;
      });
    }
    _wasThreePane = useThreePane;
  }
}

class _AnimatedIndexedStack extends StatefulWidget {
  const _AnimatedIndexedStack({
    required this.index,
    required this.children,
    required this.vertical,
  });

  final int index;
  final List<Widget> children;
  final bool vertical;

  @override
  State<_AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<_AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  int? _lastIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _offsetAnimation = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void didUpdateWidget(covariant _AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastIndex == null) {
      _lastIndex = widget.index;
      return;
    }
    if (_lastIndex != widget.index) {
      _controller.duration = widget.vertical
          ? const Duration(milliseconds: 180)
          : const Duration(milliseconds: 240);
      final begin = widget.vertical
          ? const Offset(0, 0.028)
          : const Offset(0.024, 0);
      _offsetAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
      _lastIndex = widget.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    _lastIndex ??= widget.index;
    return SlideTransition(
      position: _offsetAnimation,
      child: IndexedStack(index: widget.index, children: widget.children),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MainRail extends StatelessWidget {
  const _MainRail({
    required this.controller,
    required this.l10n,
    required this.selectedIndex,
  });

  final MainController controller;
  final AppLocalizations l10n;
  final int selectedIndex;

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
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: const Icon(Icons.notifications),
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
    required this.selected,
  });

  final MainController controller;
  final AppLocalizations l10n;
  final DiscussionItem? selected;

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return _DetailPlaceholder(
        icon: Icons.touch_app_outlined,
        title: l10n.mainDetailPlaceholderTitle,
        tips: l10n.mainDetailPlaceholderTips,
      );
    }

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: PostPage(
        key: ValueKey("DetailPost:${selected!.id}"),
        item: selected!,
        embedded: true,
      ),
    );
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
