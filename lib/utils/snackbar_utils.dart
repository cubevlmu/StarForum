/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppNoticeType { info, success, warning, error }

class SnackbarUtils {
  static void showMessage({
    required String msg,
    String title = "",
    AppNoticeType type = AppNoticeType.info,
  }) {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 800),
        content: Text(title.isEmpty ? msg : "$title  $msg"),
      ),
    );
  }

  static void showSuccess({required String msg, String title = ""}) {
    showMessage(msg: msg, title: title, type: AppNoticeType.success);
  }

  static void showError({required String msg, String title = ""}) {
    showMessage(msg: msg, title: title, type: AppNoticeType.error);
  }

  static void showWarning({required String msg, String title = ""}) {
    showMessage(msg: msg, title: title, type: AppNoticeType.warning);
  }
}
