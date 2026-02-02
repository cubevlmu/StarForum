/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forum/data/auth/storage_keys.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:hive/hive.dart';

class AuthStorage {
  final _secure = FlutterSecureStorage();
  Box get _box => StorageUtils.networkData;

  String? _cachedToken;

  bool get hasLogin => _box.get(UserStorageKeys.hasLogin) == true;
  String? get userId => _box.get(AuthStorageKeys.userId);
  String? get username => _box.get(AuthStorageKeys.username);
  bool get autoRelogin => _box.get(AuthStorageKeys.autoRelogin) == true;
  DateTime? get lastInputPwdTime => _box.get(AuthStorageKeys.lastInputPwd);

  Future<String?> get accessToken async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _secure.read(key: AuthStorageKeys.accessToken);
    return _cachedToken;
  }

  Future<String?> get password async =>
      _secure.read(key: AuthStorageKeys.password);

  Future<void> saveLogin({
    required String token,
    required String userId,
    bool autoRelogin = false,
    String? username,
    String? password,
  }) async {
    _box.put(UserStorageKeys.hasLogin, true);
    _box.put(AuthStorageKeys.userId, userId);
    _box.put(AuthStorageKeys.autoRelogin, autoRelogin);
    _box.put(AuthStorageKeys.username, username);
    _box.put(
      AuthStorageKeys.tokenCreatedAt,
      DateTime.now().millisecondsSinceEpoch,
    );

    _cachedToken = token;
    await _secure.write(key: AuthStorageKeys.accessToken, value: token);

    if (autoRelogin && password != null) {
      await _secure.write(key: AuthStorageKeys.password, value: password);
      _box.put(AuthStorageKeys.lastInputPwd, DateTime.now());
    }
  }

  Future<void> clear() async {
    _cachedToken = null;
    _box.put(UserStorageKeys.hasLogin, false);
    _box.delete(AuthStorageKeys.userId);

    await _secure.delete(key: AuthStorageKeys.accessToken);
  }

  void clearAutoLogin() async {
    _box.delete(AuthStorageKeys.username);
    await _secure.delete(key: AuthStorageKeys.password);
  }
}
