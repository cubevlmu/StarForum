/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:forum/data/auth/storage_keys.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:hive/hive.dart';

class AuthStorage {
  static Box get _box => StorageUtils.networkData;

  static String? get accessToken => _box.get(AuthStorageKeys.accessToken);
  static String? get userId => _box.get(AuthStorageKeys.userId);

  static Future<void> saveAccessToken(String token, String userId) async {
    await _box.put(AuthStorageKeys.accessToken, token);
    await _box.put(
      AuthStorageKeys.tokenCreatedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _box.put(AuthStorageKeys.userId, userId);
  }

  static Future<void> clear() async {
    await _box.delete(AuthStorageKeys.accessToken);
    await _box.delete(AuthStorageKeys.tokenCreatedAt);
    await _box.delete(AuthStorageKeys.userId);
  }

  static Future<void> logout() async {
    await AuthStorage.clear();
    await StorageUtils.user.clear(); // 清用户信息
  }

  static bool get hasToken => accessToken != null && accessToken!.isNotEmpty;
  static bool get hasUserId => userId != null && userId!.isNotEmpty;
}
