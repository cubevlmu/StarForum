/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_forum/app/local_controller.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/star_forum_app.dart';
import 'package:star_forum/utils/http_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/utils/window_util.dart';
import 'package:window_manager/window_manager.dart';

final kIsDesktopPlatform =
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrapTasks = <Future<void>>[
    StorageUtils.ensureInitialized(),
    LogUtil.init(),
  ];
  if (kIsDesktopPlatform) {
    bootstrapTasks.add(windowManager.ensureInitialized());
  }
  await Future.wait(bootstrapTasks);

  WindowResizeObserver.instance.init();
  setupInjector();
  Get.put(LocaleController(), permanent: true);
  unawaited(HttpUtils().init());
  runApp(const StarForumApp());
  unawaited(_configureSystemUi());
}

Future<void> _configureSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final isMobilePlatform =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (isMobilePlatform) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
}
