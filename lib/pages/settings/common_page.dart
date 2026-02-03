import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/api/api_constants.dart';
import 'package:forum/data/repository/discussion_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/setup/view.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:forum/pages/settings/widgets/settings_label.dart';
import 'package:forum/pages/settings/widgets/settings_switch_tile.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/shared_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CommonSettingsPage extends StatelessWidget {
  const CommonSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("通用")),
      body: ListView(
        children: [
          const SettingsSwitchTile(
            title: '自动检查更新',
            subTitle: '是否在启动app时检查更新',
            settingsKey: SettingsStorageKeys.autoCheckUpdate,
            defualtValue: false,
          ),
          const SettingsLabel(text: '数据'),
          ListTile(
            title: const Text("缓存管理"),
            onTap: () {
              Navigator.of(
                context,
              ).push(GetPageRoute(page: () => const CacheManagementPage()));
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: const Text("数据管理"),
            onTap: () {
              Navigator.of(
                context,
              ).push(GetPageRoute(page: () => const DataBasePage()));
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: const Text("重新配置站点"),
            onTap: ApiConstants.apiBase.isNotEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      GetPageRoute(page: () => const SetupPage(isSetup: false)),
                    );
                  },
          ),
        ],
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
      appBar: AppBar(title: const Text("缓存管理")),
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
      "确认",
      "是否删除该缓存?",
      "否",
      () => Navigator.of(context).pop(),
      "是",
      () {
        try {
          element.deleteSync(recursive: true);
        } catch (_) {
          SnackbarUtils.showMessage(msg: "删除失败...");
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
        title: const Text("缓存管理"),
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
      "确认",
      "是否删除该缓存?",
      "否",
      () => Navigator.of(context).pop(),
      "是",
      () async {
        try {
          await repo.discussionsDao.deleteItem(element);
        } catch (_) {
          SnackbarUtils.showMessage(msg: "删除失败...");
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
      "确认",
      "是否清空缓存?",
      "否",
      () => Navigator.of(context).pop(),
      "是",
      () async {
        try {
          await repo.clearAll();
        } catch (_) {
          SnackbarUtils.showMessage(msg: "删除失败...");
        }
        if (!context.mounted) return;
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }
}
