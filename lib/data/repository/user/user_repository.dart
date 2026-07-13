import 'package:dio/dio.dart';
import 'package:star_forum/data/api/services/user_api.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/db/mappers/user_cache_mapper.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/repo_result.dart';

class UserRepository {
  UserRepository(this.userApi, this.resourceCacheDao);

  final UserApi userApi;
  final ResourceCacheDao resourceCacheDao;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  Future<RepoResult<UserInfo>> getByNameOrId(
    String idOrName, {
    CancelToken? cancelToken,
  }) {
    return _requests.run('user:$idOrName', () async {
      final cached = await getCachedByNameOrId(idOrName);
      final result = await RepoResult.guard(
        () => fetchAndCache(idOrName, cancelToken: cancelToken),
        name: 'user.getById',
      );
      if (result.data == null && cached != null) {
        return RepoResult.success(cached, fromCache: true);
      }
      return result;
    }, coalesce: cancelToken == null);
  }

  Future<UserInfo?> fetchAndCache(
    String idOrName, {
    CancelToken? cancelToken,
  }) async {
    final user = await userApi.getByNameOrId(
      idOrName,
      cancelToken: cancelToken,
    );
    if (user != null) {
      await resourceCacheDao.upsertUsers([user.toDbUser()]);
    }
    return user;
  }

  Future<UserInfo?> getCachedByNameOrId(String idOrName) async {
    final id = int.tryParse(idOrName);
    if (id == null) return null;
    final row = await resourceCacheDao.getUser(id);
    return row?.toUserInfo();
  }

  Future<RepoResult<List<UserBadge>>> getBadges(
    int userId, {
    CancelToken? cancelToken,
  }) {
    return RepoResult.guard(
      () => userApi.badges(userId, cancelToken: cancelToken),
      name: 'user.badges',
    );
  }
}
