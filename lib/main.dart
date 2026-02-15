/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/splash/view.dart';
import 'package:forum/utils/http_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/setting_util.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:forum/utils/window_util.dart';
import 'package:get/get.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:nil/nil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtils.ensureInitialized();
  await LogUtil.init();

  WindowResizeObserver.instance.init();
  runApp(const StarForumApp());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
}

class StarForumApp extends StatelessWidget {
  const StarForumApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: ((lightDynamic, darkDynamic) {
        return GetMaterialApp(
          scrollBehavior: const _DesktopScrollBehavior(),
          onInit: () async {
            setupInjector();
            await HttpUtils().init();
          },
          useInheritedMediaQuery: true,
          themeMode: SettingsUtil.currentThemeMode,
          theme: ThemeData(
            colorScheme: SettingsUtil.currentTheme == AppTheme.dynamic
                ? lightDynamic ?? AppTheme.dynamic.themeDataLight.colorScheme
                : SettingsUtil.currentTheme.themeDataLight.colorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: SettingsUtil.currentTheme == AppTheme.dynamic
                ? darkDynamic ?? AppTheme.dynamic.themeDataDark.colorScheme
                : SettingsUtil.currentTheme.themeDataDark.colorScheme,
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          builder: (context, child) => child == null
              ? nil
              : MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).textScaler.scale(
                        SettingsUtil.getValue(
                          SettingsStorageKeys.textScaleFactor,
                          defaultValue: 1.0,
                        ),
                      ),
                    ),
                  ),
                  child: child,
                ),
        );
      }),
    );
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
