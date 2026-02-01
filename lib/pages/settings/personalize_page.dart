import 'package:flutter/material.dart';
import 'package:forum/utils/setting_util.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:forum/pages/settings/widgets/settings_label.dart';
import 'package:get/get.dart';

class PersonalizeSettingsPage extends StatefulWidget {
  const PersonalizeSettingsPage({super.key});

  @override
  State<PersonalizeSettingsPage> createState() => _PersonalizeSettingsPageState();
}

class _PersonalizeSettingsPageState extends State<PersonalizeSettingsPage> {
  RadioListTile themeModeListTile(ThemeMode themeMode) {
    return RadioListTile<ThemeMode>(
      value: themeMode,
      groupValue: SettingsUtil.currentThemeMode,
      title: Text(themeMode.value),
      onChanged: (value) {
        SettingsUtil.changeThemeMode(value!);
        setState(() {});
        Navigator.pop(context);
      },
    );
  }

  List<RadioListTile> buildThemeModeList() {
    List<RadioListTile> list = [];
    for (var themeMode in ThemeMode.values) {
      list.add(themeModeListTile(themeMode));
    }
    return list;
  }

  RadioListTile themeListTile(AppTheme theme) {
    return RadioListTile<AppTheme>(
      value: theme,
      groupValue: SettingsUtil.currentTheme,
      title: Text(
        theme.value,
        style: TextStyle(
            color: theme == AppTheme.dynamic ? null : theme.seedColor),
      ),
      onChanged: (value) {
        SettingsUtil.changeTheme(value!);
        setState(() {});
        Navigator.pop(context);
      },
    );
  }

  List<RadioListTile> buildThemeLists() {
    List<RadioListTile> list = [];
    for (var theme in AppTheme.values) {
      list.add(themeListTile(theme));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("主题设置")),
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "主题",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const Padding(padding: EdgeInsetsGeometry.only(bottom: 5)),
          ListTile(
            title: const Text("主题模式"),
            subtitle: Text(SettingsUtil.currentThemeMode.value),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        scrollable: true,
                        title: const Text("主题模式"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("取消"))
                        ],
                        contentPadding: EdgeInsets.zero,
                        content: Column(children: buildThemeModeList()),
                      ));
            },
          ),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            title: const Text("主题色"),
            subtitle: Text(SettingsUtil.currentTheme.value),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        scrollable: true,
                        title: const Text("主题色"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("取消"))
                        ],
                        contentPadding: EdgeInsets.zero,
                        content: Column(
                          children: buildThemeLists(),
                        ),
                      ));
            },
          ),
          const Padding(padding: EdgeInsetsGeometry.only(bottom: 8)),
          const SettingsLabel(text: '字体'),
          const Padding(padding: EdgeInsetsGeometry.only(bottom: 5)),
          ListTile(
            title: const Text('字体大小'),
            subtitle: Text(SettingsUtil.getValue(
                    SettingsStorageKeys.textScaleFactor,
                    defaultValue: 1.0)
                .toString()),
            onTap: () => showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text('字体大小'),
                children: [
                  Slider(
                    value: SettingsUtil.getValue(
                        SettingsStorageKeys.textScaleFactor,
                        defaultValue: 1.0),
                    min: 0.5,
                    max: 2,
                    divisions: 6,
                    onChanged: (value) async {
                      await SettingsUtil.setValue(
                          SettingsStorageKeys.textScaleFactor, value);
                      await Get.forceAppUpdate();
                    },
                  )
                ],
              ),
            ),
          )
        ]));
  }
}
