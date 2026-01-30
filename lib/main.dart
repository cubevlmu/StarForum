/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/main/view.dart';
import 'package:forum/utils/http_utils.dart';
import 'package:forum/utils/setting_util.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:get/get.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// Enable functions designed for StarFish Forum.
const bool isStarFourmForATC = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtils.ensureInitialized();
  
  setupInjector();
  runApp(const MyApp());
  
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: ((lightDynamic, darkDynamic) {
        return GetMaterialApp(
          onInit: () async {
            await HttpUtils().init();
            await StorageUtils.ensureInitialized();
          },
          useInheritedMediaQuery: true,
          themeMode: SettingsUtil.currentThemeMode,
          theme: ThemeData(
            colorScheme: SettingsUtil.currentTheme == BiliTheme.dynamic
                ? lightDynamic ?? BiliTheme.dynamic.themeDataLight.colorScheme
                : SettingsUtil.currentTheme.themeDataLight.colorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: SettingsUtil.currentTheme == BiliTheme.dynamic
                ? darkDynamic ?? BiliTheme.dynamic.themeDataDark.colorScheme
                : SettingsUtil.currentTheme.themeDataDark.colorScheme,
            useMaterial3: true,
          ),
          home: const MainPage(),
          builder: (context, child) => child == null
              ? const SizedBox()
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
