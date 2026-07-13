/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/widgets.dart';

enum AppNoticeType { info, success, warning, error }

class SnackbarUtils {
  static void showMessage({
    required String msg,
    String title = "",
    AppNoticeType type = AppNoticeType.info,
    BuildContext? context,
  }) {
    if (context != null) {
      FUIToast.show(
        context,
        message: msg,
        title: title,
        type: _toastType(type),
      );
      return;
    }
    switch (type) {
      case AppNoticeType.success:
        FUIToast.successGlobal(message: msg, title: title);
        break;
      case AppNoticeType.warning:
        FUIToast.warningGlobal(message: msg, title: title);
        break;
      case AppNoticeType.error:
        FUIToast.errorGlobal(message: msg, title: title);
        break;
      case AppNoticeType.info:
        FUIToast.infoGlobal(message: msg, title: title);
        break;
    }
  }

  static FUIToastType _toastType(AppNoticeType type) => switch (type) {
    AppNoticeType.info => FUIToastType.info,
    AppNoticeType.success => FUIToastType.success,
    AppNoticeType.warning => FUIToastType.warning,
    AppNoticeType.error => FUIToastType.error,
  };

  static void showSuccess({
    required String msg,
    String title = "",
    BuildContext? context,
  }) {
    showMessage(
      msg: msg,
      title: title,
      type: AppNoticeType.success,
      context: context,
    );
  }

  static void showError({
    required String msg,
    String title = "",
    BuildContext? context,
  }) {
    showMessage(
      msg: msg,
      title: title,
      type: AppNoticeType.error,
      context: context,
    );
  }

  static void showWarning({
    required String msg,
    String title = "",
    BuildContext? context,
  }) {
    showMessage(
      msg: msg,
      title: title,
      type: AppNoticeType.warning,
      context: context,
    );
  }
}
