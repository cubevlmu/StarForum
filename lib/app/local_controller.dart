/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    final dynamic saved = StorageUtils.settings.get(
      SettingsStorageKeys.appLang,
    );
    if (saved is! String || saved.isEmpty) {
      _locale.value = _resolveSystemLocale();
      return;
    }

    final decoded = _decode(saved);
    if (decoded == null) {
      _locale.value = _resolveSystemLocale();
      return;
    }
    final normalized = _normalizeSupported(decoded);
    if (normalized == null) {
      _locale.value = _resolveSystemLocale();
      return;
    }
    _locale.value = normalized;
    final encoded = _encode(normalized);
    if (encoded != saved) {
      StorageUtils.settings.put(SettingsStorageKeys.appLang, encoded);
    }
    Get.updateLocale(normalized);
  }

  void changeLocale(Locale locale) {
    final normalized = _normalizeSupported(locale);
    if (normalized == null) {
      return;
    }
    _locale.value = normalized;
    StorageUtils.settings.put(SettingsStorageKeys.appLang, _encode(normalized));
    Get.updateLocale(normalized);
  }

  String _encode(Locale locale) {
    if (locale.scriptCode != null && locale.countryCode != null) {
      return "${locale.languageCode}_${locale.scriptCode}_${locale.countryCode}";
    }
    if (locale.scriptCode != null) {
      return "${locale.languageCode}_${locale.scriptCode}";
    }
    if (locale.countryCode != null) {
      return "${locale.languageCode}_${locale.countryCode}";
    }
    return locale.languageCode;
  }

  Locale? _decode(String value) {
    final normalized = value.replaceAll('-', '_');
    final parts = normalized.split('_').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    if (parts.length == 2) {
      if (parts[1].length == 4) {
        return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
      }
      return Locale(parts[0], parts[1]);
    }
    return Locale.fromSubtags(
      languageCode: parts[0],
      scriptCode: parts[1],
      countryCode: parts[2],
    );
  }

  Locale? _normalizeSupported(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const Locale('en');
      case 'zh':
        if (locale.scriptCode == 'Hans' && locale.countryCode == 'CN') {
          return Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN',
          );
        }
        return const Locale('zh');
      default:
        return null;
    }
  }

  Locale _resolveSystemLocale() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final locale in locales) {
      final normalized = _normalizeSupported(locale);
      if (normalized != null) {
        return normalized;
      }
    }
    return const Locale('en');
  }
}
