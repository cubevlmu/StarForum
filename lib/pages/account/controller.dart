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
  final RxBool isLogin = false.obs;

  @override
  void onInit() {
    isLogin.value = repo.isLogin;
    super.onInit();
  }

  int getTrueId() {
    if (!repo.isLogin) return -2;
    return repo.userId;
  }

  void onLogOut() {}
}
