import 'dart:async';

import 'package:dio/dio.dart';
import 'package:star_forum/data/background/background_task_scheduler.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/services/discussion_api.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/repository/discussion/discussion_cache_writer.dart';
import 'package:star_forum/data/repository/discussion/discussion_excerpt_hydrator.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/sync/sync_status.dart';
import 'package:star_forum/utils/setting_util.dart';

class DiscussionFeedRepository {
  DiscussionFeedRepository(
    this.discussionsDao,
    this.collectionDao,
    this.syncStatus,
    this.discussionApi,
    this.cacheWriter,
    this.excerptHydrator,
    this.backgroundTasks,
  );

  final DiscussionsDao discussionsDao;
  final CacheCollectionDao collectionDao;
  final SyncStatusService syncStatus;
  final DiscussionApi discussionApi;
  final DiscussionCacheWriter cacheWriter;
  final DiscussionExcerptHydrator excerptHydrator;
  final BackgroundTaskScheduler backgroundTasks;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  Stream<List<DiscussionSummary>> watchItems({required int limit}) {
    return discussionsDao.watchPaged(
      limit,
      collectionKey: DiscussionCollectionKey.feed(),
      showExcerpt: SettingsUtil.showDiscussionExcerpt,
      keepStickyOnTop: SettingsUtil.keepStickyDiscussionsOnTop,
    );
  }

  Future<int> count() => discussionsDao.countAll();

  Future<void> cancelHydration() =>
      backgroundTasks.cancel('discussion-excerpt');

  Future<RepoResult<bool>> syncPage({
    required int offset,
    required int limit,
    String sortKey = '',
    String? tagSlug,
    CancelToken? cancelToken,
    bool reportStatus = true,
    bool force = false,
  }) {
    final collectionKey = DiscussionCollectionKey.feed(
      sort: sortKey,
      tagSlug: tagSlug,
    );
    return _requests.run(
      'sync:$collectionKey:$offset:$limit:$reportStatus:$force',
      () => _syncPage(
        offset: offset,
        limit: limit,
        sortKey: sortKey,
        tagSlug: tagSlug,
        cancelToken: cancelToken,
        reportStatus: reportStatus,
        force: force,
      ),
      coalesce: cancelToken == null,
    );
  }

  Future<RepoResult<bool>> _syncPage({
    required int offset,
    required int limit,
    required String sortKey,
    required String? tagSlug,
    required CancelToken? cancelToken,
    required bool reportStatus,
    required bool force,
  }) async {
    final collectionKey = DiscussionCollectionKey.feed(
      sort: sortKey,
      tagSlug: tagSlug,
    );
    if (!force && offset == 0) {
      final freshState = await collectionDao.getFreshSyncState(collectionKey);
      if (freshState != null) {
        return RepoResult.success(
          freshState.nextUrl != null && freshState.nextUrl!.isNotEmpty,
          fromCache: true,
        );
      }
    }

    final syncTime = DateTime.now();
    try {
      if (reportStatus) syncStatus.start(SyncPhase.checking);
      FlarumPage<DiscussionDetail>? page;
      try {
        page = await discussionApi.list(
          sortKey,
          tagSlug: tagSlug,
          offset: offset,
          limit: limit,
          cancelToken: cancelToken,
        );
      } on FlarumTransportError catch (error) {
        await collectionDao.setSyncState(
          collectionKey: collectionKey,
          lastSyncAt: syncTime,
          lastError: error.message,
        );
        return RepoResult.failure(RepoError.fromTransport(error));
      }
      if (page == null) return const RepoResult.failure(RepoError.empty);

      final changed = await cacheWriter.saveCollectionPage(
        collectionKey: collectionKey,
        remote: page.items,
        offset: offset,
        limit: limit,
        nextUrl: page.nextUrl,
        ttlSeconds: offset == 0 ? 30 : 120,
      );
      final targets = await excerptHydrator.targets(page.items, changed);
      if (targets.isNotEmpty) {
        final hydration = backgroundTasks.run(
          name: 'discussion-excerpt',
          dedupeKey: _hydrationKey(targets),
          task: (token) =>
              excerptHydrator.hydrate(targets, cancellationToken: token),
        );
        unawaited(hydration);
      }
      return RepoResult.success(page.hasMore || page.items.length >= limit);
    } finally {
      if (reportStatus) syncStatus.finish();
    }
  }

  String _hydrationKey(List<DiscussionDetail> items) {
    final ids = items.map((item) => item.id).toList()..sort();
    return ids.join(',');
  }
}
