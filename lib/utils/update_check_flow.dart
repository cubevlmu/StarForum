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
        await _showReleaseNotes(
          context,
          release: result.release,
          title: l10n.aboutLatestVersionStatus,
          versionLabel: l10n.aboutInstalledVersionLabel(appVersion),
          closeText: l10n.commonActionClose,
        );
      }
      return;
    }

    final release = result.release;
    final openDownload = await shared.SharedDialog.showContentDialog(
      context,
      title: l10n.aboutUpdateAvailableStatus,
      cancelText: l10n.commonActionCancel,
      confirmText: l10n.aboutDownloadUpdate,
      content: _ReleaseNotesContent(
        releaseTitle: release.title,
        versionLabel: l10n.aboutUpdateVersionLabel(release.version),
        description: release.description.trim().isEmpty
            ? l10n.aboutUpdateNoDescription
            : release.description.trim(),
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

Future<void> _showReleaseNotes(
  BuildContext context, {
  required GithubReleaseInfo release,
  required String title,
  required String versionLabel,
  required String closeText,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await shared.SharedDialog.showContentDialog(
    context,
    title: title,
    cancelText: '',
    confirmText: closeText,
    content: _ReleaseNotesContent(
      versionLabel: versionLabel,
      description: release.description.trim().isEmpty
          ? l10n.aboutUpdateNoDescription
          : release.description.trim(),
    ),
  );
}

class _ReleaseNotesContent extends StatelessWidget {
  const _ReleaseNotesContent({
    this.releaseTitle = '',
    required this.versionLabel,
    required this.description,
  });

  final String releaseTitle;
  final String versionLabel;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (releaseTitle.trim().isNotEmpty) ...[
          Text(
            releaseTitle.trim(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          versionLabel,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SelectableText(description),
      ],
    );
  }
}
