/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/settings/dev_page.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String authorUrl = "https://github.com/cubevlmu";
  static const String projectUrl = "https://github.com/cubevlmu/StarForum";
  static int tapTimes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.aboutTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.aboutVersion),
            onTap: kDebugMode
                ? () {
                    tapTimes += 1;
                    if (tapTimes == 5) {
                      tapTimes = 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DevSettingPage(),
                        ),
                      );
                      return;
                    }
                  }
                : null,
            subtitle: Text("1.1.5"),
            trailing: TextButton(
              child: Text(AppLocalizations.of(context)!.aboutCheckUpdate),
              onPressed: () {
                // SettingsUtil.checkUpdate(context);
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.aboutAuthor),
            subtitle: const Text("cubevlmu @ flybird studio"),
            onTap: () {
              launchUrlString(authorUrl);
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: authorUrl));
              SnackbarUtils.showSuccess(
                msg: AppLocalizations.of(
                  context,
                )!.commonNoticeCopiedToClipboard(authorUrl),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.aboutProjectLink),
            subtitle: Text(projectUrl),
            onTap: () {
              launchUrlString(projectUrl);
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: projectUrl));
              SnackbarUtils.showSuccess(
                msg: AppLocalizations.of(
                  context,
                )!.commonNoticeCopiedToClipboard(projectUrl),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.aboutLicense),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LicensePage(
                  applicationIcon: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Image(
                      image: AssetImage("assets/images/icon.png"),
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ),
                  applicationName: "StarForum",
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.aboutAppLog),
            onTap: () {
              LogUtil.shareLog(day: DateTime.now());
            },
          ),
        ],
      ),
    );
  }
}
