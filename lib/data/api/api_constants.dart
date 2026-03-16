/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

class ApiConstants {
  static final String userAgent = 'StarForumApp/1.0';

  static const int pageSize = 20;

  static const String fixedApiDefineKey = 'FIXED_API';
  static const String fixedApi = String.fromEnvironment(
    fixedApiDefineKey,
    defaultValue: '',
  );
  static bool get hasFixedApi => fixedApi.isNotEmpty;
}
