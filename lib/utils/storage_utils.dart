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
      final boxes = await Future.wait<Box<dynamic>>([
        Hive.openBox("user"),
        Hive.openBox("networkData"),
        Hive.openBox("settings"),
        Hive.openBox("history"),
      ]);
      user = boxes[0];
      networkData = boxes[1];
      settings = boxes[2];
      history = boxes[3];
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
  static const String themeMode = "themeMode";
  static const String appTheme = "appTheme";
  static const String appLang = "appLang";

  static const String autoCheckUpdate = "autoCheckUpdate";
  static const String showSearchHistory = "showSearchHistory";

  static const String textScaleFactor = 'textScaleFactor';
  static const String apiBaseUrl = 'apiBaseUrl';
}
