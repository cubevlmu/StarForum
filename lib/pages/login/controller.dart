/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

class LoginController extends GetxController {
  LoginController({
    this.onLoginSuccessCallback,
    this.closeToRootOnSuccess = true,
  });

  String account = "";
  String password = "";
  RxBool autoRelogin = true.obs;
  RxBool obscurePassword = true.obs;
  final Future<void> Function(UserInfo user)? onLoginSuccessCallback;
  final bool closeToRootOnSuccess;

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
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.authEmptyCredential,
      );
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
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.authLoginFailed,
        );
        return;
      }

      if (repo.user == null) {
        LogUtil.error("[LoginPage] Empty user info response.");
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.authUserInfoError,
        );
        return;
      }

      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(
          Get.context!,
        )!.authLoginSuccess(repo.user?.displayName ?? ""),
      );
      await onLoginSuccess(repo.user!);

      if (closeToRootOnSuccess) {
        Navigator.of(Get.context!).popUntil((route) => route.isFirst);
      }
    } catch (e, st) {
      LogUtil.errorE("[LoginPage] Failed to login.", e, st);
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.authLoginFailed,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> onLoginSuccess(UserInfo user) {
    return onLoginSuccessCallback?.call(user) ?? Future.sync(() {});
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
