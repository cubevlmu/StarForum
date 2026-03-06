/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/utils/storage_utils.dart';

class LocaleController extends GetxController {
  final Rx<Locale?> _locale = Rx<Locale?>(null);

  Locale? get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  void _loadLocale() {
    final saved = StorageUtils.settings.get(SettingsStorageKeys.appLang);
    if (saved == null) return;

    final parts = saved.split('_');
    if (parts.length == 1) {
      _locale.value = Locale(parts[0]);
    } else {
      _locale.value = Locale(parts[0], parts[1]);
    }

    Get.updateLocale(_locale.value!);
  }

  void changeLocale(Locale locale) {
    _locale.value = locale;
    StorageUtils.settings.put(SettingsStorageKeys.appLang, _encode(locale));
    Get.updateLocale(locale);
  }

  String _encode(Locale locale) {
    if (locale.countryCode == null) return locale.languageCode;
    return "${locale.languageCode}_${locale.countryCode}";
  }
}
