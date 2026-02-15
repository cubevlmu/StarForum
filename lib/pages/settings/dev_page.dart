/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_detail/view.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/pages/settings/widgets/settings_label.dart';
import 'package:forum/widgets/shared_dialog.dart';
import 'package:get/get.dart';

class DevSettingPage extends StatelessWidget {
  const DevSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("开发者菜单")),
      body: ListView(
        children: [
          const SettingsLabel(text: 'Dev'),
          ListTile(
            title: const Text("Navigate to"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  scrollable: true,
                  title: const Text("Page select"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("cancel"),
                    ),
                  ],
                  contentPadding: EdgeInsets.zero,
                  content: Column(children: _buildDevPages(context)),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text("Share logs"),
            onTap: () {
              LogUtil.shareLog(day: DateTime.now());
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(title: Text("Set apiBase"), onTap: () => _onSetApibase(context)),
        ],
      ),
    );
  }

  List<Widget> _buildDevPages(BuildContext context) {
    return [
      ListTile(
        title: const Text("UserPage"),
        onTap: () => {
          SharedDialog.showNumberDialog(
            context,
            "UserId",
            "-1 for invalid -2 for not login",
            "cancel",
            () {},
            "submit",
            (i) {
              Navigator.of(
                context,
              ).push(GetPageRoute(page: () => UserPage(userId: i)));
            },
          ),
        },
      ),
      const Divider(height: 1, thickness: 0.5),
      ListTile(
        title: const Text("DiscussionPage"),
        onTap: () => {
          Navigator.of(context).push(
            GetPageRoute(
              page: () => PostPage(
                item: DiscussionItem(
                  id: "0",
                  title: "TEMP",
                  excerpt: "<h1>TEMP</h1>",
                  lastPostedAt: DateTime.utc(1980),
                  userId: 0,
                ),
              ),
            ),
          ),
        },
      ),
      const Divider(height: 1, thickness: 0.5),
    ];
  }

  void _onSetApibase(BuildContext context) {
    // SharedDialog.showInputDialog(
    //   context,
    //   "UserId",
    //   "-1 for invalid -2 for not login",
    //   "cancel",
    //   () {},
    //   "submit",
    //   (i) {
    //     ApiConstants.apiBase = i;
    //     SnackbarUtils.showMessage(msg: "Set to ${ApiConstants.apiBase}", title: "Done.");
    //   },
    // );
  }
}
