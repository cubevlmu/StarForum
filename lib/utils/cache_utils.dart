/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtils {
  static const String userAvatar = 'userAvatar';
  static const String contentImage = 'content';
  static const String assetThumb = 'assetThumb';
  static const List<String> cacheKeys = [userAvatar, contentImage, assetThumb];

  static final avatarCacheManager = CacheManager(
    Config(
      userAvatar,
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 300,
    ),
  );
  static final contentCacheManager = CacheManager(Config(contentImage));
  static final assetThumbCacheManager = CacheManager(
    Config(
      assetThumb,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 120,
    ),
  );

  static final List<CacheManager> cacheMangerList = [
    avatarCacheManager,
    contentCacheManager,
    assetThumbCacheManager,
  ];

  static void clearAllCacheImageMem() {
    for (var cacheManager in cacheMangerList) {
      cacheManager.store.emptyMemoryCache();
    }
  }

  static Future<void> deleteAllCacheImage() async {
    for (var cacheManager in cacheMangerList) {
      await cacheManager.store.emptyCache();
    }
  }
}
