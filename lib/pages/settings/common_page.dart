import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_forum/app/local_controller.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/setup/view.dart';
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
            defualtValue: false,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsLanguage),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsLanguageSelect,
            ),
            onTap: () => _showLanguageSelector(context),
          ),
          SettingsLabel(
            text: AppLocalizations.of(context)!.settingsDataSection,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsCacheManagement),
            onTap: () {
              Navigator.of(
                context,
              ).push(
                MaterialPageRoute(
                  builder: (_) => const CacheManagementPage(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsDataManagement),
            onTap: () {
              Navigator.of(
                context,
              ).push(
                MaterialPageRoute(
                  builder: (_) => const DataBasePage(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsReconfigureSite),
            onTap: () {
              Navigator.of(
                context,
              ).push(
                MaterialPageRoute(
                  builder: (_) => const SetupPage(isSetup: false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final controller = Get.find<LocaleController>();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final current = controller.locale;
        return AlertDialog(
          title: Text(l10n.settingsLanguageSelect),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int index = 0; index < languages.length; index++) ...[
                  _LanguageOptionTile(
                    label: languages[index].label(context),
                    selected: _isSameLocale(current, languages[index].locale),
                    onTap: () {
                      controller.changeLocale(languages[index].locale);
                      Navigator.of(context).pop();
                    },
                  ),
                  if (index != languages.length - 1)
                    const Divider(height: 1, thickness: 0.5),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonActionCancel),
            ),
          ],
        );
      },
    );
  }
}

bool _isSameLocale(Locale? a, Locale b) {
  if (a == null) return false;
  return a.languageCode == b.languageCode &&
      a.scriptCode == b.scriptCode &&
      a.countryCode == b.countryCode;
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey("selected"),
                      color: colorScheme.primary,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: const ValueKey("unselected"),
                      color: colorScheme.outline,
                    ),
            ),
          ],
        ),
      ),
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
    SharedDialog.showDialog2(
      context,
      AppLocalizations.of(context)!.dialogConfirmTitle,
      AppLocalizations.of(context)!.dialogDeleteCacheConfirm,
      AppLocalizations.of(context)!.dialogNo,
      () => Navigator.of(context).pop(),
      AppLocalizations.of(context)!.dialogYes,
      () async {
        try {
          await repo.discussionsDao.deleteItem(element);
        } catch (_) {
          SnackbarUtils.showMessage(
            msg: AppLocalizations.of(context)!.commonNoticeDeleteFailed,
          );
        }
        if (context.mounted) {
          Navigator.of(context).pop();
          setState(() {});
        }
      },
    );
  }

  void clearAll() {
    SharedDialog.showDialog2(
      context,
      AppLocalizations.of(context)!.dialogConfirmTitle,
      AppLocalizations.of(context)!.dialogClearCacheConfirm,
      AppLocalizations.of(context)!.dialogNo,
      () => Navigator.of(context).pop(),
      AppLocalizations.of(context)!.dialogYes,
      () async {
        try {
          await repo.clearAll();
        } catch (_) {
          SnackbarUtils.showMessage(
            msg: AppLocalizations.of(context)!.commonNoticeDeleteFailed,
          );
        }
        if (!context.mounted) return;
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }
}
