/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/account/controller.dart';
import 'package:forum/pages/settings/settings_page.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/widgets/shared_dialog.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:get/get.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late AccountPageController controller;

  @override
  void initState() {
    controller = Get.put(AccountPageController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<AccountPageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("用户"),
        actions: [
          Obx(() {
            if (controller.isLogin.value) {
              return IconButton(
                onPressed: () {
                  SharedDialog.showDialog2(
                    context,
                    "登出",
                    "是否要登出账号?",
                    "取消",
                    () => Navigator.pop(context, 'Cancel'),
                    "确认",
                    () async {
                      await controller.repo.logout();
                      SnackbarUtils.showMessage("登出成功!");
                      Navigator.pop(context, 'OK');
                    },
                  );
                },
                icon: Icon(Icons.logout_outlined),
              );
            }
            return const SizedBox();
          }),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
            icon: Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (!controller.isLogin.value) {
          return SharedNotice.onNotLogin(context, "你还没有登录", "请登录你的账户来查看个人信息");
        } else {
          return UserPage(userId: controller.getTrueId(), isAccountPage: true);
        }
      }),
    );
  }
}
