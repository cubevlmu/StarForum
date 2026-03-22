import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/app/local_controller.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/utils/app_language.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/pages/settings/widgets/settings_label.dart';
import 'package:star_forum/pages/settings/widgets/settings_switch_tile.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/shared_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CommonSettingsPage extends StatelessWidget {
  const CommonSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsCommonTitle),
      ),
      body: ListView(
        children: [
          SettingsSwitchTile(
            title: AppLocalizations.of(context)!.settingsAutoCheckUpdate,
            subTitle: AppLocalizations.of(context)!.settingsAutoCheckUpdateDesc,
            settingsKey: SettingsStorageKeys.autoCheckUpdate,
            defualtValue: true,
          ),
          const Divider(height: 1, thickness: 0.5),
          Obx(
            () => _LanguageSection(
              currentLocale: localeController.locale,
              onChanged: localeController.changeLocale,
            ),
          ),
          const SizedBox(height: 8),
          SettingsLabel(
            text: AppLocalizations.of(context)!.settingsDataSection,
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsCacheManagement),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CacheManagementPage()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsDataManagement),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DataBasePage()));
            },
          ),
          if (!Api.hasFixedBaseUrl) ...[
            const Divider(height: 1, thickness: 0.5),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.settingsReconfigureSite,
              ),
              onTap: () => openSetupAdaptive(context),
            ),
          ],
        ],
      ),
    );
  }
}

bool _isSameLocale(Locale? a, Locale b) {
  if (a == null) return false;
  return a.languageCode == b.languageCode &&
      a.scriptCode == b.scriptCode &&
      a.countryCode == b.countryCode;
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({
    required this.currentLocale,
    required this.onChanged,
  });

  final Locale? currentLocale;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveLocale =
        currentLocale ??
        Localizations.maybeLocaleOf(context) ??
        languages.first.locale;
    final currentLanguage = languages.firstWhere(
      (language) => _isSameLocale(effectiveLocale, language.locale),
      orElse: () => languages.first,
    );

    return _SettingsSection(
      title: AppLocalizations.of(context)!.settingsLanguage,
      subtitle: currentLanguage.label(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<Locale>(
            segments: [
              for (final language in languages)
                ButtonSegment<Locale>(
                  value: language.locale,
                  icon: Icon(_languageIcon(language.locale)),
                  label: Text(language.label(context)),
                ),
            ],
            selected: {currentLanguage.locale},
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
            showSelectedIcon: false,
            onSelectionChanged: (value) {
              if (value.isNotEmpty) {
                onChanged(value.first);
              }
            },
          ),
        ),
      ),
    );
  }

  IconData _languageIcon(Locale locale) {
    if (locale.languageCode == 'en') {
      return Icons.sort_by_alpha_rounded;
    }
    if (locale.scriptCode == 'Hans') {
      return Icons.translate_rounded;
    }
    return Icons.language_rounded;
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(title), subtitle: Text(subtitle)),
        child,
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}

class CacheManagementPage extends StatefulWidget {
  const CacheManagementPage({super.key});

  @override
  State<CacheManagementPage> createState() => _CacheManagementPageState();
}

class _CacheManagementPageState extends State<CacheManagementPage> {
  final List<Widget> items = [];

  Future<double> getTotalSizeOfFilesInDir(FileSystemEntity file) async {
    if (file is File && await file.exists()) {
      int length = await file.length();
      return length.toDouble();
    }
    if (file is Directory && await file.exists()) {
      List children = file.listSync();
      double total = 0;
      if (children.isNotEmpty) {
        for (FileSystemEntity child in children) {
          total += await getTotalSizeOfFilesInDir(child);
        }
      }
      return total;
    }
    return 0;
  }

  Future<void> buildItems() async {
    items.clear();
    var dir = await getApplicationSupportDirectory();
    for (var element in dir.listSync()) {
      if (element is Directory && await element.exists()) {
        double size = await getTotalSizeOfFilesInDir(element);
        items.add(
          ListTile(
            title: Text(element.path.split('/').last),
            subtitle: Text(StringUtil.byteNumToFileSize(size)),
            onTap: () => _onTap(element),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsCacheManagement),
      ),
      body: FutureBuilder(
        future: buildItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(children: items);
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }

  void _onTap(FileSystemEntity element) {
    SharedDialog.showDialog2(
      context,
      AppLocalizations.of(context)!.dialogConfirmTitle,
      AppLocalizations.of(context)!.dialogDeleteCacheConfirm,
      AppLocalizations.of(context)!.dialogNo,
      () => Navigator.of(context).pop(),
      AppLocalizations.of(context)!.dialogYes,
      () {
        try {
          element.deleteSync(recursive: true);
        } catch (_) {
          SnackbarUtils.showMessage(
            msg: AppLocalizations.of(context)!.commonNoticeDeleteFailed,
          );
        }
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }
}

class DataBasePage extends StatefulWidget {
  const DataBasePage({super.key});

  @override
  State<DataBasePage> createState() => _DataBasePagePageState();
}

class _DataBasePagePageState extends State<DataBasePage> {
  final List<Widget> items = [];
  final repo = getIt<DiscussionRepository>();

  Future<void> buildItems() async {
    items.clear();

    final all = await repo.discussionsDao.getAllTitle();
    for (var element in all) {
      items.add(
        ListTile(
          title: Text(element),
          subtitle: Text(Api.getBaseUrl),
          onTap: () => _onTap(element),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsCacheManagement),
        actions: [
          IconButton(
            onPressed: clearAll,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder(
        future: buildItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(children: items);
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }

  void _onTap(String element) {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    SharedDialog.showDialog2(
      context,
      l10n.dialogConfirmTitle,
      l10n.dialogDeleteCacheConfirm,
      l10n.dialogNo,
      () => navigator.pop(),
      l10n.dialogYes,
      () async {
        try {
          await repo.discussionsDao.deleteItem(element);
        } catch (_) {
          SnackbarUtils.showMessage(msg: l10n.commonNoticeDeleteFailed);
        }
        if (!mounted) return;
        navigator.pop();
        setState(() {});
      },
    );
  }

  void clearAll() {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    SharedDialog.showDialog2(
      context,
      l10n.dialogConfirmTitle,
      l10n.dialogClearCacheConfirm,
      l10n.dialogNo,
      () => navigator.pop(),
      l10n.dialogYes,
      () async {
        try {
          await repo.clearAll();
        } catch (_) {
          SnackbarUtils.showMessage(msg: l10n.commonNoticeDeleteFailed);
        }
        if (!mounted) return;
        navigator.pop();
        setState(() {});
      },
    );
  }
}
