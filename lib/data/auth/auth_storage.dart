/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:star_forum/data/auth/app_secure_storage.dart';
import 'package:star_forum/data/auth/storage_keys.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:hive/hive.dart';
import 'package:star_forum/data/api/flarum_auth.dart';

class AuthStorage {
  final _secure = createAppSecureStorage();
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
      await _box.put(AuthStorageKeys.authKind, parsed.kind.name);
    }
    return parsed;
  }

  Future<String?> takeLegacyPassword() async {
    final value = await _secure.read(key: AuthStorageKeys.password);
    await Future.wait([
      _secure.delete(key: AuthStorageKeys.password),
      _box.delete(AuthStorageKeys.lastInputPwd),
      _box.delete(AuthStorageKeys.autoRelogin),
    ]);
    return value;
  }

  Future<void> saveLogin({
    required String token,
    required String userId,
    FlarumAuthKind authKind = FlarumAuthKind.accessToken,
    String? username,
  }) async {
    final snapshot = await _snapshot();
    try {
      await _box.put(UserStorageKeys.hasLogin, false);
      await _secure.write(key: AuthStorageKeys.accessToken, value: token);
      await _box.putAll({
        AuthStorageKeys.userId: userId,
        AuthStorageKeys.autoRelogin: false,
        AuthStorageKeys.authKind: authKind.name,
        AuthStorageKeys.tokenCreatedAt: DateTime.now().millisecondsSinceEpoch,
      });
      if (username == null) {
        await _box.delete(AuthStorageKeys.username);
      } else {
        await _box.put(AuthStorageKeys.username, username);
      }
      await Future.wait([
        _secure.delete(key: AuthStorageKeys.password),
        _box.delete(AuthStorageKeys.lastInputPwd),
      ]);
      await _box.put(UserStorageKeys.hasLogin, true);
      _cachedToken = token;
    } catch (error, stackTrace) {
      try {
        await _restore(snapshot);
      } catch (_) {}
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> clear() async {
    _cachedToken = null;
    await _box.put(UserStorageKeys.hasLogin, false);
    await Future.wait([
      _box.delete(AuthStorageKeys.userId),
      _box.delete(AuthStorageKeys.authKind),
      _box.delete(AuthStorageKeys.autoRelogin),
      _box.delete(AuthStorageKeys.username),
      _box.delete(AuthStorageKeys.tokenCreatedAt),
      _box.delete(AuthStorageKeys.lastInputPwd),
      _secure.delete(key: AuthStorageKeys.accessToken),
      _secure.delete(key: AuthStorageKeys.password),
    ]);
  }

  Future<void> clearAutoLogin() async {
    await Future.wait([
      _box.delete(AuthStorageKeys.username),
      _box.delete(AuthStorageKeys.autoRelogin),
      _box.delete(AuthStorageKeys.lastInputPwd),
      _secure.delete(key: AuthStorageKeys.password),
    ]);
  }

  Future<_AuthStorageSnapshot> _snapshot() async {
    final keys = <String>[
      UserStorageKeys.hasLogin,
      AuthStorageKeys.userId,
      AuthStorageKeys.autoRelogin,
      AuthStorageKeys.username,
      AuthStorageKeys.authKind,
      AuthStorageKeys.tokenCreatedAt,
      AuthStorageKeys.lastInputPwd,
    ];
    final values = <String, Object?>{};
    final presentKeys = <String>{};
    for (final key in keys) {
      if (_box.containsKey(key)) {
        presentKeys.add(key);
        values[key] = _box.get(key);
      }
    }
    return _AuthStorageSnapshot(
      values: values,
      presentKeys: presentKeys,
      accessToken: await _secure.read(key: AuthStorageKeys.accessToken),
      password: await _secure.read(key: AuthStorageKeys.password),
      cachedToken: _cachedToken,
    );
  }

  Future<void> _restore(_AuthStorageSnapshot snapshot) async {
    final keysToDelete = snapshot.allKeys.difference(snapshot.presentKeys);
    await Future.wait([
      if (snapshot.values.isNotEmpty) _box.putAll(snapshot.values),
      for (final key in keysToDelete) _box.delete(key),
      _writeOrDeleteSecure(AuthStorageKeys.accessToken, snapshot.accessToken),
      _writeOrDeleteSecure(AuthStorageKeys.password, snapshot.password),
    ]);
    _cachedToken = snapshot.cachedToken;
  }

  Future<void> _writeOrDeleteSecure(String key, String? value) {
    return value == null
        ? _secure.delete(key: key)
        : _secure.write(key: key, value: value);
  }
}

class _AuthStorageSnapshot {
  const _AuthStorageSnapshot({
    required this.values,
    required this.presentKeys,
    required this.accessToken,
    required this.password,
    required this.cachedToken,
  });

  final Map<String, Object?> values;
  final Set<String> presentKeys;
  final String? accessToken;
  final String? password;
  final String? cachedToken;

  Set<String> get allKeys => const {
    UserStorageKeys.hasLogin,
    AuthStorageKeys.userId,
    AuthStorageKeys.autoRelogin,
    AuthStorageKeys.username,
    AuthStorageKeys.authKind,
    AuthStorageKeys.tokenCreatedAt,
    AuthStorageKeys.lastInputPwd,
  };
}
