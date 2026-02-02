/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/users.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/log_util.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController();

  String account = "";
  String password = "";
  RxBool autoRelogin = true.obs;
  RxBool obscurePassword = true.obs;

  final repo = getIt<UserRepo>();
  bool isLoading = false;

  void togglePasswordVisible() {
    obscurePassword.value = !obscurePassword.value;
  }

  void _setLoading(bool value) {
    isLoading = value;
    update(["password_login"]);
  }

  void startLogin() async {
    if (account.isEmpty || password.isEmpty) {
      Get.rawSnackbar(title: "登录", message: "账号或密码不能为空");
      return;
    }

    _setLoading(true);

    try {
      final r = await repo.login(
        account,
        password,
        autoRelogin: autoRelogin.value,
      );
      if (!r) {
        LogUtil.error("[LoginPage] Login failed with empty response");
        Get.rawSnackbar(title: "登录", message: "网络错误或账号密码错误");
        return;
      }

      if (repo.user == null) {
        LogUtil.error("[LoginPage] Empty user info response.");
        Get.rawSnackbar(title: "登录", message: "获取用户信息错误");
        return;
      }

      Get.rawSnackbar(title: "登录", message: "成功! 用户:${repo.user?.displayName}");
      await onLoginSuccess(repo.user!);

      Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    } catch (e, st) {
      LogUtil.errorE("[LoginPage] Failed to login.", e, st);
      Get.rawSnackbar(title: "登录", message: "网络错误或账号密码错误");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> onLoginSuccess(UserInfo user) {
    return Future.sync(() {});
  }

  void _initData() {
    update(["password_login"]);
  }

  void onTap() {}

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
