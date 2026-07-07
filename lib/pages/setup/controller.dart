/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/pages/post_list/controller.dart';
import 'package:star_forum/pages/theme_list/controller.dart';
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
  final forumRepo = getIt<ForumRepository>();

  String siteUrl = "";

  Future<void> finalSetup() async {
    final box = StorageUtils.history;

    LogUtil.info("[SetupPage] Begin parallel setup cleanup.");
    await userRepo.logout();
    tagsRepo.clear();
    await Future.wait<void>([
      userRepo.setup(),
      tagsRepo.syncTags(),
      dissRepo.clearAll(),
      box.delete("searchHistory"),
    ]);

    LogUtil.info("[SetupPage] Schedule page refreshes.");
    try {
      final homeC = Get.find<HomeController>();
      homeC.info.value = forumInfo.value; // Update home
    } catch (_) {
      LogUtil.warn("[SetupPage] Home controller is not registered.");
    }

    try {
      final postC = Get.find<PostListController>();
      unawaited(postC.onRefresh());
    } catch (_) {
      LogUtil.warn("[SetupPage] Post list page controller is not registered.");
    }

    try {
      final tagC = Get.find<TagListController>();
      unawaited(tagC.reloadTags());
    } catch (_) {
      LogUtil.warn("[SetupPage] Tag list controller is not registered.");
    }

    try {
      final notificationC = Get.find<NotificationPageController>();
      unawaited(notificationC.handleLoginStateChanged(userRepo.isLogin));
    } catch (_) {
      LogUtil.warn("[SetupPage] Notification controller is not registered.");
    }

    LogUtil.info("[SetupPage] Done.");
  }

  Future<void> finishSetup() async {
    isLoading.value = true;
    forumRepo.setUrl(siteUrl);
    await finalSetup();
    isLoading.value = false;
    SnackbarUtils.showMessage(
      msg: AppLocalizations.of(Get.context!)!.setupInitDone,
    );
  }

  Future<bool> _getForumInfo(String url) async {
    try {
      final result = await forumRepo.getForumInfo(url);
      final r = result.data;
      if (r == null) {
        return false;
      }

      forumLag.value = result.latencyMs ?? 0;
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
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.setupSiteUrlEmpty,
      );
      return;
    }

    if (!pageController.hasClients) return;
    final normalizedUrl = StringUtil.normalizeSiteUrl(siteUrl);

    if (normalizedUrl == null) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.setupSiteUrlInvalid,
      );
      return;
    }

    isLoading.value = true;
    LogUtil.info("[Setup] Fetch forum info: $normalizedUrl");
    final ok = await _getForumInfo(normalizedUrl);
    isLoading.value = false;

    if (!ok) {
      final l10n = AppLocalizations.of(Get.context!)!;
      SnackbarUtils.showMessage(
        msg: l10n.setupNetworkError,
        title: l10n.setupFetchSiteInfoFailed,
      );
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
