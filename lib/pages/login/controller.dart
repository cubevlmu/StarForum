/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;

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

  Future<void> startLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (account.isEmpty || password.isEmpty) {
      await shared.SharedDialog.showConfirmDialog(
        context,
        title: l10n.authLogin,
        content: l10n.authEmptyCredential,
        cancelText: '',
        confirmText: l10n.commonActionConfirm,
        variant: shared.SharedDialogVariant.warning,
      );
      return;
    }

    _setLoading(true);
    var clearLoadingInFinally = true;

    try {
      final r = await repo.login(
        account,
        password,
        autoRelogin: autoRelogin.value,
      );
      if (!context.mounted) return;
      if (!r) {
        LogUtil.error("[LoginPage] Login failed with empty response");
        await _showLoginFailedDialog(context, message: l10n.authLoginFailed);
        return;
      }

      if (repo.user == null) {
        LogUtil.error("[LoginPage] Empty user info response.");
        await _showLoginFailedDialog(context, message: l10n.authUserInfoError);
        return;
      }

      SnackbarUtils.showSuccess(
        msg: l10n.authLoginSuccess(repo.user?.displayName ?? ""),
      );
      await onLoginSuccess(repo.user!);
      Get.forceAppUpdate();

      if (!context.mounted) return;
      _setLoading(false);
      clearLoadingInFinally = false;
      if (closeToRootOnSuccess) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        FuiNavigation.closeCurrent(context, force: true);
      }
    } catch (e, st) {
      LogUtil.errorE("[LoginPage] Failed to login.", e, st);
      if (!context.mounted) return;
      await _showLoginFailedDialog(context, message: l10n.authLoginFailed);
    } finally {
      if (clearLoadingInFinally) {
        _setLoading(false);
      }
    }
  }

  Future<void> _showLoginFailedDialog(
    BuildContext context, {
    required String message,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return shared.SharedDialog.showConfirmDialog(
      context,
      title: l10n.authLoginFailed,
      content: message,
      cancelText: '',
      confirmText: l10n.commonActionConfirm,
      variant: shared.SharedDialogVariant.danger,
    );
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
