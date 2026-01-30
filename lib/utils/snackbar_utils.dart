/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:get/get.dart';

class SnackbarUtils {
  
  static void showMessageWithTitle(
    String msg,
    String? title, 
  ) {
    if (Get.overlayContext != null) {
      Get.rawSnackbar(title: title, message: msg);
    }
  }

  static void showMessage(String msg) {
    showMessageWithTitle(msg, null);
  }
}