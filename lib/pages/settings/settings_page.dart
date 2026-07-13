/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/foundation.dart';
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
            subtitle: l10n.settingsSubtitle,
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.settingsAppSection,
            children: [
              FUITile(
                icon: FUIIcons.settings,
                title: l10n.settingsCommonTitle,
                subtitle: l10n.settingsCommonSubtitle,
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const CommonSettingsPage(),
                ),
              ),
              FUITile(
                icon: FUIIcons.palette,
                title: l10n.settingsPersonalizeTitle,
                subtitle: l10n.settingsAppearanceSubtitle,
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const PersonalizeSettingsPage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.settingsSupportSection,
            children: [
              FUITile(
                icon: FUIIcons.info,
                title: l10n.aboutTitle,
                subtitle: l10n.settingsAboutSubtitle,
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const AboutPage(),
                ),
              ),
              if (kDebugMode)
                FUITile(
                  icon: FUIIcons.bug,
                  title: l10n.devMenuTitle,
                  subtitle: l10n.settingsDeveloperSubtitle,
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
