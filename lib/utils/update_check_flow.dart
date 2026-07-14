import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/app_info.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/update_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> runGithubUpdateCheckFlow(
  BuildContext context, {
  bool silentIfLatest = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final appVersion = await AppInfo.version();
    final result = await UpdateHelper.checkGithubUpdate(
      owner: kGithubUpdateOwner,
      repo: kGithubUpdateRepo,
      appVersion: appVersion,
    );
    if (result == null) {
      if (context.mounted && !silentIfLatest) {
        SnackbarUtils.showError(msg: l10n.aboutUpdateCheckFailed);
      }
      return;
    }
    if (!context.mounted) return;
    if (!result.hasUpdate) {
      if (!silentIfLatest) {
        SnackbarUtils.showSuccess(msg: l10n.aboutAlreadyLatest);
      }
      return;
    }

    final release = result.release;
    final openDownload = await shared.SharedDialog.showContentDialog(
      context,
      title: release.title.isEmpty ? release.version : release.title,
      cancelText: l10n.commonActionCancel,
      confirmText: l10n.aboutDownloadUpdate,
      content: Builder(
        builder: (dialogContext) {
          return Column(
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
          );
        },
      ),
    );
    if (openDownload) {
      await launchUrlString(
        kGithubLatestReleaseUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (error, stackTrace) {
    LogUtil.errorE('[Update] Check update failed.', error, stackTrace);
    if (context.mounted && !silentIfLatest) {
      SnackbarUtils.showError(msg: l10n.aboutUpdateCheckFailed);
    }
  }
}
