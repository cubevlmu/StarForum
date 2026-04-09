/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/auth/auth_storage.dart';
import 'package:star_forum/pages/account/controller.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/utils/http_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart';

enum UserRepoState { unknown, notLogin, checkingToken, loggedIn, expired }

class UserRepo {
  UserRepoState _state = .unknown;
  UserInfo? _user;
  final storge = AuthStorage();

  UserRepoState get state => _state;
  bool get isLogin => _state == .loggedIn;
  UserInfo? get user => _user;

  bool _setupCalled = false;
  bool _isHandling = false;

  int get userId => int.parse(storge.userId ?? "-1");

  Future<void> setup() async {
    if (_setupCalled) {
      LogUtil.debug("[UserRepo] setup already called");
      return;
    }
    _setupCalled = true;

    if (!storge.hasLogin || storge.userId == null) {
      _setNotLogin();
      return;
    }

    _state = .checkingToken;
    HttpUtils.setToken(await storge.accessToken ?? "");

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
      final me = await Api.getUserInfoByNameOrId(storge.userId ?? "0");

      if (me == null) {
        LogUtil.error("[UserRepo] fetch me failed");
        await _clearLogin();
        return;
      }

      _user = me;
      _state = .loggedIn;
      _notifyLoginState();
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] fetch me error", e, s);
      await _clearLogin();
    }
  }

  Future<bool> login(String usr, String pwd, {bool autoRelogin = true}) async {
    try {
      final resp = await Api.login(usr, pwd);
      if (resp == null) return false;

      await storge.saveLogin(
        token: 'Token ${resp.token}; userId=${resp.userId}',
        userId: resp.userId.toString(),
        autoRelogin: autoRelogin,
        username: usr,
        password: pwd,
      );

      HttpUtils.setToken('Token ${resp.token}; userId=${resp.userId}');

      final me = await Api.getLoggedInUserInfo(resp);
      if (me == null) return false;

      _user = me;
      _state = .loggedIn;
      _notifyLoginState();
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] login failed", e, s);
      await _clearLogin();
      return false;
    }
  }

  Future<void> logout() async {
    if (_isHandling) return;
    _isHandling = true;
    
    storge.clearAutoLogin();
    await _clearLogin();

    _isHandling = false;
  }

  Future<void> _clearLogin() async {
    _state = .expired;
    if (_state == .expired && storge.autoRelogin) {
      final r = await _autoRelogin();
      if (r) {
        LogUtil.info("[UserRepo] Auto relogin success.");
        return;
      }

      storge.clearAutoLogin();
    }

    await storge.clear();
    HttpUtils.setToken("");
    LogUtil.debug("[UserRepo] Login state has been cleared.");
    _setNotLogin();
  }

  Future<bool> _autoRelogin() async {
  if (!storge.autoRelogin) return false;

  final last = storge.lastInputPwdTime;
  if (last == null ||
      DateTime.now().difference(last).inDays > 7) {
    return false;
  }

  final pwd = await storge.password;
  if (pwd == null) return false;

  return login(
    storge.username ?? "",
    pwd,
    autoRelogin: true,
  );
}


  void _setNotLogin() {
    _user = null;
    _state = .notLogin;
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
