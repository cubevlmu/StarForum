/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/view.dart';
import 'package:star_forum/pages/setup/view.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

enum SplashStage { loading, failed }

class SplashScreenController extends GetxController {
  final state = "".obs;
  final stage = SplashStage.loading.obs;
  final errorDetail = RxnString();
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();

    retry();
  }

  Future<void> retry() async {
    if (_isSyncing) return;
    final context = Get.context;
    if (context == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    _isSyncing = true;
    stage.value = SplashStage.loading;
    errorDetail.value = null;

    try {
      state.value = l10n.splashStateInitNetwork;
      LogUtil.info("[Splash] Begin to setup api service.");
      final isApiSetup = await Api.setup();
      if (!isApiSetup) {
        throw StateError(l10n.splashErrorSiteNotConfigured);
      }

      final repo = getIt<UserRepo>();
      final tag = getIt<TagRepo>();
      state.value = l10n.splashStateSyncUser;
      LogUtil.info("[Splash] Begin to setup user service.");
      LogUtil.info("[Splash] Begin sync tags.");

      await Future.wait<void>([repo.setup(), _runTagSync(tag, l10n)]);

      state.value = l10n.splashStateFinished;
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    } on StateError catch (ex) {
      if (ex.message == l10n.splashErrorSiteNotConfigured) {
        LogUtil.info("[Splash] App is not configured.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SetupPage(isSetup: true)),
          (route) => false,
        );
      }
    } catch (e, s) {
      LogUtil.errorE("[Splash] Failed to initialize application", e, s);
      stage.value = SplashStage.failed;
      errorDetail.value = state.value;
      SnackbarUtils.showMessage(msg: l10n.refreshRefreshFailed);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _runTagSync(TagRepo tagRepo, AppLocalizations l10n) async {
    state.value = l10n.splashStateSyncTags;
    await tagRepo.syncTags();
  }

  void openSetupPage() {
    final context = Get.context;
    if (context == null) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SetupPage(isSetup: true)),
      (route) => false,
    );
  }
}
