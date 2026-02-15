/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtils {
  static const String userAvatar = 'userAvatar';
  static const String contentImage = 'content';

  static final avatarCacheManager = CacheManager(Config(userAvatar));
  static final contentCacheManager = CacheManager(Config(contentImage));

  static final List<CacheManager> cacheMangerList = [
    avatarCacheManager,
    contentCacheManager,
  ];

  static void clearAllCacheImageMem() {
    for (var cacheManager in cacheMangerList) {
      cacheManager.store.emptyMemoryCache();
    }
  }

  static Future<void> deleteAllCacheImage() async {
    for (var cacheManager in cacheMangerList) {
      if (cacheManager == avatarCacheManager) continue;
      await cacheManager.store.emptyCache();
    }
  }
}
