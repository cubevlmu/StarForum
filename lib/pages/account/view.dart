/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/account/controller.dart';
import 'package:forum/pages/settings/settings_page.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/widgets/shared_dialog.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:get/get.dart';

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
    controller = Get.put(AccountPageController());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: _AccountPageTitle(controller: controller),
      body: Obx(() {
        if (!controller.isLogin.value) {
          return const NotLoginNotice(
            title: "你还没有登录",
            tipsText: "请登录你的账户来查看个人信息",
          );
        } else {
          return UserPage(userId: controller.getTrueId(), isAccountPage: true);
        }
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _AccountPageTitle extends StatelessWidget implements PreferredSizeWidget {
  final AccountPageController controller;

  const _AccountPageTitle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("用户"),
      actions: [
        Obx(() {
          if (controller.isLogin.value) {
            return IconButton(
              onPressed: () => _onLogOut(context),
              icon: const Icon(Icons.logout_outlined),
            );
          }
          return SizedBox.shrink();
        }),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _onLogOut(BuildContext context) {
    SharedDialog.showLogoutDialog(context);
  }
}
