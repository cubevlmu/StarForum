/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/api/services/discussion_api.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/sync/sync_status.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/dao/first_posts_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/db/dao/excerpt_dao.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/setting_util.dart';

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

@immutable
class _ExcerptTask {
  const _ExcerptTask({
    required this.discussionId,
    required this.contentHtml,
    required this.sourceUpdatedAtIso,
  });

  final String discussionId;
  final String contentHtml;
  final String sourceUpdatedAtIso;
}

@immutable
class _ExcerptResult {
  const _ExcerptResult({
    required this.discussionId,
    required this.excerpt,
    required this.sourceUpdatedAtIso,
  });

  final String discussionId;
  final String excerpt;
  final String sourceUpdatedAtIso;
}

List<_ExcerptResult> _buildExcerptResults(List<_ExcerptTask> tasks) {
  return tasks
      .map((task) {
        var excerpt = htmlToPlainText(task.contentHtml);
        if (excerpt.length > 80) {
          excerpt = excerpt.substring(0, 80);
        }
        return _ExcerptResult(
          discussionId: task.discussionId,
          excerpt: excerpt,
          sourceUpdatedAtIso: task.sourceUpdatedAtIso,
        );
      })
      .where((result) => _isValidExcerpt(result.excerpt))
      .toList(growable: false);
}

bool _isValidExcerpt(String value) {
  final normalized = value.trim();
  return normalized.isNotEmpty && normalized != '...';
}

_ExcerptTask _excerptTaskFromPost({
  required String discussionId,
  required PostInfo post,
}) {
  final updatedAtRaw = post.editedAt.isNotEmpty
      ? post.editedAt
      : post.createdAt;
  final updatedAt = DateTime.tryParse(updatedAtRaw) ?? DateTime.now();
  return _ExcerptTask(
    discussionId: discussionId,
    contentHtml: post.contentHtml,
    sourceUpdatedAtIso: updatedAt.toIso8601String(),
  );
}

Future<PagedRepoResult<T>> _toPagedResult<T>(
  Future<FlarumPage<T>?> request, {
  required int limit,
}) async {
  try {
    final data = await request;
    if (data == null) {
      return const PagedRepoResult.failure(RepoError.empty);
    }
    return PagedRepoResult.success(
      data.items,
      nextUrl: data.nextUrl,
      hasMoreOverride: data.hasMore || data.items.length >= limit,
    );
  } on FlarumTransportError catch (error) {
    return PagedRepoResult.failure(RepoError.fromTransport(error));
  }
}

class DiscussionRepository {
  final DiscussionsDao discussionsDao;
  final FirstPostsDao firstPostsDao;
  final ExcerptDao excerptDao;
  final CacheCollectionDao collectionDao;
  final ResourceCacheDao resourceCacheDao;
  final SyncStatusService syncStatus;
  final PostRepository postRepo;
  final DiscussionApi discussionApi;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  DiscussionRepository(
    this.discussionsDao,
    this.firstPostsDao,
    this.excerptDao,
    this.collectionDao,
    this.resourceCacheDao,
    this.syncStatus,
    this.postRepo,
    this.discussionApi,
  );

  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get lastSyncTime => _lastSyncTime;
  void beginSync(DateTime t) {
    _lastSyncTime = t;
  }

  Stream<List<DiscussionItem>> watchDiscussionItems({required int limit}) {
    return discussionsDao.watchPaged(
      limit,
      collectionKey: DiscussionCollectionKey.feed(),
      showExcerpt: SettingsUtil.showDiscussionExcerpt,
    );
  }

  Future<int> getDiscussionCount() {
    return discussionsDao.countAll();
  }

  Future<RepoResult<DiscussionInfo>> getDiscussionById(
    String id, {
    CancelToken? cancelToken,
  }) {
    return _requests.run('discussion:$id', () async {
      final result = await RepoResult.guard(
        () => discussionApi.getById(id, cancelToken: cancelToken),
      );
      final error = result.error;
      if (error != null &&
          (error.statusCode == 403 || error.statusCode == 404)) {
        await discussionsDao.markDeleted(id);
      }
      return result;
    });
  }

  Future<PagedRepoResult<DiscussionInfo>> getFollowingDiscussionList({
    DiscussionFollowingSort sort = DiscussionFollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) async {
    final collectionKey = DiscussionCollectionKey.following(sort.name);
    try {
      final page = offset == 0
          ? await discussionApi.followingIndex(
              sort: _toApiFollowingSort(sort),
              offset: offset,
              limit: limit,
            )
          : await discussionApi.following(
              sort: _toApiFollowingSort(sort),
              offset: offset,
              limit: limit,
            );
      if (page == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      final changed = offset == 0
          ? await _saveDiscussionCollectionIndexPage(
              collectionKey: collectionKey,
              remote: page.items,
              offset: offset,
              limit: limit,
              nextUrl: page.nextUrl,
              ttlSeconds: 30,
            )
          : await _saveDiscussionCollectionPage(
              collectionKey: collectionKey,
              remote: page.items,
              offset: offset,
              limit: limit,
              nextUrl: page.nextUrl,
              ttlSeconds: 120,
            );
      final excerptTargets = await _excerptTargets(page.items, changed);
      if (excerptTargets.isNotEmpty) {
        unawaited(_saveFirstPostsAndExcerpts(excerptTargets));
      }
      final displayItems = await discussionsDao.getCachedCollection(
        collectionKey: collectionKey,
        offset: offset,
        limit: limit,
      );
      await _attachCachedFirstPosts(displayItems);
      return PagedRepoResult.success(
        displayItems.isEmpty ? page.items : displayItems,
        nextUrl: page.nextUrl,
        hasMoreOverride: page.hasMore || page.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      final cached = await getCachedFollowingDiscussionList(
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

  Future<List<DiscussionInfo>> getCachedFollowingDiscussionList({
    DiscussionFollowingSort sort = DiscussionFollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) async {
    final items = await discussionsDao.getCachedCollection(
      collectionKey: DiscussionCollectionKey.following(sort.name),
      offset: offset,
      limit: limit,
    );
    await _attachCachedFirstPosts(items);
    return items;
  }

  Future<PagedRepoResult<DiscussionInfo>> getDiscussByTag({
    required String tag,
    int offset = 0,
    int limit = 20,
  }) {
    return _toPagedResult(
      discussionApi.byTag(tag: tag, offset: offset, limit: limit),
      limit: limit,
    );
  }

  Future<PagedRepoResult<DiscussionInfo>> getAuthorThemes({
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
      final changed = await _saveDiscussionCollectionPage(
        collectionKey: collectionKey,
        remote: page.items,
        offset: offset,
        limit: limit,
        nextUrl: page.nextUrl,
        ttlSeconds: 120,
      );
      final excerptTargets = await _excerptTargets(page.items, changed);
      if (excerptTargets.isNotEmpty) {
        unawaited(_saveFirstPostsAndExcerpts(excerptTargets));
      }
      await _attachCachedFirstPosts(page.items);
      return PagedRepoResult.success(
        page.items,
        nextUrl: page.nextUrl,
        hasMoreOverride: page.hasMore || page.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      final cached = await discussionsDao.getCachedCollection(
        collectionKey: collectionKey,
        offset: offset,
        limit: limit,
      );
      await _attachCachedFirstPosts(cached);
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

  Future<List<DiscussionInfo>> getCachedAuthorThemes({
    required String username,
    int offset = 0,
    int limit = 20,
  }) async {
    final items = await discussionsDao.getCachedCollection(
      collectionKey: DiscussionCollectionKey.byAuthor(username),
      offset: offset,
      limit: limit,
    );
    await _attachCachedFirstPosts(items);
    return items;
  }

  Future<PagedRepoResult<DiscussionInfo>> searchDiscuss({
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
    );
  }

  Future<RepoResult<DiscussionInfo>> createDiscussion(
    List<int> tags,
    String title,
    String content,
  ) async {
    return RepoResult.guard(() => discussionApi.create(tags, title, content));
  }

  Future<RepoResult<void>> setDiscussionFollow({
    required String discussionId,
    required bool follow,
  }) async {
    bool ok;
    try {
      ok = await discussionApi.setFollow(discussionId, follow);
    } on FlarumTransportError catch (error) {
      return RepoResult.failure(RepoError.fromTransport(error));
    }
    if (!ok) {
      return const RepoResult.failure(RepoError.operationFailed);
    }

    await updateSubscriptionIfExists(
      discussionId: discussionId,
      subscription: follow ? 1 : 0,
    );
    return const RepoResult.success(null);
  }

  /// TIPS: Imitate RSS client caching logic to solve the problem of server delete post.
  Future<bool> syncDiscussionPage({
    required int offset,
    required int limit,
    String sortKey = '',
    String? tagSlug,
    CancelToken? cancelToken,
    bool reportStatus = true,
  }) async {
    final collectionKey = DiscussionCollectionKey.feed(
      sort: sortKey,
      tagSlug: tagSlug,
    );
    final before = await collectionDao.count(collectionKey);

    FlarumPage<DiscussionInfo>? paged;
    final syncTime = DateTime.now();
    try {
      if (reportStatus) {
        syncStatus.start(SyncPhase.checking, '正在同步主题列表');
      }
      try {
        paged = offset == 0 && before > 0
            ? await discussionApi.listIndex(
                sortKey,
                tagSlug: tagSlug,
                offset: offset,
                limit: limit,
                cancelToken: cancelToken,
              )
            : await discussionApi.list(
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
        return false;
      }

      if (paged == null) return false;

      final remote = paged.items;
      final changed = offset == 0 && before > 0
          ? await _saveDiscussionCollectionIndexPage(
              collectionKey: collectionKey,
              remote: remote,
              offset: offset,
              limit: limit,
              nextUrl: paged.nextUrl,
              ttlSeconds: 30,
              reportStatus: reportStatus,
            )
          : await _saveDiscussionCollectionPage(
              collectionKey: collectionKey,
              remote: remote,
              offset: offset,
              limit: limit,
              nextUrl: paged.nextUrl,
              ttlSeconds: offset == 0 ? 30 : 120,
            );

      final excerptTargets = await _excerptTargets(remote, changed);
      if (excerptTargets.isNotEmpty) {
        if (reportStatus) {
          syncStatus.start(SyncPhase.hydrating, '正在更新主题简介');
        }
        unawaited(
          _saveFirstPostsAndExcerpts(excerptTargets).catchError((
            Object e,
            StackTrace s,
          ) {
            LogUtil.errorE('[DiscussionRepo] Excerpt hydration failed', e, s);
          }),
        );
      }

      final after = await collectionDao.count(collectionKey);

      return paged.hasMore || remote.length >= limit || after > before;
    } finally {
      if (reportStatus) {
        syncStatus.finish();
      }
    }
  }

  Future<List<DiscussionInfo>> _saveDiscussionCollectionPage({
    required String collectionKey,
    required List<DiscussionInfo> remote,
    required int offset,
    required int limit,
    required String? nextUrl,
    required int ttlSeconds,
  }) async {
    final syncTime = DateTime.now();
    final localWindow = await collectionDao.getWindow(
      collectionKey: collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: offset,
      limit: limit,
    );
    final localFingerprints = {
      for (final item in localWindow) item.resourceId: item.fingerprint,
    };
    final changed = <DiscussionInfo>[];
    final collectionItems = <DbCacheCollectionItemsCompanion>[];
    final discussionRows = <DbDiscussionsCompanion>[];
    final userRows = <DbUsersCompanion>[];

    for (var index = 0; index < remote.length; index += 1) {
      final discussion = remote[index];
      final fingerprint = _discussionFingerprint(discussion);
      if (localFingerprints[discussion.id] != fingerprint) {
        changed.add(discussion);
      }
      discussionRows.add(
        _discussionCompanion(
          discussion,
          syncTime: syncTime,
          fingerprint: fingerprint,
        ),
      );
      final user = discussion.user;
      if (user != null && user.id > 0) {
        userRows.add(user.toDbUser());
      }
      collectionItems.add(
        DbCacheCollectionItemsCompanion.insert(
          collectionKey: collectionKey,
          resourceType: CacheResourceType.discussion,
          resourceId: discussion.id,
          sortIndex: offset + index,
          fingerprint: fingerprint,
          seenAt: syncTime,
          syncedAt: syncTime,
        ),
      );
    }

    await Future.wait([
      discussionsDao.upsertAll(discussionRows),
      resourceCacheDao.upsertUsers(userRows),
    ]);
    await collectionDao.replaceWindow(
      collectionKey: collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: offset,
      windowLimit: limit,
      items: collectionItems,
      keepLimit: 600,
    );
    await collectionDao.setSyncState(
      collectionKey: collectionKey,
      nextUrl: nextUrl,
      lastSyncAt: syncTime,
      lastSuccessAt: syncTime,
      ttlSeconds: ttlSeconds,
    );
    return changed;
  }

  Future<List<DiscussionInfo>> _saveDiscussionCollectionIndexPage({
    required String collectionKey,
    required List<DiscussionInfo> remote,
    required int offset,
    required int limit,
    required String? nextUrl,
    required int ttlSeconds,
    bool reportStatus = false,
  }) async {
    final syncTime = DateTime.now();
    final localWindow = await collectionDao.getWindow(
      collectionKey: collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: offset,
      limit: limit,
    );
    final localFingerprints = {
      for (final item in localWindow) item.resourceId: item.fingerprint,
    };
    final changedIds = <String>[];
    final collectionItems = <DbCacheCollectionItemsCompanion>[];
    final missingAuthorIds = await discussionsDao.findIdsWithMissingAuthor(
      remote.map((discussion) => discussion.id),
    );

    for (var index = 0; index < remote.length; index += 1) {
      final discussion = remote[index];
      final fingerprint = _discussionFingerprint(discussion);
      if (localFingerprints[discussion.id] != fingerprint ||
          missingAuthorIds.contains(discussion.id)) {
        changedIds.add(discussion.id);
      }
      collectionItems.add(
        DbCacheCollectionItemsCompanion.insert(
          collectionKey: collectionKey,
          resourceType: CacheResourceType.discussion,
          resourceId: discussion.id,
          sortIndex: offset + index,
          fingerprint: fingerprint,
          seenAt: syncTime,
          syncedAt: syncTime,
        ),
      );
    }

    final changed = <DiscussionInfo>[];
    if (changedIds.isNotEmpty) {
      if (reportStatus) {
        syncStatus.start(SyncPhase.hydrating, '正在补全变更主题');
      }
      const chunkSize = 4;
      for (var i = 0; i < changedIds.length; i += chunkSize) {
        final chunk = changedIds.skip(i).take(chunkSize);
        final results = await Future.wait(
          chunk.map((id) => discussionApi.getById(id)),
        );
        for (final discussion in results.whereType<DiscussionInfo>()) {
          changed.add(discussion);
        }
      }
      if (reportStatus) {
        syncStatus.start(SyncPhase.writing, '正在写入本地缓存');
      }
      await Future.wait([
        discussionsDao.upsertAll(
          changed
              .map(
                (discussion) => _discussionCompanion(
                  discussion,
                  syncTime: syncTime,
                  fingerprint: _discussionFingerprint(discussion),
                ),
              )
              .toList(growable: false),
        ),
        resourceCacheDao.upsertUsers(
          changed
              .map((discussion) => discussion.user)
              .whereType<UserInfo>()
              .where((user) => user.id > 0)
              .map((user) => user.toDbUser())
              .toList(growable: false),
        ),
      ]);
    }

    await collectionDao.replaceWindow(
      collectionKey: collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: offset,
      windowLimit: limit,
      items: collectionItems,
      keepLimit: 600,
    );
    await collectionDao.setSyncState(
      collectionKey: collectionKey,
      nextUrl: nextUrl,
      lastSyncAt: syncTime,
      lastSuccessAt: syncTime,
      ttlSeconds: ttlSeconds,
    );
    return changed;
  }

  Future<void> _attachCachedFirstPosts(List<DiscussionInfo> discussions) async {
    if (!SettingsUtil.showDiscussionExcerpt || discussions.isEmpty) return;
    final cached = await firstPostsDao.getByDiscussionIds(
      discussions.map((discussion) => discussion.id).toList(growable: false),
    );
    for (final discussion in discussions) {
      final row = cached[discussion.id];
      if (row == null || discussion.firstPost != null) continue;
      discussion.firstPost = PostInfo(
        discussion.firstPostId,
        row.updatedAt.toIso8601String(),
        row.content,
        row.updatedAt.toIso8601String(),
        discussion.user?.id ?? -1,
        -1,
        int.tryParse(discussion.id) ?? -1,
        row.likeCount,
      );
      discussion.firstPost?.user = discussion.user;
    }
  }

  /// TIPS: for create discussion handler to insert the post manually in to local db.
  Future<void> manuallyInsert(DiscussionInfo d) async {
    final fingerprint = _discussionFingerprint(d);
    await discussionsDao.upsert(
      _discussionCompanion(
        d,
        syncTime: DateTime.now(),
        fingerprint: fingerprint,
      ),
    );
    await collectionDao.prependItem(
      collectionKey: DiscussionCollectionKey.feed(),
      resourceType: CacheResourceType.discussion,
      resourceId: d.id,
      fingerprint: fingerprint,
    );

    if (!SettingsUtil.showDiscussionExcerpt) return;

    var excerpt = htmlToPlainText(d.firstPost?.contentHtml ?? "");
    if (excerpt.length > 80) {
      excerpt = excerpt.substring(0, 80);
    }

    await excerptDao.upsert(
      discussionId: d.id,
      excerpt: excerpt,
      sourceUpdatedAt: DateTime.now(),
    );
  }

  Future<void> cleanupDeletedDiscussions() async {
    final threshold = DateTime.now().subtract(const Duration(days: 10));
    final deleted = await discussionsDao.deleteNotSeenSince(threshold);
    LogUtil.info('[DiscussionRepo] Deleted $deleted discussions');
  }

  Future<void> _saveFirstPostsAndExcerpts(
    List<DiscussionInfo> discussions,
  ) async {
    final tasks = <_ExcerptTask>[];
    final missingFirstPostIds = <int>{};
    final discussionIdByPostId = <int, String>{};
    final firstPostRows = <DbFirstPostsCompanion>[];
    final cacheThreshold = DateTime.now().subtract(const Duration(days: 7));
    final discussionsWithoutPost = <DiscussionInfo>[];

    for (final discussion in discussions) {
      final post = discussion.firstPost;
      if (post != null && _hasExcerptContent(post.contentHtml)) {
        tasks.add(
          _excerptTaskFromPost(discussionId: discussion.id, post: post),
        );
        final updatedAt =
            DateTime.tryParse(
              post.editedAt.isNotEmpty ? post.editedAt : post.createdAt,
            ) ??
            DateTime.now();
        firstPostRows.add(
          DbFirstPostsCompanion(
            discussionId: Value(discussion.id),
            content: Value(post.contentHtml),
            updatedAt: Value(updatedAt),
            likeCount: Value(post.likes),
          ),
        );
        continue;
      }
      discussionsWithoutPost.add(discussion);
    }

    final cachedPosts = await firstPostsDao.getByDiscussionIds(
      discussionsWithoutPost
          .map((discussion) => discussion.id)
          .toList(growable: false),
    );
    for (final discussion in discussionsWithoutPost) {
      final cached = cachedPosts[discussion.id];
      final remoteFirstPost = discussion.firstPost;
      final remoteUpdatedAt = remoteFirstPost == null
          ? null
          : DateTime.tryParse(
              remoteFirstPost.editedAt.isNotEmpty
                  ? remoteFirstPost.editedAt
                  : remoteFirstPost.createdAt,
            );
      final cacheMatchesRemote =
          cached != null &&
          (remoteUpdatedAt == null ||
              !cached.updatedAt.isBefore(remoteUpdatedAt));
      if (cached != null &&
          _hasExcerptContent(cached.content) &&
          !cached.updatedAt.isBefore(cacheThreshold) &&
          cacheMatchesRemote) {
        tasks.add(
          _ExcerptTask(
            discussionId: discussion.id,
            contentHtml: cached.content,
            sourceUpdatedAtIso: cached.updatedAt.toIso8601String(),
          ),
        );
      } else if (discussion.firstPostId >= 0) {
        missingFirstPostIds.add(discussion.firstPostId);
        discussionIdByPostId[discussion.firstPostId] = discussion.id;
      }
    }

    if (missingFirstPostIds.isNotEmpty) {
      final posts = await postRepo.getPostsById(missingFirstPostIds.toList());
      final postData = posts.data;
      if (postData != null) {
        for (final post in postData.posts.values) {
          final discussionId = discussionIdByPostId[post.id];
          if (discussionId == null) continue;
          if (!_hasExcerptContent(post.contentHtml)) continue;
          tasks.add(
            _excerptTaskFromPost(discussionId: discussionId, post: post),
          );
          final updatedAt =
              DateTime.tryParse(
                post.editedAt.isNotEmpty ? post.editedAt : post.createdAt,
              ) ??
              DateTime.now();
          firstPostRows.add(
            DbFirstPostsCompanion(
              discussionId: Value(discussionId),
              content: Value(post.contentHtml),
              updatedAt: Value(updatedAt),
              likeCount: Value(post.likes),
            ),
          );
        }
      }
    }

    await firstPostsDao.upsertAll(firstPostRows);
    if (tasks.isEmpty) return;

    final results = <_ExcerptResult>[];
    const chunkSize = 24;
    for (var i = 0; i < tasks.length; i += chunkSize) {
      results.addAll(
        await compute(
          _buildExcerptResults,
          tasks.skip(i).take(chunkSize).toList(growable: false),
        ),
      );
    }
    final generatedAt = DateTime.now();
    await excerptDao.upsertAll(
      results
          .map(
            (item) => DbDiscussionExcerptCacheCompanion(
              discussionId: Value(item.discussionId),
              excerpt: Value(item.excerpt),
              sourceUpdatedAt: Value(DateTime.parse(item.sourceUpdatedAtIso)),
              generatedAt: Value(generatedAt),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<List<DiscussionInfo>> _excerptTargets(
    List<DiscussionInfo> pageItems,
    List<DiscussionInfo> changed,
  ) async {
    if (!SettingsUtil.showDiscussionExcerpt || pageItems.isEmpty) {
      return const <DiscussionInfo>[];
    }
    final missingIds = await excerptDao.findMissingOrInvalid(
      pageItems.map((discussion) => discussion.id),
    );
    if (changed.isEmpty && missingIds.isEmpty) {
      return const <DiscussionInfo>[];
    }
    final byId = <String, DiscussionInfo>{
      for (final item in pageItems) item.id: item,
      for (final item in changed) item.id: item,
    };
    return [
      for (final id in {
        ...changed.map((discussion) => discussion.id),
        ...missingIds,
      })
        if (byId[id] != null) byId[id]!,
    ];
  }

  bool _hasExcerptContent(String html) {
    return _isValidExcerpt(htmlToPlainText(html));
  }

  Future<void> clearAll() async {
    await discussionsDao.clearAll();
    await firstPostsDao.clearAll();
    await excerptDao.clearAll();
    await collectionDao.clearAll();
    await resourceCacheDao.clearAll();
  }

  Future<void> updateSubscriptionIfExists({
    required String discussionId,
    required int subscription,
  }) async {
    await discussionsDao.updateSubscriptionIfExists(discussionId, subscription);
  }
}

String _discussionFingerprint(DiscussionInfo discussion) {
  final lastPostedAt = discussion.lastPostedAt.toUtc().toIso8601String();
  final firstPost = discussion.firstPost;
  final firstPostStamp = firstPost == null
      ? ''
      : [
          firstPost.editedAt,
          firstPost.createdAt,
          firstPost.likes,
          firstPost.isLiked,
        ].join(':');
  return [
    discussion.id,
    discussion.title,
    lastPostedAt,
    discussion.lastPostNumber,
    discussion.commentCount,
    discussion.views,
    discussion.subscription,
    discussion.firstPostId,
    firstPostStamp,
  ].join('|');
}

DbDiscussionsCompanion _discussionCompanion(
  DiscussionInfo discussion, {
  required DateTime syncTime,
  required String fingerprint,
}) {
  final firstPost = discussion.firstPost;
  return DbDiscussionsCompanion.insert(
    id: discussion.id,
    title: discussion.title,
    slug: "",
    commentCount: discussion.commentCount,
    participantCount: discussion.participantCount,
    viewCount: Value(discussion.views),
    authorName: Value(discussion.user?.displayName ?? ''),
    authorAvatar: Value(discussion.user?.avatarUrl ?? ''),
    createdAt: discussion.createdAt,
    lastPostedAt: Value(discussion.lastPostedAt),
    lastPostNumber: discussion.lastPostNumber,
    firstPostId: Value(discussion.firstPostId),
    likeCount: Value(firstPost?.likes ?? -1),
    posterId: discussion.user?.id ?? -1,
    lastSeenAt: syncTime,
    syncedAt: Value(syncTime),
    deletedAt: const Value(null),
    subscription: discussion.subscription,
    fingerprint: Value(fingerprint),
  );
}

extension on UserInfo {
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
