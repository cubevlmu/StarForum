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
import 'package:star_forum/widgets/shared_dialog.dart';

class CommonSettingsPage extends StatefulWidget {
  const CommonSettingsPage({super.key});

  @override
  State<CommonSettingsPage> createState() => _CommonSettingsPageState();
}

class _CommonSettingsPageState extends State<CommonSettingsPage> {
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
            subtitle: '管理语言、更新策略、缓存和当前论坛站点',
          ),
          const SizedBox(height: FUITokens.gap16),
          FUISection(
            title: '应用行为',
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
              Obx(() {
                final locale =
                    localeController.locale ??
                    Localizations.maybeLocaleOf(context) ??
                    languages.first.locale;
                final language = languages.firstWhere(
                  (item) => _isSameLocale(locale, item.locale),
                  orElse: () => languages.first,
                );
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
                title: l10n.settingsCacheManagement,
                subtitle: '查看并清理图片、接口及临时文件缓存',
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const CacheManagementPage(),
                ),
              ),
              FUITile(
                icon: FUIIcons.chart,
                title: l10n.settingsDataManagement,
                subtitle: '管理保存在本地的帖子列表数据',
                onTap: () => FuiNavigation.openDetail(
                  context,
                  builder: (_) => const DataBasePage(),
                ),
              ),
            ],
          ),
          if (!forumRepo.hasFixedBaseUrl) ...[
            const SizedBox(height: FUITokens.gap16),
            FUISection(
              title: '论坛站点',
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

bool _isSameLocale(Locale a, Locale b) =>
    a.languageCode == b.languageCode &&
    a.scriptCode == b.scriptCode &&
    a.countryCode == b.countryCode;

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
            subtitle: '按类别清理本地持久化数据',
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
                title: '本地数据 · $total 条记录',
                children: [
                  for (final item in items)
                    FUITile(
                      icon: item.category.icon,
                      title: item.category.label,
                      subtitle:
                          '${item.count} 条 · ${item.category.description}',
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
    if (!await _confirm('确认清理「${category.label}」？')) return;
    try {
      await repo.clear(category);
      setState(_reload);
    } catch (_) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticeDeleteFailed);
    }
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _confirm(l10n.dialogClearCacheConfirm)) return;
    try {
      await repo.clearAll();
      setState(_reload);
    } catch (_) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticeDeleteFailed);
    }
  }
}

extension _LocalCacheCategoryView on LocalCacheCategory {
  String get label {
    switch (this) {
      case LocalCacheCategory.discussions:
        return '主题信息';
      case LocalCacheCategory.posts:
        return '帖子正文';
      case LocalCacheCategory.users:
        return '用户资料';
      case LocalCacheCategory.tags:
        return '标签目录';
      case LocalCacheCategory.notifications:
        return '通知记录';
      case LocalCacheCategory.collections:
        return '列表索引';
    }
  }

  String get description {
    switch (this) {
      case LocalCacheCategory.discussions:
        return '首页、关注和用户主题的主题元数据';
      case LocalCacheCategory.posts:
        return '首帖、回复和用户回复正文缓存';
      case LocalCacheCategory.users:
        return '用户资料和用户目录缓存';
      case LocalCacheCategory.tags:
        return '论坛标签和标签层级缓存';
      case LocalCacheCategory.notifications:
        return '通知列表和已读状态缓存';
      case LocalCacheCategory.collections:
        return '首页、关注、名录等列表排序窗口';
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
