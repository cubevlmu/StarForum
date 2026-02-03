/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

class ApiConstants {
  static final String userAgent = 'StarForumApp/1.0';

  static String apiBase = ""; // For ATC "https://bbs.atcraftmc.cn"

  static final String discussions = "$apiBase/api/discussions";
  static final String discussionDetail = "$apiBase/api/discussions";

  static final String token = '$apiBase/api/token';
  static final String users = '$apiBase/api/users';
  static final String usersMe = '$apiBase/api/users/me';
  static final String tags = '$apiBase/api/tags';

  static const int pageSize = 20;
}
