import 'package:star_forum/data/repository/forum_repo.dart';
import 'package:star_forum/utils/log_util.dart';

class ForumPermissionService {
  ForumPermissionService(this.forumRepository);

  final ForumRepository forumRepository;

  Future<bool> canUpload({required bool authenticated}) async {
    if (!authenticated) return false;
    try {
      final result = await forumRepository.getForumInfo(
        forumRepository.baseUrl,
        force: true,
      );
      return result.data?.canUpload ?? false;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[ForumPermissionService] refresh failed',
        error,
        stackTrace,
      );
      return false;
    }
  }
}
