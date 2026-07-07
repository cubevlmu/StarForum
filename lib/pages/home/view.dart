/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/badge/view.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/home/widgets/user_dialog.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/pages/post_list/view.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/subscription/view.dart';
import 'package:star_forum/pages/user_group/view.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/forum_button_group.dart';
import 'package:star_forum/widgets/sheet_util.dart';
import 'package:star_forum/utils/html_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final HomeController controller;
  late final TabController _tabController;

  static const _tabs = 4;

  @override
  void initState() {
    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    _tabController = TabController(length: _tabs, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ForumLayout.pageHeadPadding,
              child: _HomeHeader(controller: controller),
            ),
            _HomeButtonGroup(
              controller: _tabController,
              items: [
                ForumButtonGroupItem(
                  icon: ForumIcons.forum,
                  label: l10n.homeSectionAllTopics,
                ),
                ForumButtonGroupItem(
                  icon: ForumIcons.bookmark,
                  label: l10n.homeSectionFollowing,
                ),
                ForumButtonGroupItem(
                  icon: ForumIcons.people,
                  label: l10n.homeSectionUsers,
                ),
                ForumButtonGroupItem(
                  icon: ForumIcons.badge,
                  label: l10n.homeSectionBadges,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  PostListPage(),
                  SubscriptionPage(),
                  UserGroupPage(),
                  BadgePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButtonGroup extends StatelessWidget {
  const _HomeButtonGroup({required this.controller, required this.items});

  final TabController controller;
  final List<ForumButtonGroupItem> items;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => ForumButtonGroup(
        items: items,
        selectedIndex: controller.index,
        onSelected: controller.animateTo,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FuiPageHead(
        showNavigation: false,
        title: controller.info.value?.title ?? 'StarForum',
        subtitle: (controller.info.value?.description ?? '').isEmpty
            ? null
            : htmlToPlainText(controller.info.value?.description ?? ''),
        actions: [
          FUIIconButton(
            icon: FUIIcons.search,
            variant: FUIIconButtonVariant.ghost,
            onPressed: () {
              if (Get.isRegistered<MainController>()) {
                Get.find<MainController>().openHomeSearch();
                return;
              }
              Navigator.of(
                context,
              ).push(FuiPageRoute<void>(builder: (_) => const SearchPage()));
            },
          ),
          const SizedBox(width: FUITokens.gap8),
          AvatarWidget(
            avatarUrl: controller.isLogin.value
                ? controller.avatarUrl.value
                : '',
            radius: 18,
            placeholder: '',
            onPressed: () {
              SheetUtil.newBottomSheet(
                context: context,
                widget: UserDialogWidget(
                  controller: controller,
                  navigationContext: context,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
