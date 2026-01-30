/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forum/data/model/users.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController();

  String account = "";
  String password = "";
  final repo = getIt<UserRepo>();
  bool isLoading = false;

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
      final r = await repo.login(account, password);
      if (!r) {
        log("[LoginPage] Login failed with empty response");
        Get.rawSnackbar(title: "登录", message: "网络错误或账号密码错误");
        return;
      }

      if (repo.user == null) {
        log("[LoginPage] Empty user info response.");
        Get.rawSnackbar(title: "登录", message: "获取用户信息错误");
        return;
      }

      /// 4️⃣ 登录成功
      Get.rawSnackbar(title: "登录", message: "成功! 用户:${repo.user?.displayName}");

      await onLoginSuccess(repo.user!);

      /// 返回首页
      Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    } catch (e, st) {
      log("登录失败", error: e, stackTrace: st);
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
