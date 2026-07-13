import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/services/discussion_api.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/repository/discussion/discussion_cache_writer.dart';
import 'package:star_forum/data/repository/repo_result.dart';

class DiscussionMutationService {
  DiscussionMutationService(this.discussionApi, this.cacheWriter);

  final DiscussionApi discussionApi;
  final DiscussionCacheWriter cacheWriter;

  Future<RepoResult<DiscussionDetail>> create(
    List<int> tags,
    String title,
    String content,
  ) {
    return RepoResult.guard(
      () => discussionApi.create(tags, title, content),
      name: 'discussion.create',
    );
  }

  Future<RepoResult<void>> setFollow({
    required String discussionId,
    required bool follow,
  }) async {
    bool ok;
    try {
      ok = await discussionApi.setFollow(discussionId, follow);
    } on FlarumTransportError catch (error) {
      return RepoResult.failure(RepoError.fromTransport(error));
    }
    if (!ok) return const RepoResult.failure(RepoError.operationFailed);

    await cacheWriter.updateSubscriptionIfExists(
      discussionId: discussionId,
      subscription: follow ? 1 : 0,
    );
    return const RepoResult.success(null);
  }
}
