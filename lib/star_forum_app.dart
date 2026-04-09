import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:nil/nil.dart';
import 'package:star_forum/app/local_controller.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/splash/view.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/storage_utils.dart';

class StarForumApp extends StatelessWidget {
  const StarForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final currentTheme = SettingsUtil.currentTheme;
        final themeMode = SettingsUtil.currentThemeMode;

        return GetMaterialApp(
          title: 'StarForum',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeController.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            final selectedLocale = localeController.locale;
            if (selectedLocale != null) {
              return selectedLocale;
            }
            if (locale == null) {
              return const Locale('en');
            }
            final normalized = _normalizeAppLocale(locale);
            if (normalized != null) {
              return normalized;
            }
            return const Locale('en');
          },
          scrollBehavior: const _DesktopScrollBehavior(),
          useInheritedMediaQuery: true,
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: currentTheme == AppTheme.dynamic
                ? lightDynamic ?? AppTheme.dynamic.themeDataLight.colorScheme
                : currentTheme.themeDataLight.colorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: currentTheme == AppTheme.dynamic
                ? darkDynamic ?? AppTheme.dynamic.themeDataDark.colorScheme
                : currentTheme.themeDataDark.colorScheme,
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          builder: (context, child) {
            if (child == null) {
              return nil;
            }
            final mediaQuery = MediaQuery.of(context);
            final textScaleFactor = SettingsUtil.getValue(
              SettingsStorageKeys.textScaleFactor,
              defaultValue: 1.0,
            );
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(
                  mediaQuery.textScaler.scale(textScaleFactor),
                ),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}

Locale? _normalizeAppLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return const Locale('en');
    case 'zh':
      final scriptCode = locale.scriptCode?.toLowerCase();
      final countryCode = locale.countryCode?.toUpperCase();
      const traditionalCountries = {'TW', 'HK', 'MO'};
      if (scriptCode == 'hant' ||
          (scriptCode == null &&
              countryCode != null &&
              traditionalCountries.contains(countryCode))) {
        return const Locale.fromSubtags(
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

class _DesktopScrollBehavior extends MaterialScrollBehavior {
  const _DesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
