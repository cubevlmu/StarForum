import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/repository/local_cache_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:fin_ui/fin_ui.dart';

class CacheManagementPage extends StatefulWidget {
  const CacheManagementPage({super.key});

  @override
  State<CacheManagementPage> createState() => _CacheManagementPageState();
}

class _CacheManagementPageState extends State<CacheManagementPage> {
  final LocalCacheRepository _localCacheRepo = getIt<LocalCacheRepository>();
  late Future<_CacheSnapshot> _snapshot;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _snapshot = _loadSnapshot();
  }

  Future<_CacheSnapshot> _loadSnapshot() async {
    final l10n = AppLocalizations.of(context)!;
    final summaries = await _localCacheRepo.summaries();
    final imageItems = await Future.wait([
      _imageCacheItem(
        label: l10n.cacheAvatarImageTitle,
        description: l10n.cacheAvatarImageDesc,
        key: CacheUtils.userAvatar,
        icon: ForumIcons.profile,
        clear: () => CacheUtils.avatarCacheManager.store.emptyCache(),
      ),
      _imageCacheItem(
        label: l10n.cacheContentImageTitle,
        description: l10n.cacheContentImageDesc,
        key: CacheUtils.contentImage,
        icon: ForumIcons.image,
        clear: () => CacheUtils.contentCacheManager.store.emptyCache(),
      ),
      _imageCacheItem(
        label: l10n.cacheAssetThumbTitle,
        description: l10n.cacheAssetThumbDesc,
        key: CacheUtils.assetThumb,
        icon: ForumIcons.attachment,
        clear: () => CacheUtils.assetThumbCacheManager.store.emptyCache(),
      ),
    ]);

    return _CacheSnapshot(
      dataItems: [
        for (final summary in summaries)
          _CacheItem.data(
            label: summary.category.label(l10n),
            description: summary.category.description(l10n),
            icon: summary.category.icon,
            count: summary.count,
            clear: () => _localCacheRepo.clear(summary.category),
          ),
      ],
      imageItems: imageItems,
    );
  }

  Future<_CacheItem> _imageCacheItem({
    required String label,
    required String description,
    required String key,
    required IconData icon,
    required Future<void> Function() clear,
  }) async {
    final dir = await _cacheDirForKey(key);
    final size = dir == null ? 0 : await _directorySize(dir);
    return _CacheItem.files(
      label: label,
      description: description,
      icon: icon,
      bytes: size,
      clear: clear,
    );
  }

  Future<Directory?> _cacheDirForKey(String key) async {
    final temp = await getTemporaryDirectory();
    final candidates = <Directory>[
      Directory('${temp.path}/$key'),
      Directory('${temp.path}/libCachedImageData/$key'),
    ];
    for (final dir in candidates) {
      if (await dir.exists()) return dir;
    }
    return null;
  }

  Future<int> _directorySize(Directory dir) async {
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      try {
        total += await entity.length();
      } catch (_) {}
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: l10n.settingsCacheManagement,
            subtitle: l10n.cacheManagementSafeSubtitle,
            trailing: FUIIconButton(
              icon: FUIIcons.refresh,
              tooltip: l10n.commonActionRefresh,
              variant: FUIIconButtonVariant.ghost,
              onPressed: () => setState(_reload),
            ),
          ),
          const SizedBox(height: FUITokens.gap16),
          FutureBuilder<_CacheSnapshot>(
            future: _snapshot,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data ?? const _CacheSnapshot.empty();
              return Column(
                children: [
                  FUISection(
                    title: l10n.cacheStorageOverviewTitle,
                    children: [
                      FUITile(
                        icon: ForumIcons.cache,
                        title: l10n.cacheRecordsCount(data.totalRecords),
                        subtitle: l10n.cacheImagesSize(
                          StringUtil.byteNumToFileSize(
                            data.totalBytes.toDouble(),
                          ),
                        ),
                        showChevron: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: FUITokens.gap16),
                  _CacheSection(
                    title: l10n.cacheLocalDataSectionTitle,
                    items: data.dataItems,
                    onClear: _clearItem,
                  ),
                  const SizedBox(height: FUITokens.gap16),
                  _CacheSection(
                    title: l10n.cacheImageFileSectionTitle,
                    items: data.imageItems,
                    onClear: _clearItem,
                  ),
                  const SizedBox(height: FUITokens.gap16),
                  FUISection(
                    title: l10n.cacheClearAllSectionTitle,
                    children: [
                      FUITile(
                        icon: FUIIcons.delete,
                        title: l10n.cacheClearAllTitle,
                        subtitle: l10n.cacheClearAllSubtitle,
                        onTap: _clearAll,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearItem(_CacheItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await shared.SharedDialog.showConfirmDialog(
      context,
      title: l10n.dialogConfirmTitle,
      content: '${l10n.dialogDeleteCacheConfirm}\n${item.label}',
      cancelText: l10n.dialogNo,
      confirmText: l10n.dialogYes,
      variant: shared.SharedDialogVariant.danger,
    );
    if (!confirmed) return;
    try {
      await item.clear();
      CacheUtils.clearAllCacheImageMem();
      if (mounted) setState(_reload);
    } catch (_) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticeDeleteFailed);
    }
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await shared.SharedDialog.showConfirmDialog(
      context,
      title: l10n.dialogConfirmTitle,
      content: l10n.dialogClearCacheConfirm,
      cancelText: l10n.dialogNo,
      confirmText: l10n.dialogYes,
      variant: shared.SharedDialogVariant.danger,
    );
    if (!confirmed) return;
    try {
      await _localCacheRepo.clearAll();
      for (final manager in CacheUtils.cacheMangerList) {
        await manager.store.emptyCache();
      }
      CacheUtils.clearAllCacheImageMem();
      if (mounted) setState(_reload);
    } catch (_) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticeDeleteFailed);
    }
  }
}

class _CacheSection extends StatelessWidget {
  const _CacheSection({
    required this.title,
    required this.items,
    required this.onClear,
  });

  final String title;
  final List<_CacheItem> items;
  final ValueChanged<_CacheItem> onClear;

  @override
  Widget build(BuildContext context) {
    return FUISection(
      title: title,
      children: [
        for (final item in items)
          FUITile(
            icon: item.icon,
            title: item.label,
            subtitle: item.subtitle,
            showChevron: item.hasContent,
            onTap: item.hasContent ? () => onClear(item) : null,
          ),
      ],
    );
  }
}

class _CacheSnapshot {
  const _CacheSnapshot({required this.dataItems, required this.imageItems});
  const _CacheSnapshot.empty() : dataItems = const [], imageItems = const [];

  final List<_CacheItem> dataItems;
  final List<_CacheItem> imageItems;

  int get totalRecords => dataItems.fold(0, (sum, item) => sum + item.count);
  int get totalBytes => imageItems.fold(0, (sum, item) => sum + item.bytes);
}

class _CacheItem {
  const _CacheItem._({
    required this.label,
    required this.description,
    required this.icon,
    required this.count,
    required this.bytes,
    required this.clear,
  });

  factory _CacheItem.data({
    required String label,
    required String description,
    required IconData icon,
    required int count,
    required Future<void> Function() clear,
  }) {
    return _CacheItem._(
      label: label,
      description: description,
      icon: icon,
      count: count,
      bytes: 0,
      clear: clear,
    );
  }

  factory _CacheItem.files({
    required String label,
    required String description,
    required IconData icon,
    required int bytes,
    required Future<void> Function() clear,
  }) {
    return _CacheItem._(
      label: label,
      description: description,
      icon: icon,
      count: 0,
      bytes: bytes,
      clear: clear,
    );
  }

  final String label;
  final String description;
  final IconData icon;
  final int count;
  final int bytes;
  final Future<void> Function() clear;

  bool get hasContent => count > 0 || bytes > 0;

  String get subtitle {
    if (bytes > 0) {
      final size = StringUtil.byteNumToFileSize(bytes.toDouble());
      return '$size · $description';
    }
    return '$count · $description';
  }
}

extension _LocalCacheCategoryView on LocalCacheCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case LocalCacheCategory.discussions:
        return l10n.cacheDiscussionsTitle;
      case LocalCacheCategory.posts:
        return l10n.cachePostsTitle;
      case LocalCacheCategory.users:
        return l10n.cacheUsersTitle;
      case LocalCacheCategory.tags:
        return l10n.cacheTagsTitle;
      case LocalCacheCategory.notifications:
        return l10n.cacheNotificationsTitle;
      case LocalCacheCategory.collections:
        return l10n.cacheCollectionsTitle;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case LocalCacheCategory.discussions:
        return l10n.cacheDiscussionsDesc;
      case LocalCacheCategory.posts:
        return l10n.cachePostsDesc;
      case LocalCacheCategory.users:
        return l10n.cacheUsersDesc;
      case LocalCacheCategory.tags:
        return l10n.cacheTagsDesc;
      case LocalCacheCategory.notifications:
        return l10n.cacheNotificationsDesc;
      case LocalCacheCategory.collections:
        return l10n.cacheCollectionsDesc;
    }
  }

  IconData get icon {
    switch (this) {
      case LocalCacheCategory.discussions:
        return ForumIcons.forum;
      case LocalCacheCategory.posts:
        return ForumIcons.comments;
      case LocalCacheCategory.users:
        return ForumIcons.profile;
      case LocalCacheCategory.tags:
        return ForumIcons.tags;
      case LocalCacheCategory.notifications:
        return ForumIcons.notifications;
      case LocalCacheCategory.collections:
        return ForumIcons.cache;
    }
  }
}
