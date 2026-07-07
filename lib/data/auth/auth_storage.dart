/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:star_forum/data/auth/storage_keys.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:hive/hive.dart';
import 'package:star_forum/data/api/flarum_auth.dart';

class AuthStorage {
  final _secure = FlutterSecureStorage(
    mOptions: const MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
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

  FlarumAuthKind get authKind {
    final value = _box.get(AuthStorageKeys.authKind)?.toString();
    return FlarumAuthKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => FlarumAuthKind.accessToken,
    );
  }

  Future<FlarumAuthToken> get authToken async {
    final stored = await accessToken;
    final parsedUserId = int.tryParse(userId ?? '');
    final parsed = FlarumAuthToken.parseLegacy(
      stored,
      storedKind: authKind,
      storedUserId: parsedUserId,
    );
    if (stored != null && stored != parsed.token) {
      _cachedToken = parsed.token;
      await _secure.write(
        key: AuthStorageKeys.accessToken,
        value: parsed.token,
      );
      _box.put(AuthStorageKeys.authKind, parsed.kind.name);
    }
    return parsed;
  }

  Future<String?> takeLegacyPassword() async {
    final value = await _secure.read(key: AuthStorageKeys.password);
    await _secure.delete(key: AuthStorageKeys.password);
    _box.delete(AuthStorageKeys.lastInputPwd);
    _box.delete(AuthStorageKeys.autoRelogin);
    return value;
  }

  Future<void> saveLogin({
    required String token,
    required String userId,
    FlarumAuthKind authKind = FlarumAuthKind.accessToken,
    String? username,
  }) async {
    _box.put(UserStorageKeys.hasLogin, true);
    _box.put(AuthStorageKeys.userId, userId);
    _box.put(AuthStorageKeys.autoRelogin, false);
    _box.put(AuthStorageKeys.username, username);
    _box.put(AuthStorageKeys.authKind, authKind.name);
    _box.put(
      AuthStorageKeys.tokenCreatedAt,
      DateTime.now().millisecondsSinceEpoch,
    );

    _cachedToken = token;
    await _secure.write(key: AuthStorageKeys.accessToken, value: token);
    await _secure.delete(key: AuthStorageKeys.password);
    _box.delete(AuthStorageKeys.lastInputPwd);
  }

  Future<void> clear() async {
    _cachedToken = null;
    _box.put(UserStorageKeys.hasLogin, false);
    _box.delete(AuthStorageKeys.userId);
    _box.delete(AuthStorageKeys.authKind);
    _box.delete(AuthStorageKeys.autoRelogin);
    _box.delete(AuthStorageKeys.username);

    await _secure.delete(key: AuthStorageKeys.accessToken);
    await _secure.delete(key: AuthStorageKeys.password);
  }

  void clearAutoLogin() async {
    _box.delete(AuthStorageKeys.username);
    await _secure.delete(key: AuthStorageKeys.password);
  }
}
