import 'dart:typed_data';

import 'package:star_forum/data/api/services/user_api.dart';
import 'package:star_forum/data/repository/repo_result.dart';

class UserProfileMutationService {
  UserProfileMutationService(this.userApi);

  final UserApi userApi;

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
      name: 'user.uploadAvatar',
    );
  }

  Future<RepoResult<void>> updateBio(int userId, String bio) {
    return RepoResult.guardBool(
      () => userApi.update(userId, attributes: {'bio': bio}),
      name: 'user.updateBio',
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
      name: 'user.updateProfile',
    );
  }
}
