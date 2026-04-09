/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/pages/user/controller.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/discussion_list_item_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';

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
  late final bool _shouldDeleteControllerOnDispose;
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
    _tabController = TabController(length: 4, vsync: this);
    controller.currentSection.value = UserPageSection.info;
    _shouldDeleteControllerOnDispose = !widget.embedded;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.ensureSectionLoaded(UserPageSection.info);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_shouldDeleteControllerOnDispose &&
        Get.isRegistered<UserPageController>(tag: widget.tag)) {
      Get.delete<UserPageController>(tag: widget.tag);
    }
    super.dispose();
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (widget.isAccountPage && widget.userId > 0) return null;

    final mainController = widget.embedded && Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : null;

    return AppBar(
      automaticallyImplyLeading: !widget.embedded,
      leading: widget.embedded
          ? IconButton(
              onPressed: () {
                if (mainController == null) return;
                if (mainController.canPopDetail) {
                  mainController.popDetail();
                  return;
                }
                mainController.closeDetail();
              },
              icon: Icon(
                mainController?.canPopDetail == true
                    ? Icons.arrow_back_rounded
                    : Icons.close_rounded,
              ),
            )
          : null,
      title: widget.embedded
          ? Obx(
              () => Text(
                controller.info?.displayName ??
                    (widget.isAccountPage
                        ? AppLocalizations.of(context)!.userCenter
                        : AppLocalizations.of(context)!.userAppBarTitle),
              ),
            )
          : Text(AppLocalizations.of(context)!.userAppBarTitle),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Obx(() {
          return controller.isLoading.value
              ? const LinearProgressIndicator()
              : const SizedBox.shrink();
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _UserSectionTabs(controller: controller, tabController: _tabController),
        Expanded(
          child: _UserSectionBody(
            controller: controller,
            isAccountPage: widget.isAccountPage,
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

    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
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

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (index) =>
            controller.selectSection(UserPageSection.values[index]),
        tabs: [
          Tab(text: l10n.userSectionInfo),
          Tab(text: l10n.userCommentCountLabel),
          Tab(text: l10n.userDiscussionCountLabel),
          Tab(text: l10n.userSectionBadges),
        ],
      ),
    );
  }
}

class _UserSectionBody extends StatelessWidget {
  const _UserSectionBody({
    required this.controller,
    required this.isAccountPage,
  });

  final UserPageController controller;
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentSection.value) {
        case UserPageSection.info:
          return _UserInfoSection(
            controller: controller,
            isAccountPage: isAccountPage,
          );
        case UserPageSection.comments:
          return _UserCommentsSection(controller: controller);
        case UserPageSection.topics:
          return _UserTopicsSection(controller: controller);
        case UserPageSection.badges:
          return _UserBadgesSection(controller: controller);
      }
    });
  }
}
