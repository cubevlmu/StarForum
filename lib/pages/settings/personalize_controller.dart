import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/storage_utils.dart';

class PersonalizeSettingsController extends GetxController {
  final themeMode = SettingsUtil.currentThemeMode.obs;
  final theme = SettingsUtil.currentTheme.obs;
  final textScaleFactor = _loadTextScaleFactor().obs;

  Future<void> changeThemeMode(ThemeMode value) async {
    if (themeMode.value == value) return;
    themeMode.value = value;
    SettingsUtil.changeThemeMode(value);
  }

  Future<void> changeTheme(AppTheme value) async {
    if (theme.value == value) return;
    theme.value = value;
    SettingsUtil.changeTheme(value);
  }

  Future<void> changeTextScaleFactor(double value) async {
    if (textScaleFactor.value == value) return;
    textScaleFactor.value = value;
    await SettingsUtil.setValue(SettingsStorageKeys.textScaleFactor, value);
    await Get.forceAppUpdate();
  }

  static double _loadTextScaleFactor() {
    final value = SettingsUtil.getValue(
      SettingsStorageKeys.textScaleFactor,
      defaultValue: 1.0,
    );
    if (value is num) {
      return value.toDouble();
    }
    return 1.0;
  }
}
