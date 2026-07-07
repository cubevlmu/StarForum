/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/about_page.dart';
import 'package:star_forum/pages/settings/dev_page.dart';
import 'package:star_forum/pages/settings/personalize_page.dart';
import 'package:star_forum/pages/settings/common_page.dart';
import 'package:fin_ui/fin_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: l10n.commonActionSettings,
            subtitle: '管理论坛、外观和本地数据',
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: '应用设置',
            children: [
              FUITile(
                icon: FUIIcons.settings,
                title: l10n.settingsCommonTitle,
                subtitle: '语言、更新、缓存和站点',
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const CommonSettingsPage(),
                ),
              ),
              FUITile(
                icon: FUIIcons.palette,
                title: l10n.settingsPersonalizeTitle,
                subtitle: '主题和字体大小',
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const PersonalizeSettingsPage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: '支持',
            children: [
              FUITile(
                icon: FUIIcons.info,
                title: l10n.aboutTitle,
                subtitle: '版本、项目链接和许可',
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const AboutPage(),
                ),
              ),
              FUITile(
                icon: FUIIcons.bug,
                title: l10n.devMenuTitle,
                subtitle: '调试工具、日志导出和组件预览',
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const DevSettingPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
