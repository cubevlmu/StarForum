/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';

@immutable
class LoginResult {
  final int userId;
  final String token;

  factory LoginResult.formMap(Map data) {
    return LoginResult(userId: data["userId"] ?? 0, token: data["token"] ?? "");
  }

  const LoginResult({required this.userId, required this.token});
}
