/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/users.dart';
import 'package:forum/data/auth/auth_storage.dart';
import 'package:forum/pages/account/controller.dart';
import 'package:forum/pages/home/controller.dart';
import 'package:forum/pages/notification/controller.dart';
import 'package:forum/utils/http_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:get/get.dart';

enum UserRepoState { unknown, notLogin, checkingToken, loggedIn, expired }

class UserRepo {
  UserRepoState _state = UserRepoState.unknown;
  UserInfo? _user;

  UserRepoState get state => _state;
  bool get isLogin => _state == UserRepoState.loggedIn;
  UserInfo? get user => _user;

  bool _setupCalled = false;

  int get userId => int.parse(AuthStorage.userId ?? "-1");

  Future<void> setup() async {
    if (_setupCalled) {
      LogUtil.debug("[UserRepo] setup already called");
      return;
    }
    _setupCalled = true;

    if (!AuthStorage.hasToken || !AuthStorage.hasUserId) {
      _setNotLogin();
      return;
    }

    _state = UserRepoState.checkingToken;
    HttpUtils.setToken(AuthStorage.accessToken ?? "");

    try {
      final valid = await Api.isTokenValid();
      if (!valid) {
        LogUtil.warn("[UserRepo] token invalid");
        await _clearLogin();
        return;
      }

      await _fetchMe();
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] setup failed", e, s);
      await _clearLogin();
    }
  }

  Future<void> _fetchMe() async {
    try {
      final me = await Api.getUserInfoByNameOrId(AuthStorage.userId ?? "0");

      if (me == null) {
        LogUtil.error("[UserRepo] fetch me failed");
        await _clearLogin();
        return;
      }

      _user = me;
      _state = UserRepoState.loggedIn;
      _notifyLoginState();
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] fetch me error", e, s);
      await _clearLogin();
    }
  }

  Future<bool> login(String usr, String pwd) async {
    try {
      final resp = await Api.login(usr, pwd);
      if (resp == null) return false;

      await AuthStorage.saveAccessToken(
        'Token ${resp.token}; userId=${resp.userId}',
        resp.userId.toString(),
      );

      HttpUtils.setToken(AuthStorage.accessToken ?? "");

      final me = await Api.getLoggedInUserInfo(resp);
      if (me == null) return false;

      _user = me;
      _state = UserRepoState.loggedIn;
      _notifyLoginState();
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] login failed", e, s);
      await _clearLogin();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearLogin();
  }

  Future<void> _clearLogin() async {
    _state = .expired;
    await AuthStorage.clear();
    HttpUtils.setToken("");
    _setNotLogin();
  }

  void _setNotLogin() {
    _user = null;
    _state = UserRepoState.notLogin;
    _notifyLoginState();
  }

  void _notifyLoginState() {
    try {
      Get.find<HomeController>().isLogin.value = isLogin;
      Get.find<HomeController>().avatarUrl.value = _user?.avatarUrl ?? "";
    } catch (_) {}

    try {
      Get.find<NotificationPageController>().isLogin.value = isLogin;
    } catch (_) {}

    try {
      Get.find<AccountPageController>().isLogin.value = isLogin;
    } catch (_) {}
  }
}
