/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static late final Box user;
  static late final Box networkData;
  static late final Box settings;
  static late final Box history;
  static bool _initialized = false;
  static Future<void> ensureInitialized() async {
    if (!_initialized) {
      Hive.init("${(await getApplicationSupportDirectory()).path}/hive");
      user = await Hive.openBox("user");
      networkData = await Hive.openBox("networkData");
      settings = await Hive.openBox("settings");
      history = await Hive.openBox("history");
      _initialized = true;
    }
  }
}

class UserStorageKeys {
  static const String userFace = "userFace";
  static const String hasLogin = "hasLogin";
  static const String userName = "userName";
}

class SettingsStorageKeys {
  /// Theme settings.
  static const String themeMode = "themeMode";
  static const String biliTheme = "biliTheme";

  /// Auto update from github repo's release.
  static const String autoCheckUpdate = "autoCheckUpdate";

  /// Show search history.
  static const String showSearchHistory = "showSearchHistory";
  
  /// Enabled functions for StarFish Forum.
  static const String appForATC = "appForATC";

  /// Text scaling.
  static const String textScaleFactor = 'textScaleFactor';
}
