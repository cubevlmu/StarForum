/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/pages/main/view.dart';
import 'package:star_forum/pages/setup/view.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

class SplashScreenController extends GetxController {
  final state = "".obs;
  bool _isHalt = false;

  @override
  void onInit() {
    super.onInit();

    _init();
  }

  void _init() async {
    state.value = "初始化网络中...";
    LogUtil.info("[Splash] Begin to setup api service.");
    final isApiSetup = await Api.setup();

    if (isApiSetup) {
      final repo = getIt<UserRepo>();
      state.value = "同步用户数据...";
      LogUtil.info("[Splash] Begin to setup user service.");
      await repo.setup();

      state.value = "同步标签信息...";
      LogUtil.info("[Splash] Begin sync tags.");
      final tag = getIt<TagRepo>();
      await tag.syncTags();
    } else {
      _isHalt = true;
      LogUtil.info("[Splash] App api url is not setup. Call setup page.");
    }
    state.value = "同步完毕";

    final context = Get.context;
    if (context == null) {
      SnackbarUtils.showMessage(msg: "初始化视图错误");
      return;
    }

    if (!context.mounted) return;
    if (_isHalt) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SetupPage(isSetup: true)),
        (route) => false,
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (route) => false,
    );
  }
}
