/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/post_list/controller.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:get/get.dart';

class SetupPageController extends GetxController {
  final pageController = PageController();

  final forumInfo = Rxn<ForumInfo>();
  final forumLag = 0.obs;
  final isLoading = false.obs;

  final userRepo = getIt<UserRepo>();
  final tagsRepo = getIt<TagRepo>();
  final dissRepo = getIt<DiscussionRepository>();

  String siteUrl = "";

  Future<void> finalSetup() async {
    final box = StorageUtils.history;

    LogUtil.info("[SetupPage] Begin to sync user repo.");
    await userRepo.logout();
    await userRepo.setup();
    LogUtil.info("[SetupRage] Begin to sync tag repo.");
    tagsRepo.clear();
    await tagsRepo.syncTags();
    LogUtil.info("[SetupRage] Begin to clear database.");
    await dissRepo.clearAll();
    await box.delete("searchHistory");

    LogUtil.info("[SetupPage] Begin to sync post list.");
    try {
      final homeC = Get.find<HomeController>();
      homeC.info.value = forumInfo.value; // Update home
    } catch (_) {
      LogUtil.warn("[SetupPage] Home controller is not registered.");
    }

    try {
      final postC = Get.find<PostListController>();
      await postC.onRefresh();
    } catch (_) {
      LogUtil.warn("[SetupPage] Post list page controller is not registered.");
    }

    LogUtil.info("[SetupPage] Done.");
  }

  Future<void> finishSetup() async {
    isLoading.value = true;
    Api.setUrl(siteUrl);
    await finalSetup();
    isLoading.value = false;
    SnackbarUtils.showMessage(msg: "初始化完毕!");
  }

  Future<bool> _getForumInfo(String url) async {
    try {
      final (r, l) = await Api.getForumInfo(url);
      if (r == null) {
        return false;
      }

      forumLag.value = l;
      forumInfo.value = r;
      return true;
    } catch (e, s) {
      LogUtil.errorE(
        "[SetupPage] Failed to fetch forum information with errror:",
        e,
        s,
      );
    }

    return false;
  }

  Future<void> setupUrl() async {
    if (siteUrl.isEmpty) {
      SnackbarUtils.showMessage(msg: "站点地址不能为空!");
      return;
    }

    if (!pageController.hasClients) return;
    final normalizedUrl = StringUtil.normalizeSiteUrl(siteUrl);

    if (normalizedUrl == null) {
      SnackbarUtils.showMessage(msg: "请输入正确的站点地址");
      return;
    }

    isLoading.value = true;
    LogUtil.info("[Setup] Fetch forum info: $normalizedUrl");
    final ok = await _getForumInfo(normalizedUrl);
    isLoading.value = false;

    if (!ok) {
      SnackbarUtils.showMessage(msg: "网络错误", title: "获取站点信息失败");
      return;
    }

    siteUrl = normalizedUrl;

    pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  void checkGreet() async {
    if (!pageController.hasClients) {
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }
}
