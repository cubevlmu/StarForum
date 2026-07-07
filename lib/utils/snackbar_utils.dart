/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:fin_ui/fin_ui.dart';

enum AppNoticeType { info, success, warning, error }

class SnackbarUtils {
  static void showMessage({
    required String msg,
    String title = "",
    AppNoticeType type = AppNoticeType.info,
  }) {
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
