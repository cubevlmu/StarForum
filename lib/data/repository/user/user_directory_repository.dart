import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/services/user_api.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/db/mappers/user_cache_mapper.dart';
import 'package:star_forum/data/model/group_info.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/repo_result.dart';

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

class UserDirectoryRepository {
  UserDirectoryRepository(
    this.userApi,
    this.apiClient,
    this.resourceCacheDao,
    this.collectionDao,
  );

  final UserApi userApi;
  final FlarumApiClient apiClient;
  final ResourceCacheDao resourceCacheDao;
  final CacheCollectionDao collectionDao;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();
  List<GroupInfo> _groups = const [];
  DateTime? _groupsSyncedAt;

  Future<RepoResult<List<GroupInfo>>> getGroups({
    CancelToken? cancelToken,
    bool force = false,
  }) {
    final syncedAt = _groupsSyncedAt;
    if (!force &&
        _groups.isNotEmpty &&
        syncedAt != null &&
        DateTime.now().difference(syncedAt) < const Duration(minutes: 15)) {
      return Future.value(RepoResult.success(_groups, fromCache: true));
    }
    return _requests.run('user-groups', () async {
      final result = await RepoResult.guard(
        () => userApi.groups(cancelToken: cancelToken),
        name: 'user.groups',
      );
      final groups = result.data;
      if (groups != null && groups.isNotEmpty) {
        _groups = List.unmodifiable(groups);
        _groupsSyncedAt = DateTime.now();
        return RepoResult.success(_groups);
      }
      if (_groups.isNotEmpty) {
        return RepoResult.success(_groups, fromCache: true);
      }
      return result;
    }, coalesce: cancelToken == null);
  }

  Future<PagedRepoResult<UserInfo>> getDirectory({
    int limit = 100,
    int offset = 0,
    UserDirectorySort sort = UserDirectorySort.unknown,
    int? groupId,
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
        groupId: groupId,
        cancelToken: cancelToken,
      );
      if (data == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      await resourceCacheDao.upsertUsers([
        for (final user in data.items) user.toDbUser(),
      ]);
      await _saveCollection(
        sort: sort,
        groupId: groupId,
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
      final cached = await getCachedDirectory(
        sort: sort,
        groupId: groupId,
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

  Future<List<UserInfo>> getCachedDirectory({
    int limit = 100,
    int offset = 0,
    UserDirectorySort sort = UserDirectorySort.unknown,
    int? groupId,
  }) async {
    final window = await collectionDao.getWindow(
      collectionKey: UserCollectionKey.directory(sort.name, groupId: groupId),
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

  Future<void> _saveCollection({
    required UserDirectorySort sort,
    required int? groupId,
    required List<UserInfo> users,
    required int offset,
    required int limit,
    required String? nextUrl,
  }) async {
    final now = DateTime.now();
    await collectionDao.replaceWindowAndMarkSynced(
      collectionKey: UserCollectionKey.directory(sort.name, groupId: groupId),
      resourceType: CacheResourceType.user,
      offset: offset,
      windowLimit: limit,
      items: [
        for (var index = 0; index < users.length; index += 1)
          DbCacheCollectionItemsCompanion.insert(
            collectionKey: UserCollectionKey.directory(
              sort.name,
              groupId: groupId,
            ),
            resourceType: CacheResourceType.user,
            resourceId: users[index].id.toString(),
            sortIndex: offset + index,
            fingerprint: users[index].fingerprint,
            seenAt: now,
            syncedAt: now,
          ),
      ],
      keepLimit: 500,
      nextUrl: nextUrl,
      syncedAt: now,
      ttlSeconds: 300,
    );
  }
}
