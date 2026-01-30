/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeController extends GetxController {
  HomeController();
  CacheManager cacheManager = CacheUtils.avatarCacheManager;

  final List<Map<String, String>> tabsList = [
    {'text': '贴文', 'id': '', 'controller': 'PostListController'},
    {'text': '主题', 'id': '', 'controller': 'ThemeListController'},
  ];
  late TabController? tabController;
  final int tabInitIndex = 0;

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  RxString avatarUrl = "".obs;
  final userRepo = getIt<UserRepo>();

  @override
  void onInit() {
    super.onInit();

    log("首页初始化 开始检测用户登录");
    _restoreLoginUser();
  }

  Future<void> _restoreLoginUser() async {
    if (!await userRepo.setup()) {
      return;
    }
    if (userRepo.user == null) {
      return;
    }

    avatarUrl.value = userRepo.user!.avatarUrl;
    log("取得用户信息 用户名称:${userRepo.user!.displayName} 头像地址:${avatarUrl.value}");
  }
}
