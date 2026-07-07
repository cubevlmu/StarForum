/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_auth.dart';
import 'package:star_forum/data/api/services/auth_api.dart';
import 'package:star_forum/data/api/services/user_api.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/auth/auth_storage.dart';
import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/pages/account/controller.dart';
import 'package:star_forum/pages/home/controller.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart' hide Value;

enum UserRepoState { unknown, notLogin, checkingToken, loggedIn, expired }

enum UserDirectorySort {
  unknown,
  username,
  usernameD,
  joinedAtD,
  joinedAt,
  discussionCountD,
  discussionCount,
  expD,
  exp,
}

UserSort _toApiUserSort(UserDirectorySort sort) {
  return switch (sort) {
    UserDirectorySort.unknown => UserSort.unknown,
    UserDirectorySort.username => UserSort.username,
    UserDirectorySort.usernameD => UserSort.usernameD,
    UserDirectorySort.joinedAtD => UserSort.joinedAtD,
    UserDirectorySort.joinedAt => UserSort.joinedAt,
    UserDirectorySort.discussionCountD => UserSort.discussionCountD,
    UserDirectorySort.discussionCount => UserSort.discussionCount,
    UserDirectorySort.expD => UserSort.expD,
    UserDirectorySort.exp => UserSort.exp,
  };
}

class UserRepo {
  UserRepo(
    this.authApi,
    this.userApi,
    this.apiClient,
    this.forumRepo,
    this.resourceCacheDao,
    this.collectionDao,
  );

  final AuthApi authApi;
  final UserApi userApi;
  final FlarumApiClient apiClient;
  final ForumRepository forumRepo;
  final ResourceCacheDao resourceCacheDao;
  final CacheCollectionDao collectionDao;
  UserRepoState _state = .unknown;
  UserInfo? _user;
  final storge = AuthStorage();
  final RxBool canUpload = false.obs;

  UserRepoState get state => _state;
  bool get isLogin => _state == .loggedIn;
  UserInfo? get user => _user;

  bool _setupCalled = false;
  bool _isHandling = false;
  Future<void>? _setupTask;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  int get userId => int.parse(storge.userId ?? "-1");

  Future<RepoResult<UserInfo>> getUserInfoByNameOrId(
    String idOrName, {
    CancelToken? cancelToken,
  }) {
    return _requests.run('user:$idOrName', () async {
      final cached = await getCachedUserInfoByNameOrId(idOrName);
      final result = await RepoResult.guard(
        () => userApi.getByNameOrId(idOrName, cancelToken: cancelToken),
      );
      final user = result.data;
      if (user != null) {
        await resourceCacheDao.upsertUsers([user.toDbUser()]);
      } else if (cached != null) {
        return RepoResult.success(cached, fromCache: true);
      }
      return result;
    });
  }

  Future<UserInfo?> getCachedUserInfoByNameOrId(String idOrName) async {
    final id = int.tryParse(idOrName);
    if (id == null) return null;
    final row = await resourceCacheDao.getUser(id);
    return row?.toUserInfo();
  }

  Future<PagedRepoResult<UserInfo>> getUserDirectory({
    int limit = 100,
    int offset = 0,
    UserDirectorySort sort = UserDirectorySort.unknown,
    CancelToken? cancelToken,
  }) async {
    if (!apiClient.environment.features.supportsUserDirectory) {
      return const PagedRepoResult.failure(
        RepoError(
          type: RepoErrorType.extensionUnavailable,
          message: 'User directory is unavailable on this forum.',
        ),
      );
    }
    try {
      final data = await userApi.directory(
        limit: limit,
        offset: offset,
        sort: _toApiUserSort(sort),
        cancelToken: cancelToken,
      );
      if (data == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      await resourceCacheDao.upsertUsers(
        data.items.map((user) => user.toDbUser()).toList(growable: false),
      );
      await _saveUserDirectoryCollection(
        sort: sort,
        users: data.items,
        offset: offset,
        limit: limit,
        nextUrl: data.nextUrl,
      );
      return PagedRepoResult.success(
        data.items,
        nextUrl: data.nextUrl,
        hasMoreOverride: data.hasMore || data.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      if (error.statusCode == 403 || error.statusCode == 404) {
        apiClient.setEnvironment(
          apiClient.environment.copyWith(
            features: apiClient.environment.features.copyWith(
              supportsUserDirectory: false,
            ),
          ),
        );
        return PagedRepoResult.failure(
          RepoError(
            type: RepoErrorType.extensionUnavailable,
            message: error.message,
            statusCode: error.statusCode,
            code: error.apiError?.code,
            detail: error.apiError?.detail,
            sourcePointer: error.apiError?.sourcePointer,
          ),
        );
      }
      final cached = await getCachedUserDirectory(
        sort: sort,
        offset: offset,
        limit: limit,
      );
      if (cached.isNotEmpty) {
        return PagedRepoResult.success(
          cached,
          hasMoreOverride: cached.length >= limit,
          fromCache: true,
        );
      }
      return PagedRepoResult.failure(RepoError.fromTransport(error));
    }
  }

  Future<List<UserInfo>> getCachedUserDirectory({
    int limit = 100,
    int offset = 0,
    UserDirectorySort sort = UserDirectorySort.unknown,
  }) async {
    final window = await collectionDao.getWindow(
      collectionKey: UserCollectionKey.directory(sort.name),
      resourceType: CacheResourceType.user,
      offset: offset,
      limit: limit,
    );
    final ids = window
        .map((item) => int.tryParse(item.resourceId))
        .whereType<int>()
        .toList(growable: false);
    final rows = await resourceCacheDao.getUsersByIds(ids);
    return [
      for (final id in ids)
        if (rows[id] != null) rows[id]!.toUserInfo(),
    ];
  }

  Future<void> _saveUserDirectoryCollection({
    required UserDirectorySort sort,
    required List<UserInfo> users,
    required int offset,
    required int limit,
    required String? nextUrl,
  }) async {
    final now = DateTime.now();
    await collectionDao.replaceWindow(
      collectionKey: UserCollectionKey.directory(sort.name),
      resourceType: CacheResourceType.user,
      offset: offset,
      windowLimit: limit,
      items: [
        for (var index = 0; index < users.length; index += 1)
          DbCacheCollectionItemsCompanion.insert(
            collectionKey: UserCollectionKey.directory(sort.name),
            resourceType: CacheResourceType.user,
            resourceId: users[index].id.toString(),
            sortIndex: offset + index,
            fingerprint: users[index].fingerprint,
            seenAt: now,
            syncedAt: now,
          ),
      ],
      keepLimit: 500,
    );
    await collectionDao.setSyncState(
      collectionKey: UserCollectionKey.directory(sort.name),
      nextUrl: nextUrl,
      lastSyncAt: now,
      lastSuccessAt: now,
      ttlSeconds: 300,
    );
  }

  Future<RepoResult<void>> uploadAvatar({
    required int userId,
    required Uint8List fileData,
    required String fileName,
  }) {
    return RepoResult.guardBool(
      () => userApi.uploadAvatar(
        userId: userId,
        fileData: fileData,
        fileName: fileName,
      ),
    );
  }

  Future<RepoResult<void>> updateBio(int userId, String bio) {
    return RepoResult.guardBool(
      () => userApi.update(userId, attributes: {'bio': bio}),
    );
  }

  Future<RepoResult<void>> updateNickname({
    required int userId,
    required String username,
    required String nickname,
  }) {
    return RepoResult.guardBool(
      () => userApi.update(
        userId,
        attributes: {'username': username, 'nickname': nickname},
      ),
    );
  }

  Future<RepoResult<List<UserBadge>>> getUserBadges(
    int userId, {
    CancelToken? cancelToken,
  }) {
    return RepoResult.guard(
      () => userApi.badges(userId, cancelToken: cancelToken),
    );
  }

  Future<void> setup() async {
    final activeTask = _setupTask;
    if (activeTask != null) {
      await activeTask;
      return;
    }

    final task = _performSetup();
    _setupTask = task;
    try {
      await task;
    } finally {
      if (identical(_setupTask, task)) {
        _setupTask = null;
      }
    }
  }

  Future<void> _performSetup() async {
    if (_setupCalled) {
      LogUtil.debug("[UserRepo] setup already called");
      return;
    }
    _setupCalled = true;

    if (!storge.hasLogin || storge.userId == null) {
      _setNotLogin();
      return;
    }

    _state = .checkingToken;
    apiClient.setAuth(await storge.authToken);
    final cachedMe = await getCachedUserInfoByNameOrId(storge.userId ?? '');
    if (cachedMe != null) {
      _user = cachedMe;
      _state = .loggedIn;
      _notifyLoginState();
      unawaited(refreshForumPermissions());
    }
    final legacyUsername = storge.username;
    final legacyPassword = await storge.takeLegacyPassword();

    try {
      final authInvalid = await _fetchMe();
      if (authInvalid &&
          legacyUsername != null &&
          legacyUsername.isNotEmpty &&
          legacyPassword != null &&
          legacyPassword.isNotEmpty) {
        await login(legacyUsername, legacyPassword);
      }
      unawaited(refreshForumPermissions());
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] setup failed", e, s);
      await _clearLogin();
    }
  }

  Future<bool> _fetchMe() async {
    try {
      final me = await userApi.getByNameOrId(storge.userId ?? "0");

      if (me == null) {
        LogUtil.error("[UserRepo] fetch me failed");
        await _clearLogin();
        return true;
      }

      _user = me;
      await resourceCacheDao.upsertUsers([me.toDbUser()]);
      _state = .loggedIn;
      _notifyLoginState();
      return false;
    } on FlarumTransportError catch (error, stackTrace) {
      LogUtil.errorE("[UserRepo] fetch me transport error", error, stackTrace);
      if (error.isAuthExpired) {
        await _clearLogin();
        return true;
      }
      return false;
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] fetch me error", e, s);
      return false;
    }
  }

  Future<bool> login(String usr, String pwd, {bool autoRelogin = true}) async {
    try {
      final resp = await authApi.login(
        identification: usr,
        password: pwd,
        remember: true,
      );
      if (resp == null) return false;

      await storge.saveLogin(
        token: resp.token,
        userId: resp.userId.toString(),
        authKind: FlarumAuthKind.accessToken,
        username: usr,
      );

      apiClient.setAuth(FlarumAuthToken.access(resp.token));
      final me = await userApi.getByNameOrId(resp.userId.toString());
      if (me == null) return false;

      _user = me;
      await resourceCacheDao.upsertUsers([me.toDbUser()]);
      _state = .loggedIn;
      await refreshForumPermissions();
      _notifyLoginState();
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] login failed", e, s);
      await _clearLogin();
      return false;
    }
  }

  Future<bool> refreshCurrentUser() async {
    if (!isLogin || storge.userId == null) {
      return false;
    }

    try {
      final me = await userApi.getByNameOrId(storge.userId!);
      if (me == null) {
        return false;
      }

      _user = me;
      await resourceCacheDao.upsertUsers([me.toDbUser()]);
      _state = .loggedIn;
      await refreshForumPermissions();
      _notifyLoginState();
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] refreshCurrentUser failed", e, s);
      return false;
    }
  }

  Future<void> logout() async {
    if (_isHandling) return;
    _isHandling = true;
    try {
      await authApi.logout();
      await _clearLogin();
    } finally {
      _isHandling = false;
    }
  }

  Future<void> _clearLogin() async {
    _state = .expired;
    await storge.clear();
    apiClient.clearAuth();
    canUpload.value = false;
    LogUtil.debug("[UserRepo] Login state has been cleared.");
    _setNotLogin();
  }

  void _setNotLogin() {
    _user = null;
    _state = .notLogin;
    canUpload.value = false;
    _notifyLoginState();
  }

  Future<void> refreshForumPermissions() async {
    if (!isLogin) {
      canUpload.value = false;
      return;
    }

    try {
      final result = await forumRepo.getForumInfo(
        forumRepo.baseUrl,
        force: true,
      );
      canUpload.value = result.data?.canUpload ?? false;
    } catch (e, s) {
      LogUtil.errorE("[UserRepo] refresh forum permissions failed", e, s);
      canUpload.value = false;
    }
  }

  void _notifyLoginState() {
    try {
      Get.find<HomeController>().isLogin.value = isLogin;
      Get.find<HomeController>().avatarUrl.value = _user?.avatarUrl ?? "";
    } catch (_) {}

    try {
      final notificationController = Get.find<NotificationPageController>();
      notificationController.handleLoginStateChanged(isLogin);
    } catch (_) {}

    try {
      Get.find<AccountPageController>().isLogin.value = isLogin;
    } catch (_) {}
  }
}

extension on UserInfo {
  String get fingerprint {
    return [
      id,
      username,
      displayName,
      avatarUrl,
      discussionCount,
      commentCount,
      lastSeenAt.toUtc().toIso8601String(),
    ].join('|');
  }

  DbUsersCompanion toDbUser() {
    return DbUsersCompanion.insert(
      id: Value(id),
      username: username,
      displayName: displayName,
      avatarUrl: Value(avatarUrl),
      avatarSrcset: Value(avatarSrcset),
      joinedAt: Value(joinTime),
      lastSeenAt: Value(lastSeenAt),
      discussionCount: Value(discussionCount),
      commentCount: Value(commentCount),
      email: Value(email),
      bio: Value(bio),
      syncedAt: DateTime.now(),
      deletedAt: const Value(null),
    );
  }
}

extension on DbUser {
  UserInfo toUserInfo() {
    return UserInfo(
      id,
      username,
      displayName,
      avatarUrl,
      joinedAt ?? DateTime.utc(1980),
      discussionCount,
      commentCount,
      lastSeenAt ?? DateTime.utc(1980),
      email,
      null,
      bio,
      avatarSrcset: avatarSrcset,
    );
  }
}
