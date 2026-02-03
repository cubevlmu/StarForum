import 'package:flutter/material.dart';
import 'package:forum/utils/setting_util.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.settingsKey,
      required this.defualtValue,
      this.apply});
  final String title;
  final String subTitle;
  final String settingsKey;
  final bool defualtValue;

  final Function()? apply;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subTitle),
      trailing: StatefulBuilder(builder: (context, setState) {
        return Switch(
          value: SettingsUtil.getValue(settingsKey, defaultValue: defualtValue),
          onChanged: null
          //  (value) async {
          //   await SettingsUtil.setValue(settingsKey, value);
          //   setState(() {});
          //   apply?.call();
          // },
        );
      }),
    );
  }
}
