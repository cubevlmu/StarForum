/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:forum/data/repository/user_repo.dart';
import 'package:get/get.dart';

import '../../di/injector.dart';

class AccountPageController extends GetxController {
  AccountPageController();
  final repo = getIt<UserRepo>();

  RxBool isLogOut = true.obs;

  int getTrueId() {
    if (!repo.isLogin()) return -2;
    if (repo.user == null) {
      return -1;
    }
    return repo.user!.id;
  }

  void onLogOut() {}
}
