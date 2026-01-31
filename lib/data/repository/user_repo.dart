/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/users.dart';
import 'package:forum/data/auth/auth_storage.dart';
import 'package:forum/pages/account/controller.dart';
import 'package:forum/pages/home/controller.dart';
import 'package:forum/pages/notification/controller.dart';
import 'package:forum/utils/http_utils.dart';
import 'package:get/get.dart';

enum UserRepoState { kUnknown, kNotLogin, kExpired, kLogined }

class UserRepo {

  void _onLoginStateChange() {
    final homeC = Get.find<HomeController>();
    homeC.avatarUrl.value = user?.avatarUrl ?? "";
    final notiC = Get.find<NotificationPageController>();
    notiC.isLogin.value = isLogin;
    final accoC = Get.find<AccountPageController>();
    accoC.isLogOut.value = !isLogin;
  }

  Future<bool> setup() async {
    if (_state != UserRepoState.kUnknown) {
      log("[UserRepo] Already setup.");
      return true;
    }
    if (AuthStorage.hasToken && AuthStorage.hasUserId) {
      log("[UserRepo] Buffered user token : ${AuthStorage.accessToken ?? ""}");
      HttpUtils.setToken(AuthStorage.accessToken ?? "");

      try {
        final r = await Api.isTokenValid();
        if (!r) {
          log("[UserRepo] Buffered token is invalid.");
          _isLogin = false;
          _onLoginStateChange();

          _state = UserRepoState.kExpired;
          return true;
        }

        _isLogin = true;
        final me = await Api.getUserInfoByNameOrId(AuthStorage.userId ?? "0");
        if (me == null) {
          log(
            "[UserRepo] Get user information failed with id ${AuthStorage.userId}. Maybe expired.",
          );
          _state = UserRepoState.kExpired;
          return true;
        }

        user = me;
        log(
          "[UserRepo] Logged user : id: ${me.id} nickname: ${me.displayName}",
        );

        _onLoginStateChange();
        _state = UserRepoState.kLogined;
          return true;
      } catch (e) {
        // token 失效
        await AuthStorage.clear();
        _onLoginStateChange();
        _isLogin = false;
        _state = UserRepoState.kExpired;
        HttpUtils().getInstance().options.headers.remove("Authorization");
        log("[UserRepo] Token expired.");

      }
    }

    _state = UserRepoState.kNotLogin;
    return false;
  }

  Future<bool> login(String usr, String pwd) async {
    try {
      final loginResp = await Api.login(usr, pwd);
      if (loginResp == null) {
        log("[UserRepo] Login failed with empty response");
        return false;
      }

      await AuthStorage.saveAccessToken(
        'Token ${loginResp.token}; userId=${loginResp.userId}',
        loginResp.userId.toString(),
      );

      final user = await Api.getLoggedInUserInfo(loginResp);

      if (user == null) {
        log("[UserRepo] Empty user info response.");
        return false;
      }

      this.user = user;
      _isLogin = true;
      _onLoginStateChange();
      return true;
    } catch (e, st) {
      log(
        "[UserRepo] Login process failed with error :",
        error: e,
        stackTrace: st,
      );
      _isLogin = false;
      return false;
    }
  }

  bool logout() {
    if (AuthStorage.hasToken && AuthStorage.hasUserId) {
      HttpUtils.setToken("");
      AuthStorage.logout();
      _isLogin = false;
      _onLoginStateChange();
      return true;
    }
    return false;
  }

  bool get isLogin => user != null && user?.id != 0 && _isLogin == true;
  UserRepoState get loginState => _state;

  UserInfo? user;
  bool _isLogin = false;
  UserRepoState _state = UserRepoState.kUnknown;
}
