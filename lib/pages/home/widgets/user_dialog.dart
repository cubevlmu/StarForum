/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/login/view.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/main/controller.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/shared_dialog.dart';
import 'package:get/get.dart';

class UserDialogWidget extends StatelessWidget {
  const UserDialogWidget({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
        ),
        if (!controller.isLogin.value)
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: Text(AppLocalizations.of(context)!.authLogin),
            onTap: () => _onLoginBtn(context),
          ),
        if (controller.isLogin.value)
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(AppLocalizations.of(context)!.userCenter),
            onTap: () => _onSelfPage(context),
          ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(AppLocalizations.of(context)!.commonActionSettings),
          onTap: () => _onSettingBtn(context),
        ),
        if (controller.isLogin.value)
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: Text(AppLocalizations.of(context)!.authLogout),
            onTap: () => _onLogoutBtn(context),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _onLoginBtn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _onSelfPage(BuildContext context) {
    Navigator.pop(context);
    try {
      final cc = Get.find<MainController>();
      cc.selectedIndex.value = 2;
    } catch (e, s) {
      LogUtil.errorE(
        "[HomePage] Failed to navigate to user space page with error:",
        e,
        s,
      );
      SnackbarUtils.showMessage(msg: AppLocalizations.of(context)!.commonNoticeOpenFailed);
    }
  }

  void _onSettingBtn(BuildContext context) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = Get.context;
      if (currentContext == null) return;
      openSettingsAdaptive(currentContext);
    });
  }

  void _onLogoutBtn(BuildContext context) {
    Navigator.pop(context);
    SharedDialog.showLogoutDialog(context);
  }
}
