/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/about_page.dart';
import 'package:star_forum/pages/settings/personalize_page.dart';
import 'package:star_forum/pages/settings/common_page.dart';

class SettingsDialogNavigator extends StatefulWidget {
  const SettingsDialogNavigator({super.key});

  @override
  State<SettingsDialogNavigator> createState() => _SettingsDialogNavigatorState();
}

class _SettingsDialogNavigatorState extends State<SettingsDialogNavigator> {
  static const double _dialogToPageBreakPoint = 640;
  bool _didFallbackToPage = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final shouldFallbackToPage = width < _dialogToPageBreakPoint;
    if (shouldFallbackToPage && !_didFallbackToPage) {
      _didFallbackToPage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
      });
    }

    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(isDesktop: true),
          settings: settings,
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  final bool isDesktop;
  const SettingsPage({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isDesktop,
        leading: isDesktop
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              )
            : null,
        title: Text(AppLocalizations.of(context)!.commonActionSettings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.tune_outlined, color: iconColor),
            title: Text(AppLocalizations.of(context)!.settingsCommonTitle),
            onTap: () => Navigator.of(
              context,
            ).push(
              MaterialPageRoute(
                builder: (_) => const CommonSettingsPage(),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            leading: Icon(Icons.color_lens_outlined, color: iconColor),
            title: Text(AppLocalizations.of(context)!.settingsPersonalizeTitle),
            onTap: () => Navigator.of(
              context,
            ).push(
              MaterialPageRoute(
                builder: (_) => const PersonalizeSettingsPage(),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Text(AppLocalizations.of(context)!.aboutTitle),
            onTap: () => Navigator.of(
              context,
            ).push(
              MaterialPageRoute(
                builder: (_) => const AboutPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
