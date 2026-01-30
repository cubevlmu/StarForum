/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtils {
  static const String userAvatar = 'userAvatar';
  static const String contentImage = 'content';

  static final CacheManager avatarCacheManager = CacheManager(Config(userAvatar));
  static final CacheManager contentCacheManager = CacheManager(Config(contentImage));

  static final List<CacheManager> cacheMangerList = [
    avatarCacheManager,
    contentCacheManager
  ];

  ///释放所有图像内存
  static void clearAllCacheImageMem() {
    for (var cacheManager in cacheMangerList) {
      cacheManager.store.emptyMemoryCache();
    }
  }

  ///删除所有图片缓存（除了用户头像缓存）
  static Future<void> deleteAllCacheImage() async {
    for (var cacheManager in cacheMangerList) {
      //不删除用户头像
      if (cacheManager == avatarCacheManager) continue;
      await cacheManager.store.emptyCache();
    }
  }
}
