/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/settings_page.dart';
import 'package:star_forum/pages/account/controller.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/shared_dialog.dart';
import 'package:star_forum/widgets/shared_notice.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with AutomaticKeepAliveClientMixin {
  late AccountPageController controller;

  @override
  void initState() {
    controller = Get.isRegistered<AccountPageController>()
        ? Get.find<AccountPageController>()
        : Get.put(AccountPageController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FUITokens.pagePadding,
              FUITokens.gap12,
              FUITokens.pagePadding,
              FUITokens.gap4,
            ),
            child: FuiPageHead(
              showNavigation: false,
              title: l10n.accountAppBarTitle,
              actions: [
                Obx(() {
                  if (!controller.isLogin.value) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FUIIconButton(
                        icon: FUIIcons.logout,
                        variant: FUIIconButtonVariant.ghost,
                        tooltip: l10n.commonActionLogout,
                        onPressed: () => SharedDialog.showLogoutDialog(context),
                      ),
                    ],
                  );
                }),
                FUIIconButton(
                  icon: FUIIcons.settings,
                  variant: FUIIconButtonVariant.ghost,
                  onPressed: () => FuiNavigation.openDetail(
                    context,
                    builder: (_) => const SettingsPage(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (!controller.isLogin.value) {
                return NotLoginNotice(
                  title: l10n.commonNotLoggedInTitle,
                  tipsText: l10n.authNotLoginTips,
                );
              }
              return UserPage(
                userId: controller.getTrueId(),
                isAccountPage: true,
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
