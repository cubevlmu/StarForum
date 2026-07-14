import 'package:fin_ui/fin_ui.dart';
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
    final theme = SettingsUtil.currentTheme;
    final customAccent = theme == AppTheme.dynamic
        ? null
        : _accentFromTheme(theme);

    return Obx(() {
      final selectedLocale = localeController.locale;
      return FuiDynamicThemeBuilder(
        useSystemAccent: theme == AppTheme.dynamic,
        lightAccent: customAccent?.light,
        darkAccent: customAccent?.dark,
        builder: (context, lightTheme, darkTheme) {
          return GetMaterialApp(
            title: 'StarForum',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: selectedLocale,
            localeResolutionCallback: (locale, supportedLocales) {
              if (selectedLocale != null) {
                return selectedLocale;
              }
              if (locale == null) {
                return const Locale('en');
              }
              final normalized = LocaleController.normalizeSupported(locale);
              if (normalized != null) {
                return normalized;
              }
              return const Locale('en');
            },
            scrollBehavior: FuiTheme.scrollBehavior,
            useInheritedMediaQuery: true,
            themeMode: SettingsUtil.currentThemeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
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
    });
  }
}

({FuiAccent light, FuiAccent dark}) _accentFromTheme(AppTheme theme) {
  return (
    light: FuiAccent.fromColorScheme(
      ColorScheme.fromSeed(
        seedColor: theme.seedColor,
        brightness: Brightness.light,
      ),
    ),
    dark: FuiAccent.fromColorScheme(
      ColorScheme.fromSeed(
        seedColor: theme.seedColor,
        brightness: Brightness.dark,
      ),
    ),
  );
}
