import 'package:dio/dio.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/repository/discussion/discussion_cache_writer.dart';
import 'package:star_forum/data/repository/discussion/discussion_detail_repository.dart';
import 'package:star_forum/data/repository/discussion/discussion_feed_repository.dart';
import 'package:star_forum/data/repository/discussion/discussion_mutation_service.dart';
import 'package:star_forum/data/repository/repo_result.dart';

export 'discussion/discussion_detail_repository.dart'
    show DiscussionFollowingSort;

class DiscussionRepository {
  DiscussionRepository(
    this.feedRepository,
    this.detailRepository,
    this.mutationService,
    this.cacheWriter,
  );

  final DiscussionFeedRepository feedRepository;
  final DiscussionDetailRepository detailRepository;
  final DiscussionMutationService mutationService;
  final DiscussionCacheWriter cacheWriter;

  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get lastSyncTime => _lastSyncTime;
  void beginSync(DateTime time) => _lastSyncTime = time;

  Stream<List<DiscussionSummary>> watchDiscussionSummaries({
    required int limit,
  }) {
    return feedRepository.watchItems(limit: limit);
  }

  Future<int> getDiscussionCount() => feedRepository.count();

  Future<RepoResult<DiscussionDetail>> getDiscussionById(
    String id, {
    CancelToken? cancelToken,
  }) {
    return detailRepository.getById(id, cancelToken: cancelToken);
  }

  Future<PagedRepoResult<DiscussionSummary>> getFollowingDiscussionList({
    DiscussionFollowingSort sort = DiscussionFollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) {
    return detailRepository.getFollowing(
      sort: sort,
      offset: offset,
      limit: limit,
    );
  }

  Future<List<DiscussionSummary>> getCachedFollowingDiscussionList({
    DiscussionFollowingSort sort = DiscussionFollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) {
    return detailRepository.getCachedFollowing(
      sort: sort,
      offset: offset,
      limit: limit,
    );
  }

  Future<PagedRepoResult<DiscussionSummary>> getDiscussByTag({
    required String tag,
    int offset = 0,
    int limit = 20,
    bool force = false,
  }) {
    return detailRepository.getByTag(
      tag: tag,
      offset: offset,
      limit: limit,
      force: force,
    );
  }

  Future<PagedRepoResult<DiscussionSummary>> getAuthorThemes({
    required String username,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return detailRepository.getByAuthor(
      username: username,
      offset: offset,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<List<DiscussionSummary>> getCachedAuthorThemes({
    required String username,
    int offset = 0,
    int limit = 20,
  }) {
    return detailRepository.getCachedByAuthor(
      username: username,
      offset: offset,
      limit: limit,
    );
  }

  Future<PagedRepoResult<DiscussionSummary>> searchDiscuss({
    required String key,
    String? tagSlug,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return detailRepository.search(
      key: key,
      tagSlug: tagSlug,
      offset: offset,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<RepoResult<DiscussionDetail>> createDiscussion(
    List<int> tags,
    String title,
    String content,
  ) {
    return mutationService.create(tags, title, content);
  }

  Future<RepoResult<void>> setDiscussionFollow({
    required String discussionId,
    required bool follow,
  }) {
    return mutationService.setFollow(
      discussionId: discussionId,
      follow: follow,
    );
  }

  Future<RepoResult<bool>> syncDiscussionPage({
    required int offset,
    required int limit,
    String sortKey = '',
    String? tagSlug,
    CancelToken? cancelToken,
    bool reportStatus = true,
    bool force = false,
  }) {
    return feedRepository.syncPage(
      offset: offset,
      limit: limit,
      sortKey: sortKey,
      tagSlug: tagSlug,
      cancelToken: cancelToken,
      reportStatus: reportStatus,
      force: force,
    );
  }

  Future<void> manuallyInsert(DiscussionDetail discussion) {
    return cacheWriter.manuallyInsert(discussion);
  }

  Future<void> cleanupDeletedDiscussions() {
    return cacheWriter.cleanupDeletedDiscussions();
  }

  Future<void> clearAll() async {
    await feedRepository.cancelHydration();
    await cacheWriter.clearAll();
  }

  Future<void> updateSubscriptionIfExists({
    required String discussionId,
    required int subscription,
  }) {
    return cacheWriter.updateSubscriptionIfExists(
      discussionId: discussionId,
      subscription: subscription,
    );
  }
}
