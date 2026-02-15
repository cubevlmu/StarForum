/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/pages/settings/about_page.dart';
import 'package:star_forum/pages/settings/personalize_page.dart';
import 'package:star_forum/pages/settings/common_page.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text("设置")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.tune_outlined, color: iconColor),
            title: const Text("通用"),
            onTap: () => Navigator.of(
              context,
            ).push(GetPageRoute(page: () => const CommonSettingsPage())),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            leading: Icon(Icons.color_lens_outlined, color: iconColor),
            title: const Text("外观"),
            onTap: () => Navigator.of(
              context,
            ).push(GetPageRoute(page: () => const PersonalizeSettingsPage())),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: const Text("关于"),
            onTap: () => Navigator.of(
              context,
            ).push(GetPageRoute(page: () => const AboutPage())),
          ),
        ],
      ),
    );
  }
}
