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
import 'package:star_forum/utils/update_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> runGithubUpdateCheckFlow(
  BuildContext context, {
  bool silentIfLatest = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  LogUtil.info('[Update] Start checking GitHub release update.');

  try {
    final result = await UpdateHelper.checkGithubUpdate(
      owner: kGithubUpdateOwner,
      repo: kGithubUpdateRepo,
      appVersion: kAppVersion,
    );

    if (result == null) {
      LogUtil.warn('[Update] Latest GitHub release fetch returned null.');
      if (!context.mounted || silentIfLatest) return;
      SnackbarUtils.showError(msg: l10n.aboutUpdateCheckFailed);
      return;
    }

    LogUtil.info(
      '[Update] Check complete. local=$kAppVersion remote=${result.release.version} hasUpdate=${result.hasUpdate}',
    );

    if (!context.mounted) return;

    if (!result.hasUpdate) {
      if (!silentIfLatest) {
        SnackbarUtils.showSuccess(msg: l10n.aboutAlreadyLatest);
      }
      return;
    }

    final release = result.release;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(release.title.isEmpty ? release.version : release.title),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.aboutUpdateVersionLabel(release.version),
                  style: Theme.of(
                    dialogContext,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  release.description.trim().isEmpty
                      ? l10n.aboutUpdateNoDescription
                      : release.description.trim(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonActionCancel),
          ),
          FilledButton(
            onPressed: () async {
              LogUtil.info(
                '[Update] Open release download page: $kGithubLatestReleaseUrl',
              );
              await launchUrlString(
                kGithubLatestReleaseUrl,
                mode: LaunchMode.externalApplication,
              );
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.aboutDownloadUpdate),
          ),
        ],
      ),
    );
  } catch (e, s) {
    LogUtil.errorE('[Update] Check update failed.', e, s);
    if (!context.mounted || silentIfLatest) return;
    SnackbarUtils.showError(msg: l10n.aboutUpdateCheckFailed);
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const String authorUrl = 'https://github.com/cubevlmu';
  static const String projectUrl = 'https://github.com/cubevlmu/StarForum';
  static int tapTimes = 0;

  bool _isCheckingUpdate = false;

  Future<void> _checkUpdate() async {
    if (_isCheckingUpdate) return;

    setState(() => _isCheckingUpdate = true);
    try {
      await runGithubUpdateCheckFlow(context, silentIfLatest: false);
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.aboutVersion),
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
                    }
                  }
                : null,
            subtitle: const Text(kAppVersion),
            trailing: TextButton(
              onPressed: _isCheckingUpdate ? null : _checkUpdate,
              child: _isCheckingUpdate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.aboutCheckUpdate),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(l10n.aboutAuthor),
            subtitle: const Text('cubevlmu @ flybird studio'),
            onTap: () => launchUrlString(authorUrl),
            onLongPress: () {
              Clipboard.setData(const ClipboardData(text: authorUrl));
              SnackbarUtils.showSuccess(
                msg: l10n.commonNoticeCopiedToClipboard(authorUrl),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(l10n.aboutProjectLink),
            subtitle: const Text(projectUrl),
            onTap: () => launchUrlString(projectUrl),
            onLongPress: () {
              Clipboard.setData(const ClipboardData(text: projectUrl));
              SnackbarUtils.showSuccess(
                msg: l10n.commonNoticeCopiedToClipboard(projectUrl),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(l10n.aboutLicense),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LicensePage(
                  applicationIcon: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Image(
                      image: AssetImage('assets/images/icon.png'),
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ),
                  applicationName: 'StarForum',
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(l10n.aboutAppLog),
            onTap: () => LogUtil.shareLog(day: DateTime.now()),
          ),
        ],
      ),
    );
  }
}
