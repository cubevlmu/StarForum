import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/perf/perf_interactive_boundary.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/account/view.dart';
import 'package:star_forum/pages/home/view.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/notification/view.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/search_result/view.dart';
import 'package:star_forum/pages/theme_list/view.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/utils/update_check_flow.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MainController controller;
  bool _didScheduleAutoUpdateCheck = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : Get.put(MainController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleAutoUpdateCheck();
    });
  }

  Future<void> _scheduleAutoUpdateCheck() async {
    if (_didScheduleAutoUpdateCheck) return;
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
    if (!mounted) return;
    await runGithubUpdateCheckFlow(context, silentIfLatest: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final hasUnread =
          Get.isRegistered<NotificationPageController>() &&
          Get.find<NotificationPageController>().hasUnreadItems;

      return FuiNavigationShell(
        selectedIndex: controller.selectedIndex.value,
        onSelected: controller.onDestinationSelected,
        autoExtendRail: false,
        splitPlan: FuiSplitNavigationPlan(
          placeholderData: FuiSecondaryPlaceholderData(
            icon: ForumIcons.forum,
            title: l10n.mainDetailPlaceholderTitle,
            subtitle: l10n.mainDetailPlaceholderTips,
          ),
        ),
        items: [
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: ForumIcons.feed,
              selectedIcon: ForumIcons.feedFilled,
              label: l10n.mainHomePage,
            ),
            page: PerfInteractiveBoundary(
              name: 'home',
              active: controller.selectedIndex.value == 0,
              child: _HomeRootPage(controller: controller),
            ),
          ),
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: ForumIcons.tags,
              selectedIcon: ForumIcons.tagsFilled,
              label: l10n.mainTagsPage,
            ),
            page: PerfInteractiveBoundary(
              name: 'tags',
              active: controller.selectedIndex.value == 1,
              child: const TagListPage(),
            ),
          ),
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: ForumIcons.notifications,
              selectedIcon: ForumIcons.notificationsFilled,
              label: l10n.mainNotiPage,
              showBadge: hasUnread,
            ),
            page: PerfInteractiveBoundary(
              name: 'notifications',
              active: controller.selectedIndex.value == 2,
              child: const NotificationPage(),
            ),
          ),
          FuiNavigationItem(
            destination: FuiNavigationDestination(
              icon: ForumIcons.profile,
              selectedIcon: ForumIcons.profileFilled,
              label: l10n.mainUserPage,
            ),
            page: PerfInteractiveBoundary(
              name: 'account',
              active: controller.selectedIndex.value == 3,
              child: const AccountPage(),
            ),
          ),
        ],
      );
    });
  }
}

class _HomeRootPage extends StatelessWidget {
  const _HomeRootPage({required this.controller});

  final MainController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final keyword = controller.homeSearchKeyword.value;
      final showSearch = controller.isHomeSearchActive.value;

      return Stack(
        children: [
          const HomePage(),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !showSearch,
              child: AnimatedSlide(
                offset: showSearch ? Offset.zero : const Offset(1, 0),
                duration: FUITokens.durationNormal,
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: showSearch ? 1 : 0,
                  duration: FUITokens.durationFast,
                  child: ColoredBox(
                    color: context.colors.background,
                    child: keyword == null || keyword.isEmpty
                        ? SearchPage(
                            embedded: true,
                            onClose: controller.closeHomeSearch,
                            onSearchRequested: controller.submitHomeSearch,
                          )
                        : SearchResultPage(
                            key: ValueKey('home-search:$keyword'),
                            keyWord: keyword,
                            embedded: true,
                            onBack: controller.editHomeSearch,
                            onEditSearch: controller.editHomeSearch,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
