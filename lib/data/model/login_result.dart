/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'base.dart';

@immutable
class LoginResult {
  final int userId;
  final String token;

  factory LoginResult.formMap(Map data) {
    final json = asJsonMap(data);
    return LoginResult(
      userId: JsonValue.asInt(json["userId"]),
      token: JsonValue.asString(json["token"]),
    );
  }

  const LoginResult({required this.userId, required this.token});
}
