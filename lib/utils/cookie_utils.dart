/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:forum/data/api/api_constants.dart';

import 'http_utils.dart';

class CookieUtils {
  static Future<String> getCsrf() async {
    //从cookie中获取csrf需要的数据
    for (var i in (await HttpUtils.cookieManager.cookieJar.loadForRequest(
      Uri.parse(ApiConstants.apiBase),
    ))) {
      if (i.name == 'Authorization') {
        return i.value;
      }
    }
    return '';
  }
}
