import 'dart:async';

import 'package:dio/dio.dart';
import 'package:star_forum/data/background/background_task_scheduler.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/services/discussion_api.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/repository/discussion/discussion_cache_writer.dart';
import 'package:star_forum/data/repository/discussion/discussion_excerpt_hydrator.dart';
import 'package:star_forum/data/repository/repo_result.dart';

enum DiscussionFollowingSort { hottest, latestReply, newest, oldest, mostViews }

FollowingSort _toApiFollowingSort(DiscussionFollowingSort sort) {
  return switch (sort) {
    DiscussionFollowingSort.hottest => FollowingSort.hottest,
    DiscussionFollowingSort.latestReply => FollowingSort.latestReply,
    DiscussionFollowingSort.newest => FollowingSort.newest,
    DiscussionFollowingSort.oldest => FollowingSort.oldest,
    DiscussionFollowingSort.mostViews => FollowingSort.mostViews,
  };
}

class DiscussionDetailRepository {
  DiscussionDetailRepository(
    this.discussionsDao,
    this.collectionDao,
    this.discussionApi,
    this.cacheWriter,
    this.excerptHydrator,
    this.backgroundTasks,
  );

  final DiscussionsDao discussionsDao;
  final CacheCollectionDao collectionDao;
  final DiscussionApi discussionApi;
  final DiscussionCacheWriter cacheWriter;
  final DiscussionExcerptHydrator excerptHydrator;
  final BackgroundTaskScheduler backgroundTasks;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  Future<RepoResult<DiscussionDetail>> getById(
    String id, {
    CancelToken? cancelToken,
  }) {
    return _requests.run('discussion:$id', () async {
      final result = await RepoResult.guard(
        () => discussionApi.getById(id, cancelToken: cancelToken),
        name: 'discussion.getById',
      );
      final error = result.error;
      if (error != null &&
          (error.statusCode == 403 || error.statusCode == 404)) {
        await discussionsDao.markDeleted(id);
      }
      return result;
    }, coalesce: cancelToken == null);
  }

  Future<PagedRepoResult<DiscussionSummary>> getFollowing({
    DiscussionFollowingSort sort = DiscussionFollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) async {
    final collectionKey = DiscussionCollectionKey.following(sort.name);
    try {
      final page = await discussionApi.following(
        sort: _toApiFollowingSort(sort),
        offset: offset,
        limit: limit,
      );
      if (page == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      final changed = await cacheWriter.saveCollectionPage(
        collectionKey: collectionKey,
        remote: page.items,
        offset: offset,
        limit: limit,
        nextUrl: page.nextUrl,
        ttlSeconds: offset == 0 ? 30 : 120,
      );
      await _hydrateInBackground(page.items, changed);
      final displayItems = await excerptHydrator.withCachedFirstPosts(
        await discussionsDao.getCachedCollection(
          collectionKey: collectionKey,
          offset: offset,
          limit: limit,
        ),
      );
      return PagedRepoResult.success(
        _toSummaries(displayItems.isEmpty ? page.items : displayItems),
        nextUrl: page.nextUrl,
        hasMoreOverride: page.hasMore || page.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      final cached = await getCachedFollowing(
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

  Future<List<DiscussionSummary>> getCachedFollowing({
    DiscussionFollowingSort sort = DiscussionFollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) async {
    final items = await excerptHydrator.withCachedFirstPosts(
      await discussionsDao.getCachedCollection(
        collectionKey: DiscussionCollectionKey.following(sort.name),
        offset: offset,
        limit: limit,
      ),
    );
    return _toSummaries(items);
  }

  Future<PagedRepoResult<DiscussionSummary>> getByTag({
    required String tag,
    int offset = 0,
    int limit = 20,
    bool force = false,
  }) async {
    final collectionKey = DiscussionCollectionKey.feed(tagSlug: tag);
    if (!force && offset == 0 && await collectionDao.isFresh(collectionKey)) {
      final cached = await discussionsDao.getCachedCollection(
        collectionKey: collectionKey,
        offset: offset,
        limit: limit,
      );
      if (cached.isNotEmpty) {
        final displayItems = await excerptHydrator.withCachedFirstPosts(cached);
        return PagedRepoResult.success(
          _toSummaries(displayItems),
          hasMoreOverride: displayItems.length >= limit,
          fromCache: true,
        );
      }
    }
    try {
      final page = await discussionApi.byTag(
        tag: tag,
        offset: offset,
        limit: limit,
      );
      if (page == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      final changed = await cacheWriter.saveCollectionPage(
        collectionKey: collectionKey,
        remote: page.items,
        offset: offset,
        limit: limit,
        nextUrl: page.nextUrl,
        ttlSeconds: 120,
      );
      await _hydrateInBackground(page.items, changed);
      final cached = await excerptHydrator.withCachedFirstPosts(
        await discussionsDao.getCachedCollection(
          collectionKey: collectionKey,
          offset: offset,
          limit: limit,
        ),
      );
      return PagedRepoResult.success(
        _toSummaries(cached.isEmpty ? page.items : cached),
        nextUrl: page.nextUrl,
        hasMoreOverride: page.hasMore || page.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      final cached = await excerptHydrator.withCachedFirstPosts(
        await discussionsDao.getCachedCollection(
          collectionKey: collectionKey,
          offset: offset,
          limit: limit,
        ),
      );
      if (cached.isNotEmpty) {
        return PagedRepoResult.success(
          _toSummaries(cached),
          hasMoreOverride: cached.length >= limit,
          fromCache: true,
        );
      }
      return PagedRepoResult.failure(RepoError.fromTransport(error));
    }
  }

  Future<PagedRepoResult<DiscussionSummary>> getByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final collectionKey = DiscussionCollectionKey.byAuthor(username);
    try {
      final page = await discussionApi.byAuthor(
        username: username,
        offset: offset,
        limit: limit,
        cancelToken: cancelToken,
      );
      if (page == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      final changed = await cacheWriter.saveCollectionPage(
        collectionKey: collectionKey,
        remote: page.items,
        offset: offset,
        limit: limit,
        nextUrl: page.nextUrl,
        ttlSeconds: 120,
      );
      await _hydrateInBackground(page.items, changed);
      final displayItems = await excerptHydrator.withCachedFirstPosts(
        page.items,
      );
      return PagedRepoResult.success(
        _toSummaries(displayItems),
        nextUrl: page.nextUrl,
        hasMoreOverride: page.hasMore || page.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      final cached = await getCachedByAuthor(
        username: username,
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

  Future<List<DiscussionSummary>> getCachedByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
  }) async {
    final items = await excerptHydrator.withCachedFirstPosts(
      await discussionsDao.getCachedCollection(
        collectionKey: DiscussionCollectionKey.byAuthor(username),
        offset: offset,
        limit: limit,
      ),
    );
    return _toSummaries(items);
  }

  Future<PagedRepoResult<DiscussionSummary>> search({
    required String key,
    String? tagSlug,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return _toPagedResult(
      discussionApi.search(
        key: key,
        tagSlug: tagSlug,
        offset: offset,
        limit: limit,
        cancelToken: cancelToken,
      ),
      limit: limit,
      map: (discussion) => discussion.toSummary(),
    );
  }

  Future<void> _hydrateInBackground(
    List<DiscussionDetail> items,
    List<DiscussionDetail> changed,
  ) async {
    final targets = await excerptHydrator.targets(items, changed);
    if (targets.isEmpty) return;
    unawaited(
      backgroundTasks.run(
        name: 'discussion-excerpt',
        dedupeKey: _hydrationKey(targets),
        task: (token) =>
            excerptHydrator.hydrate(targets, cancellationToken: token),
      ),
    );
  }

  String _hydrationKey(List<DiscussionDetail> items) {
    final ids = items.map((item) => item.id).toList()..sort();
    return ids.join(',');
  }

  List<DiscussionSummary> _toSummaries(List<DiscussionDetail> discussions) {
    return discussions.map((item) => item.toSummary()).toList(growable: false);
  }
}

Future<PagedRepoResult<R>> _toPagedResult<T, R>(
  Future<FlarumPage<T>?> request, {
  required int limit,
  required R Function(T item) map,
}) async {
  try {
    final data = await request;
    if (data == null) {
      return const PagedRepoResult.failure(RepoError.empty);
    }
    return PagedRepoResult.success(
      data.items.map(map).toList(growable: false),
      nextUrl: data.nextUrl,
      hasMoreOverride: data.hasMore || data.items.length >= limit,
    );
  } on FlarumTransportError catch (error) {
    return PagedRepoResult.failure(RepoError.fromTransport(error));
  }
}
