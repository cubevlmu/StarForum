/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:get/get.dart';

import '../../di/injector.dart';

class AccountPageController extends GetxController {
  AccountPageController();
  final repo = getIt<UserRepo>();
  final sessionState = getIt<SessionState>();
  final RxBool isLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    sessionState.state.addListener(_handleSessionChanged);
    _handleSessionChanged();
  }

  void _handleSessionChanged() {
    isLogin.value = sessionState.current.isAuthenticated;
  }

  int getTrueId() {
    if (!repo.isLogin) return -2;
    return repo.userId;
  }

  void onLogOut() {}

  @override
  void onClose() {
    sessionState.state.removeListener(_handleSessionChanged);
    super.onClose();
  }
}
