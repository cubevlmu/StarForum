/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/widgets.dart';
import 'package:star_forum/l10n/app_localizations.dart';

class AppLanguage {
  final Locale locale;
  final String Function(AppLocalizations l10n) labelBuilder;

  const AppLanguage(this.locale, this.labelBuilder);

  String label(BuildContext context) {
    return labelBuilder(AppLocalizations.of(context)!);
  }
}

const languages = [
  AppLanguage(Locale('en'), _languageEnglish),
  AppLanguage(Locale('zh'), _languageSimplifiedChinese),
  AppLanguage(
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    _languageTraditionalChinese,
  ),
];

String _languageEnglish(AppLocalizations l10n) => l10n.languageEnglish;
String _languageSimplifiedChinese(AppLocalizations l10n) =>
    l10n.languageSimplifiedChinese;
String _languageTraditionalChinese(AppLocalizations l10n) =>
    l10n.languageTraditionalChinese;
