/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/forum_info.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeController extends GetxController {
  HomeController();
  final cacheManager = CacheUtils.avatarCacheManager;

  final List<Map<String, String>> tabsList = [
    {'text': '贴文', 'id': '', 'controller': 'PostListController'},
    {'text': '主题', 'id': '', 'controller': 'ThemeListController'},
  ];
  late TabController? tabController;
  final int tabInitIndex = 0;
  final info = Rxn<ForumInfo>();

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final RxString avatarUrl = "".obs;
  final RxBool isLogin = false.obs;
  final userRepo = getIt<UserRepo>();

  @override
  void onInit() {
    super.onInit();

    LogUtil.info("[HomePage] Setting up user repo, checking user login status");
    _restoreInfo();
    _restoreLoginUser();
  }

  Future<void> _restoreLoginUser() async {
    await userRepo.setup();

    final state = userRepo.state;
    switch (state) {
      case .unknown:
        LogUtil.error("[HomePage] User repo init failed.");
        SnackbarUtils.showMessage(msg: "用户服务初始化失败");
        return;
      case .loggedIn:
        isLogin.value = true;
        break;
      case .notLogin:
        isLogin.value = false;
        break;
      case .checkingToken:
        break;
      case .expired:
        LogUtil.error("[HomePage] User login is expired.");
        SnackbarUtils.showMessage(msg: "用户登录状态过期!请重新登录");
        userRepo.logout();
        return;
    }
    if (userRepo.user == null) {
      return;
    }

    avatarUrl.value = userRepo.user!.avatarUrl;
    LogUtil.info(
      "[HomePage] Fetched user info, nickname :${userRepo.user!.displayName} avatar url:${avatarUrl.value}",
    );
  }
  
  void _restoreInfo() async {
    final (r, l) = await Api.getForumInfo(Api.getBaseUrl);
    if (r == null) {
      SnackbarUtils.showMessage(msg: "论坛信息获取失败...");
      return;
    }
    info.value = r;
    LogUtil.info("[HomePage] Forum latency $l");
  }
}
