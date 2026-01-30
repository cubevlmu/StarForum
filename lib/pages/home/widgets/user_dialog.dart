/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/login/view.dart';
import 'package:forum/pages/settings/settings_page.dart';
import 'package:get/get.dart';

class UserDialogWidget extends StatelessWidget {
  const UserDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<UserRepo>();

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
          if (!repo.isLogin())
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text("登录"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
          if (repo.isLogin())
            ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: Text("个人中心"),
              onTap: () {},
            ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text("设置"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
          if (repo.isLogin())
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text("登出"),
              onTap: () {
                final repo = getIt<UserRepo>();

                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('登出'),
                    content: const Text('要登出账户嘛'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          final r = repo.logout();
                          Get.showSnackbar(
                            GetSnackBar(message: r ? "登出成功!" : "登出失败!"),
                          );
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
