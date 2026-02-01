/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:forum/utils/log_util.dart';

class ApiLog {
  static void ok(String api, String action, [String? extra]) {
    LogUtil.debug(
      "[API::$api] $action | OK${extra != null ? ' | $extra' : ''}",
    );
  }

  static void fail(String api, String action, String reason) {
    LogUtil.error("[API::$api] $action | FAIL | $reason");
  }

  static void exception(String api, String action, Object e, StackTrace s) {
    LogUtil.errorE("[API::$api] $action | EXCEPTION", e, s);
  }
}
