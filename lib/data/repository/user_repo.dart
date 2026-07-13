import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/model/group_info.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/repository/user/session_repository.dart';
import 'package:star_forum/data/repository/user/user_directory_repository.dart';
import 'package:star_forum/data/repository/user/user_profile_mutation_service.dart';
import 'package:star_forum/data/repository/user/user_repository.dart';

export 'user/session_repository.dart' show UserRepoState;
export 'user/user_directory_repository.dart' show UserDirectorySort;

class UserRepo {
  UserRepo(
    this.sessionRepository,
    this.userRepository,
    this.directoryRepository,
    this.profileMutationService,
  );

  final SessionRepository sessionRepository;
  final UserRepository userRepository;
  final UserDirectoryRepository directoryRepository;
  final UserProfileMutationService profileMutationService;

  UserRepoState get state => sessionRepository.state;
  bool get isLogin => sessionRepository.isLogin;
  UserInfo? get user => sessionRepository.user;
  int get userId => sessionRepository.userId;

  Future<RepoResult<UserInfo>> getUserInfoByNameOrId(
    String idOrName, {
    CancelToken? cancelToken,
  }) {
    return userRepository.getByNameOrId(idOrName, cancelToken: cancelToken);
  }

  Future<UserInfo?> getCachedUserInfoByNameOrId(String idOrName) {
    return userRepository.getCachedByNameOrId(idOrName);
  }

  Future<PagedRepoResult<UserInfo>> getUserDirectory({
    int limit = 100,
    int offset = 0,
    UserDirectorySort sort = UserDirectorySort.unknown,
    int? groupId,
    CancelToken? cancelToken,
  }) {
    return directoryRepository.getDirectory(
      limit: limit,
      offset: offset,
      sort: sort,
      groupId: groupId,
      cancelToken: cancelToken,
    );
  }

  Future<List<UserInfo>> getCachedUserDirectory({
    int limit = 100,
    int offset = 0,
    UserDirectorySort sort = UserDirectorySort.unknown,
    int? groupId,
  }) {
    return directoryRepository.getCachedDirectory(
      limit: limit,
      offset: offset,
      sort: sort,
      groupId: groupId,
    );
  }

  Future<RepoResult<List<GroupInfo>>> getUserGroups({
    CancelToken? cancelToken,
    bool force = false,
  }) {
    return directoryRepository.getGroups(
      cancelToken: cancelToken,
      force: force,
    );
  }

  Future<RepoResult<void>> uploadAvatar({
    required int userId,
    required Uint8List fileData,
    required String fileName,
  }) {
    return profileMutationService.uploadAvatar(
      userId: userId,
      fileData: fileData,
      fileName: fileName,
    );
  }

  Future<RepoResult<void>> updateBio(int userId, String bio) {
    return profileMutationService.updateBio(userId, bio);
  }

  Future<RepoResult<void>> updateNickname({
    required int userId,
    required String username,
    required String nickname,
  }) {
    return profileMutationService.updateNickname(
      userId: userId,
      username: username,
      nickname: nickname,
    );
  }

  Future<RepoResult<List<UserBadge>>> getUserBadges(
    int userId, {
    CancelToken? cancelToken,
  }) {
    return userRepository.getBadges(userId, cancelToken: cancelToken);
  }

  Future<void> setup() => sessionRepository.setup();

  Future<bool> login(
    String username,
    String password, {
    bool autoRelogin = true,
  }) {
    return sessionRepository.login(
      username,
      password,
      autoRelogin: autoRelogin,
    );
  }

  Future<bool> refreshCurrentUser() {
    return sessionRepository.refreshCurrentUser();
  }

  Future<void> logout() => sessionRepository.logout();

  Future<void> refreshForumPermissions() {
    return sessionRepository.refreshPermissions();
  }
}
