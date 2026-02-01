/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SheetUtil {

  static void newBottomSheet({required Widget widget}) {
    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.fromLTRB(8, 15, 8, 0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            widget,
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Theme.of(Get.context!).colorScheme.surface,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }
}
