/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/storage_utils.dart';

class SettingsUtil {
  static dynamic getValue(String key, {dynamic defaultValue}) {
    return StorageUtils.settings.get(key, defaultValue: defaultValue);
  }

  static Future<void> setValue(String key, dynamic value) async {
    await StorageUtils.settings.put(key, value);
  }

  static ThemeMode get currentThemeMode {
    var index = getValue(
      SettingsStorageKeys.themeMode,
      defaultValue: ThemeMode.system.index,
    );
    return ThemeMode.values[index];
  }

  static void changeThemeMode(ThemeMode themeMode) {
    setValue(SettingsStorageKeys.themeMode, themeMode.index);
    Get.changeThemeMode(themeMode);
  }

  static AppTheme get currentTheme {
    var index = getValue(
      SettingsStorageKeys.appTheme,
      defaultValue: AppTheme.dynamic.index,
    );
    return AppTheme.values[index];
  }

  static void changeTheme(AppTheme theme) {
    setValue(SettingsStorageKeys.appTheme, theme.index);
    Get.forceAppUpdate();
  }
}

extension ThemeModeString on ThemeMode {
  String get value {
    final context = Get.context;
    final l10n = context == null ? null : AppLocalizations.of(context);
    if (l10n == null) return ['System', 'Light', 'Dark'][index];
    return [
      l10n.themeModeSystem,
      l10n.themeModeLight,
      l10n.themeModeDark,
    ][index];
  }
}

enum AppTheme {
  dynamic,
  blue,
  lightBlue,
  cyan,
  teal,
  green,
  lime,
  yellow,
  amber,
  orange,
  deepOrange,
  red,
  pink,
  purple,
  deepPurple,
  indigo,
  brown,
  blueGrey,
  grey,
}

extension AppThemeName on AppTheme {
  String get value {
    final context = Get.context;
    final l10n = context == null ? null : AppLocalizations.of(context);
    if (l10n == null) {
      return [
        'Dynamic',
        'Blue',
        'Light Blue',
        'Cyan',
        'Teal',
        'Green',
        'Lime',
        'Yellow',
        'Amber',
        'Orange',
        'Deep Orange',
        'Red',
        'Pink',
        'Purple',
        'Deep Purple',
        'Indigo',
        'Brown',
        'Blue Grey',
        'Grey',
      ][index];
    }
    return [
      l10n.themeColorDynamic,
      l10n.themeColorBlue,
      l10n.themeColorLightBlue,
      l10n.themeColorCyan,
      l10n.themeColorTeal,
      l10n.themeColorGreen,
      l10n.themeColorLime,
      l10n.themeColorYellow,
      l10n.themeColorAmber,
      l10n.themeColorOrange,
      l10n.themeColorDeepOrange,
      l10n.themeColorRed,
      l10n.themeColorPink,
      l10n.themeColorPurple,
      l10n.themeColorDeepPurple,
      l10n.themeColorIndigo,
      l10n.themeColorBrown,
      l10n.themeColorBlueGrey,
      l10n.themeColorGrey,
    ][index];
  }

  Color get seedColor => [
    Colors.blue,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.brown,
    Colors.blueGrey,
    Colors.grey,
  ][index];
  ThemeData get themeDataLight => ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
  ThemeData get themeDataDark => ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
