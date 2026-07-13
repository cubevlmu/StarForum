import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/diagnostics/developer_diagnostics.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/widgets/forum/forum_asset_tile.dart';
import 'package:star_forum/widgets/forum/forum_badge_card.dart';
import 'package:star_forum/widgets/forum/forum_discussion_tile.dart';
import 'package:star_forum/widgets/forum/forum_post_card.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/shared_dialog.dart';

class DevSettingPage extends StatefulWidget {
  const DevSettingPage({super.key});

  @override
  State<DevSettingPage> createState() => _DevSettingPageState();
}

enum _ExportAction { database, settings }

class _DevSettingPageState extends State<DevSettingPage> {
  late final DeveloperDiagnosticsService _diagnostics;
  late Future<DeveloperDiagnosticsSnapshot> _snapshot;
  _ExportAction? _exporting;

  @override
  void initState() {
    super.initState();
    _diagnostics = DeveloperDiagnosticsService(getIt<AppDatabase>());
    _reload();
  }

  void _reload() {
    _snapshot = _diagnostics.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: l10n.devMenuTitle,
            subtitle: l10n.devSubtitle,
            trailing: FUIIconButton(
              icon: FUIIcons.refresh,
              tooltip: l10n.commonActionRefresh,
              variant: FUIIconButtonVariant.ghost,
              onPressed: () => setState(_reload),
            ),
          ),
          const SizedBox(height: FUITokens.gap16),
          _buildInformationSection(context),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.devToolsSection,
            children: [
              FUITile(
                icon: FUIIcons.apps,
                title: l10n.devNavigationTitle,
                subtitle: l10n.devNavigationSubtitle,
                onTap: () => _showPageSelector(context),
              ),
              FUITile(
                icon: FUIIcons.bug,
                title: l10n.devShareLogsTitle,
                subtitle: l10n.devShareLogsSubtitle,
                onTap: () => LogUtil.shareLog(day: DateTime.now()),
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.devExportSection,
            children: [
              FUITile(
                icon: ForumIcons.cache,
                title: l10n.devExportDatabaseTitle,
                subtitle: l10n.devExportDatabaseSubtitle,
                trailing: _exportTrailing(_ExportAction.database),
                onTap: _exporting == null
                    ? () => _exportDatabase(context)
                    : null,
              ),
              FUITile(
                icon: FUIIcons.settings,
                title: l10n.devExportSettingsTitle,
                subtitle: l10n.devExportSettingsSubtitle,
                trailing: _exportTrailing(_ExportAction.settings),
                onTap: _exporting == null
                    ? () => _exportSettings(context)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.devComponentPreviewSection,
            children: const [
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumAssetTile(
                  name: 'Asset tile',
                  subtitle: 'File information preview',
                  thumbnail: null,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumBadgeCard(
                  title: 'Badge card',
                  subtitle: 'Progress preview',
                  progress: 0.5,
                  progressLabel: '50%',
                  icon: ForumIcons.badge,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumDiscussionTile(
                  title: 'Discussion tile',
                  excerpt: 'Shared discussion component preview',
                  author: 'developer',
                  tags: ['debug', 'preview'],
                  replyCount: 10,
                  lastActivity: 'now',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(FUITokens.gap12),
                child: ForumPostCard(
                  author: 'Developer',
                  content: Text('Shared post card preview'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<DeveloperDiagnosticsSnapshot>(
      future: _snapshot,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return FUISection(
            title: l10n.devInformationSection,
            children: [
              FUITile(
                icon: FUIIcons.info,
                title: l10n.devClientInfoTitle,
                subtitle: snapshot.hasError
                    ? l10n.devInformationLoadFailed
                    : l10n.refreshLoading,
                trailing: snapshot.hasError
                    ? FUIIconButton(
                        icon: FUIIcons.refresh,
                        tooltip: l10n.commonActionRefresh,
                        variant: FUIIconButtonVariant.ghost,
                        onPressed: () => setState(_reload),
                      )
                    : const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
            ],
          );
        }

        final osVersion = data.operatingSystemVersion.replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
        return FUISection(
          title: l10n.devInformationSection,
          children: [
            FUITile(
              icon: FUIIcons.info,
              title: l10n.devClientInfoTitle,
              subtitle: l10n.devClientInfoSubtitle(
                data.appName,
                data.versionLabel,
                data.packageName,
                data.buildMode,
                data.databaseSchemaVersion,
                data.dataVersion,
                data.settingsCount,
              ),
              showChevron: false,
            ),
            FUITile(
              icon: FUIIcons.apps,
              title: l10n.devSystemInfoTitle,
              subtitle: l10n.devSystemInfoSubtitle(
                data.operatingSystem,
                data.processorCount,
                data.localeName,
                data.dartVersion,
                osVersion,
              ),
              showChevron: false,
            ),
            FUITile(
              icon: ForumIcons.cache,
              title: l10n.devStorageInfoTitle,
              subtitle: l10n.devStorageInfoSubtitle(
                StringUtil.byteNumToFileSize(data.totalBytes.toDouble()),
                StringUtil.byteNumToFileSize(data.supportBytes.toDouble()),
                StringUtil.byteNumToFileSize(data.databaseBytes.toDouble()),
                StringUtil.byteNumToFileSize(data.cacheBytes.toDouble()),
              ),
              showChevron: false,
            ),
          ],
        );
      },
    );
  }

  Widget? _exportTrailing(_ExportAction action) {
    if (_exporting != action) return null;
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Future<void> _exportDatabase(BuildContext context) async {
    await _exportAndShare(
      context,
      action: _ExportAction.database,
      createFile: _diagnostics.exportDatabase,
      mimeType: 'application/vnd.sqlite3',
    );
  }

  Future<void> _exportSettings(BuildContext context) async {
    await _exportAndShare(
      context,
      action: _ExportAction.settings,
      createFile: _diagnostics.exportSettings,
      mimeType: 'application/json',
    );
  }

  Future<void> _exportAndShare(
    BuildContext context, {
    required _ExportAction action,
    required Future<File> Function() createFile,
    required String mimeType,
  }) async {
    if (_exporting != null) return;
    setState(() => _exporting = action);
    try {
      final file = await createFile();
      if (!context.mounted) return;
      final renderBox = context.findRenderObject();
      final origin = renderBox is RenderBox
          ? renderBox.localToGlobal(Offset.zero) & renderBox.size
          : null;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        text: action == _ExportAction.database
            ? AppLocalizations.of(context)!.devExportDatabaseTitle
            : AppLocalizations.of(context)!.devExportSettingsTitle,
        sharePositionOrigin: origin,
      );
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[Developer] Failed to export diagnostics.',
        error,
        stackTrace,
      );
      if (context.mounted) {
        SnackbarUtils.showError(
          msg: AppLocalizations.of(context)!.devExportFailed,
          context: context,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = null);
    }
  }

  Future<void> _showPageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FUITile(
                icon: FUIIcons.person,
                title: 'UserPage',
                subtitle: l10n.devUserIdNavigationSubtitle,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openUserPage(context);
                },
              ),
              FUITile(
                icon: ForumIcons.forum,
                title: 'DiscussionPage',
                subtitle: l10n.devDiscussionNavigationSubtitle,
                onTap: () {
                  Navigator.pop(sheetContext);
                  FuiNavigation.openDetail(
                    context,
                    builder: (_) => PostPage(
                      item: DiscussionSummary(
                        id: '0',
                        title: 'TEMP',
                        excerpt: '<h1>TEMP</h1>',
                        lastPostedAt: DateTime.utc(1980),
                        createdAt: DateTime.utc(1980),
                        userId: 0,
                        subscription: 0,
                      ),
                      embedded: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openUserPage(BuildContext context) {
    SharedDialog.showNumberDialog(
      context,
      'UserId',
      '-1 for invalid, -2 for not login',
      'Cancel',
      () {},
      'Open',
      (id) => FuiNavigation.openDetail(
        context,
        builder: (_) => UserPage(userId: id, embedded: true),
      ),
    );
  }
}
