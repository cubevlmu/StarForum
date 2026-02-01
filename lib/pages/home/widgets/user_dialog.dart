/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/home/controller.dart';
import 'package:forum/pages/login/view.dart';
import 'package:forum/pages/main/controller.dart';
import 'package:forum/pages/settings/settings_page.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/widgets/shared_dialog.dart';
import 'package:get/get.dart';
import 'package:nil/nil.dart';

class UserDialogWidget extends StatelessWidget {
  const UserDialogWidget({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
          ),
          Obx(() {
            if (!controller.isLogin.value) {
              return ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text("登录"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              );
            } else {
              return ListTile(
                leading: Icon(Icons.account_circle_outlined),
                title: Text("个人中心"),
                onTap: () {
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
                    SnackbarUtils.showMessage("打开失败");
                  }
                },
              );
            }
          }),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text("设置"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
          Obx(() {
            if (controller.isLogin.value) {
              return ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text("登出"),
                onTap: () {
                  Navigator.pop(context);
                  final repo = getIt<UserRepo>();

                  SharedDialog.showDialog2(
                    context,
                    "登出",
                    "是否要登出账号?",
                    "取消",
                    () => Navigator.pop(context, 'Cancel'),
                    "确认",
                    () async {
                      await repo.logout();
                      SnackbarUtils.showMessage("登出成功!");
                      Navigator.pop(context, 'OK');
                    },
                  );
                },
              );
            } else {
              return nil;
            }
          }),
        ],
      ),
    );
  }
}
