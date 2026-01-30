/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final String authorUrl = "https://github.com/cubevlmu";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("关于")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("版本"),
            subtitle: Text("1.0.0"),
            trailing: TextButton(
              child: const Text("检查更新"),
              onPressed: () {
                // SettingsUtil.checkUpdate(context);
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: const Text("作者"),
            subtitle: const Text("cubevlmu @ flybird studio"),
            onTap: () {
              // launchUrlString(authorUrl);
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: authorUrl));
              ScaffoldMessenger.of(context);
              Get.rawSnackbar(message: '已复制$authorUrl到剪切板');
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          // ListTile(
          //   title: const Text("项目链接"),
          //   subtitle: Text(projectUrl),
          //   onTap: () {
          //     // launchUrlString(projectUrl);
          //   },
          //   onLongPress: () {
          //     Clipboard.setData(ClipboardData(text: projectUrl));
          //     ScaffoldMessenger.of(context);
          //     Get.rawSnackbar(message: '已复制$projectUrl到剪切板');
          //   },
          // ),
          ListTile(
            title: const Text("许可"),
            onTap: () => Navigator.push(
              context,
              GetPageRoute(
                page: () => const LicensePage(
                  applicationIcon: ImageIcon(
                    AssetImage("assets/images/icon.png"),
                    size: 200,
                  ),
                  applicationName: "StarForum",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
