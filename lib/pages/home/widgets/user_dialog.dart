/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/login/view.dart';
import 'package:star_forum/pages/settings/settings_page.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/widgets/shared_dialog.dart';

class UserDialogWidget extends StatelessWidget {
  const UserDialogWidget({
    super.key,
    required this.controller,
    required this.navigationContext,
  });

  final HomeController controller;
  final BuildContext navigationContext;

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
          FUITile(
            icon: FUIIcons.login,
            title: AppLocalizations.of(context)!.authLogin,
            onTap: () => _onLoginBtn(context),
          ),
        if (controller.isLogin.value)
          FUITile(
            icon: FUIIcons.person,
            title: AppLocalizations.of(context)!.userCenter,
            onTap: () => _onSelfPage(context),
          ),
        FUITile(
          icon: FUIIcons.settings,
          title: AppLocalizations.of(context)!.commonActionSettings,
          onTap: () => _onSettingBtn(context),
        ),
        if (controller.isLogin.value)
          FUITile(
            icon: FUIIcons.logout,
            title: AppLocalizations.of(context)!.authLogout,
            onTap: () => _onLogoutBtn(context),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _onLoginBtn(BuildContext context) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!navigationContext.mounted) return;
      FuiNavigation.openDetail(
        navigationContext,
        builder: (_) => const LoginPage(embedded: true),
      );
    });
  }

  void _onSelfPage(BuildContext context) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!navigationContext.mounted) return;
      final userId = controller.userRepo.userId;
      if (userId <= 0) {
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(navigationContext)!.commonNoticeOpenFailed,
        );
        return;
      }
      FuiNavigation.openDetail(
        navigationContext,
        builder: (_) => UserPage(userId: userId, embedded: true),
      );
    });
  }

  void _onSettingBtn(BuildContext context) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!navigationContext.mounted) return;
      FuiNavigation.openDetail(
        navigationContext,
        builder: (_) => const SettingsPage(),
      );
    });
  }

  void _onLogoutBtn(BuildContext context) {
    Navigator.pop(context);
    SharedDialog.showLogoutDialog(context);
  }
}
