/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: khfahqp khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/assets/view.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/user/controller.dart';
import 'package:star_forum/pages/user/controllers/user_badges_controller.dart';
import 'package:star_forum/pages/user/controllers/user_profile_controller.dart';
import 'package:star_forum/pages/user/controllers/user_replies_controller.dart';
import 'package:star_forum/pages/user/controllers/user_topics_controller.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/two_column_loading_skeleton.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/widgets/forum/forum_discussion_tile.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';

part 'pages/badges_page.dart';
part 'pages/avatar_crop_dialog.dart';
part 'pages/comments_page.dart';
part 'pages/info_page.dart';
part 'pages/info_widgets.dart';
part 'pages/topics_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    super.key,
    required this.userId,
    this.isAccountPage = false,
    this.embedded = false,
  }) : tag = "user_space:$userId";

  final int userId;
  final String tag;
  final bool isAccountPage;
  final bool embedded;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  late final UserPageController controller;
  late final TabController _tabController;

  @override
  void initState() {
    if (Get.isRegistered<UserPageController>(tag: widget.tag)) {
      controller = Get.find<UserPageController>(tag: widget.tag);
    } else {
      controller = Get.put(
        UserPageController(userId: widget.userId),
        tag: widget.tag,
      );
    }
    _tabController = TabController(
      length: widget.isAccountPage ? 5 : 4,
      vsync: this,
    );
    controller.currentSection.value = UserPageSection.info;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.ensureSectionLoaded(UserPageSection.info);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        if (!widget.isAccountPage)
          _UserPageHead(controller: controller.profileController),
        _UserSectionTabs(controller: controller, tabController: _tabController),
        Expanded(
          child: _UserSectionBody(
            controller: controller,
            isAccountPage: widget.isAccountPage,
            showAssetsSection: widget.isAccountPage,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == -1) {
      return NoticeWidget(
        emoji: "🤦‍♂️",
        title: AppLocalizations.of(context)!.userInvalidAccountTitle,
        tips: AppLocalizations.of(context)!.userInvalidAccountTips,
      );
    } else if (widget.userId == -2) {
      return NotLoginNotice(
        title: AppLocalizations.of(context)!.userNotLoginTitle,
        tipsText: AppLocalizations.of(context)!.userNotLoginTips,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: _buildBody(context),
    );
  }
}

class _UserPageHead extends StatelessWidget {
  const _UserPageHead({required this.controller});

  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: ForumLayout.pageHeadPadding,
          child: Obx(() {
            final info = controller.info;
            return FuiPageHead(
              title: info?.displayName ?? l10n.userAppBarTitle,
              subtitle: l10n.userAppBarSub,
            );
          }),
        ),
        Obx(
          () => controller.isLoading.value
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox(height: 2),
        ),
      ],
    );
  }
}

class _UserSectionTabs extends StatelessWidget {
  const _UserSectionTabs({
    required this.controller,
    required this.tabController,
  });

  final UserPageController controller;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = <UserPageSection>[
      UserPageSection.info,
      UserPageSection.comments,
      UserPageSection.topics,
      UserPageSection.badges,
      if (tabController.length > 4) UserPageSection.assets,
    ];

    final tabs = <({UserPageSection section, FUIButtonGroupTabItem item})>[
      (
        section: UserPageSection.info,
        item: FUIButtonGroupTabItem(
          icon: FUIIcons.info,
          label: l10n.userSectionInfo,
        ),
      ),
      (
        section: UserPageSection.comments,
        item: FUIButtonGroupTabItem(
          icon: ForumIcons.comments,
          label: l10n.userCommentCountLabel,
        ),
      ),
      (
        section: UserPageSection.topics,
        item: FUIButtonGroupTabItem(
          icon: ForumIcons.forum,
          label: l10n.userDiscussionCountLabel,
        ),
      ),
      (
        section: UserPageSection.badges,
        item: FUIButtonGroupTabItem(
          icon: ForumIcons.badge,
          label: l10n.userSectionBadges,
        ),
      ),
      if (tabController.length > 4)
        (
          section: UserPageSection.assets,
          item: FUIButtonGroupTabItem(
            icon: ForumIcons.folder,
            label: l10n.userSectionAssets,
          ),
        ),
    ];
    return Obx(
      () => FUIButtonGroupTabBar(
        items: [for (final tab in tabs) tab.item],
        selectedIndex: tabs.indexWhere(
          (tab) => tab.section == controller.currentSection.value,
        ),
        onSelected: (index) {
          tabController.animateTo(index);
          controller.selectSection(sections[index]);
        },
        showLabels: !SettingsUtil.buttonGroupIconOnly,
        alignment: SettingsUtil.buttonGroupAlignment.alignment,
        padding: const EdgeInsets.symmetric(horizontal: ForumLayout.edge),
      ),
    );
  }
}

class _UserSectionBody extends StatelessWidget {
  const _UserSectionBody({
    required this.controller,
    required this.isAccountPage,
    required this.showAssetsSection,
  });

  final UserPageController controller;
  final bool isAccountPage;
  final bool showAssetsSection;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentSection.value) {
        case UserPageSection.info:
          return _UserInfoSection(
            controller: controller.profileController,
            isAccountPage: isAccountPage,
          );
        case UserPageSection.comments:
          return _UserCommentsSection(controller: controller.repliesController);
        case UserPageSection.topics:
          return _UserTopicsSection(controller: controller.topicsController);
        case UserPageSection.badges:
          return _UserBadgesSection(controller: controller.badgesController);
        case UserPageSection.assets:
          if (showAssetsSection) {
            return const AssetsPage(embedded: true);
          }
          return _UserInfoSection(
            controller: controller.profileController,
            isAccountPage: isAccountPage,
          );
      }
    });
  }
}
