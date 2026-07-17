import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/app/local_controller.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/data/repository/local_cache_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/setup/view.dart';
import 'package:star_forum/pages/settings/cache_management_page.dart';
import 'package:star_forum/pages/settings/widgets/settings_toggle_tile.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/utils/app_language.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/utils/update_check_flow.dart';
import 'package:star_forum/widgets/shared_dialog.dart';

class CommonSettingsPage extends StatefulWidget {
  const CommonSettingsPage({super.key});

  @override
  State<CommonSettingsPage> createState() => _CommonSettingsPageState();
}

class _CommonSettingsPageState extends State<CommonSettingsPage> {
  bool _isCheckingUpdate = false;

  bool get _autoCheckUpdate => SettingsUtil.getValue(
    SettingsStorageKeys.autoCheckUpdate,
    defaultValue: true,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeController = Get.find<LocaleController>();
    final forumRepo = getIt<ForumRepository>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: l10n.settingsCommonTitle,
            subtitle: l10n.settingsCommonPageSubtitle,
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.settingsBehaviorSection,
            children: [
              SettingsToggleTile(
                icon: FUIIcons.update,
                title: l10n.settingsAutoCheckUpdate,
                subtitle: l10n.settingsAutoCheckUpdateDesc,
                value: _autoCheckUpdate,
                onChanged: (value) async {
                  await SettingsUtil.setValue(
                    SettingsStorageKeys.autoCheckUpdate,
                    value,
                  );
                  if (mounted) setState(() {});
                },
              ),
              SettingsToggleTile(
                icon: ForumIcons.sticky,
                title: l10n.settingsKeepStickyDiscussionsOnTop,
                subtitle: l10n.settingsKeepStickyDiscussionsOnTopDesc,
                value: SettingsUtil.keepStickyDiscussionsOnTop,
                onChanged: (value) async {
                  await SettingsUtil.changeKeepStickyDiscussionsOnTop(value);
                  if (mounted) setState(() {});
                },
              ),
              FUITile(
                icon: FUIIcons.update,
                title: l10n.aboutCheckUpdate,
                subtitle: l10n.settingsCheckUpdateDesc,
                showChevron: false,
                trailing: _isCheckingUpdate
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isCheckingUpdate ? null : _checkUpdate,
              ),
              Obx(() {
                final locale =
                    localeController.locale ??
                    Localizations.maybeLocaleOf(context) ??
                    languages.first.locale;
                final language = appLanguageForLocale(locale);
                return FUITile(
                  icon: FUIIcons.palette,
                  title: l10n.settingsLanguage,
                  subtitle: language.label(context),
                  onTap: () => _selectLanguage(
                    context,
                    current: language.locale,
                    onChanged: localeController.changeLocale,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: l10n.settingsDataSection,
            children: [
              FUITile(
                icon: ForumIcons.cache,
                title: l10n.settingsDataManagement,
                subtitle: l10n.settingsCacheSubtitle,
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const CacheManagementPage(),
                ),
              ),
            ],
          ),
          if (!forumRepo.hasFixedBaseUrl) ...[
            const SizedBox(height: FUITokens.gap16),
            FUISection(
              title: l10n.settingsForumSection,
              children: [
                FUITile(
                  icon: FUIIcons.building,
                  title: l10n.settingsReconfigureSite,
                  subtitle: forumRepo.baseUrl,
                  onTap: () => FuiNavigation.openDetail(
                    context,
                    builder: (_) =>
                        const SetupPage(isSetup: false, embedded: true),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _checkUpdate() async {
    if (_isCheckingUpdate) return;
    setState(() => _isCheckingUpdate = true);
    try {
      await runGithubUpdateCheckFlow(context);
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  Future<void> _selectLanguage(
    BuildContext context, {
    required Locale current,
    required ValueChanged<Locale> onChanged,
  }) async {
    final selected = await SharedDialog.showRadioListDialog<Locale>(
      context,
      title: AppLocalizations.of(context)!.settingsLanguageSelect,
      itemNameValueMap: {
        for (final language in languages)
          language.label(context): language.locale,
      },
      groupValue: current,
    );
    if (selected != null) onChanged(selected);
  }
}

class DataBasePage extends StatefulWidget {
  const DataBasePage({super.key});

  @override
  State<DataBasePage> createState() => _DataBasePageState();
}

class _DataBasePageState extends State<DataBasePage> {
  final repo = getIt<LocalCacheRepository>();
  final forumRepo = getIt<ForumRepository>();
  late Future<List<LocalCacheSummary>> _items;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _items = repo.summaries();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FUIPage(
        children: [
          FuiPageHead(
            title: l10n.settingsDataManagement,
            subtitle: l10n.cacheDataManagementSubtitle,
            trailing: FUIIconButton(
              icon: FUIIcons.delete,
              tooltip: l10n.dialogClearCacheConfirm,
              variant: FUIIconButtonVariant.ghost,
              onPressed: _clearAll,
            ),
          ),
          const SizedBox(height: FUITokens.gap16),
          FutureBuilder<List<LocalCacheSummary>>(
            future: _items,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? const <LocalCacheSummary>[];
              final total = items.fold<int>(0, (sum, item) => sum + item.count);
              return FUISection(
                title: l10n.cacheLocalDataCount(total),
                children: [
                  for (final item in items)
                    FUITile(
                      icon: item.category.icon,
                      title: item.category.label(l10n),
                      subtitle: l10n.cacheCategorySummary(
                        item.count,
                        item.category.description(l10n),
                      ),
                      showChevron: item.count > 0,
                      onTap: item.count == 0
                          ? null
                          : () => _clearCategory(item.category),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(String message) async {
    final l10n = AppLocalizations.of(context)!;
    return shared.SharedDialog.showConfirmDialog(
      context,
      title: l10n.dialogConfirmTitle,
      content: message,
      cancelText: l10n.dialogNo,
      confirmText: l10n.dialogYes,
      variant: shared.SharedDialogVariant.warning,
    );
  }

  Future<void> _clearCategory(LocalCacheCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _confirm(l10n.cacheClearCategoryConfirm(category.label(l10n)))) {
      return;
    }
    if (!mounted) return;
    try {
      await repo.clear(category);
      if (!mounted) return;
      setState(_reload);
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showMessage(
        msg: l10n.commonNoticeDeleteFailed,
        context: context,
      );
    }
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _confirm(l10n.dialogClearCacheConfirm)) return;
    if (!mounted) return;
    try {
      await repo.clearAll();
      if (!mounted) return;
      setState(_reload);
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showMessage(
        msg: l10n.commonNoticeDeleteFailed,
        context: context,
      );
    }
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
