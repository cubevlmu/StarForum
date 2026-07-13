/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/forum_info.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';

class HomeController extends GetxController {
  HomeController();
  final cacheManager = CacheUtils.avatarCacheManager;
  final info = Rxn<ForumInfo>();

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final RxString avatarUrl = "".obs;
  final RxBool isLogin = false.obs;
  final userRepo = getIt<UserRepo>();
  final sessionState = getIt<SessionState>();
  final forumRepo = getIt<ForumRepository>();

  @override
  void onInit() {
    super.onInit();
    sessionState.state.addListener(_handleSessionChanged);
    _handleSessionChanged();

    LogUtil.info("[HomePage] Setting up user repo, checking user login status");
    _restoreInfo();
    _restoreLoginUser();
  }

  void _handleSessionChanged() {
    final session = sessionState.current;
    isLogin.value = session.isAuthenticated;
    avatarUrl.value = session.avatarUrl;
  }

  Future<void> _restoreLoginUser() async {
    await userRepo.setup();

    final state = userRepo.state;
    switch (state) {
      case .unknown:
        LogUtil.error("[HomePage] User repo init failed.");
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.homeUserServiceInitFailed,
        );
        return;
      case .loggedIn:
        break;
      case .notLogin:
        break;
      case .checkingToken:
        break;
      case .expired:
        LogUtil.error("[HomePage] User login is expired.");
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(
            Get.context!,
          )!.homeUserLoginExpiredNeedRelogin,
        );
        userRepo.logout();
        return;
    }
    if (userRepo.user == null) {
      return;
    }

    LogUtil.info(
      "[HomePage] Fetched user info, nickname :${userRepo.user!.displayName} avatar url:${avatarUrl.value}",
    );
  }

  @override
  void onClose() {
    sessionState.state.removeListener(_handleSessionChanged);
    refreshController.dispose();
    super.onClose();
  }

  void _restoreInfo() async {
    final cached = forumRepo.cachedForumInfo;
    if (cached != null) {
      info.value = cached;
      _updateDesktopWindowTitle(cached.title);
    }
    final result = await forumRepo.getForumInfo(forumRepo.baseUrl);
    final r = result.data;
    if (r == null) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.homeForumInfoFetchFailed,
      );
      return;
    }
    info.value = r;
    _updateDesktopWindowTitle(r.title);
    LogUtil.info("[HomePage] Forum latency ${result.latencyMs ?? 0}");
  }

  Future<void> _updateDesktopWindowTitle(String forumTitle) async {
    final isDesktopPlatform =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
    if (!isDesktopPlatform) {
      return;
    }
    await windowManager.setTitle("StarForum - $forumTitle");
  }
}
