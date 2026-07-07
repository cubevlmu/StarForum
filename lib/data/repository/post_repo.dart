/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/api/services/post_api.dart' as api;
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/repo_result.dart';

enum PostPageSort { time, number }

class DiscussionPostBundle {
  const DiscussionPostBundle({
    required this.firstPost,
    required this.replies,
    required this.nextUrl,
    required this.hasMore,
  });

  final PostInfo? firstPost;
  final List<PostInfo> replies;
  final String? nextUrl;
  final bool hasMore;
}

class PostRepository {
  PostRepository(
    this.postApi,
    this.resourceCacheDao,
    this.collectionDao,
    this.discussionsDao,
  );

  final api.PostApi postApi;
  final ResourceCacheDao resourceCacheDao;
  final CacheCollectionDao collectionDao;
  final DiscussionsDao discussionsDao;
  final RepoRequestCoalescer _requests = RepoRequestCoalescer();

  Future<RepoResult<PostInfo>> getFirstPost(String discussionId) {
    return _requests.run(
      'firstPost:$discussionId',
      () => RepoResult.guard(() => postApi.getFirstPost(discussionId)),
    );
  }

  Future<RepoResult<Posts>> getPosts({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostPageSort sort = PostPageSort.number,
  }) async {
    return RepoResult.guard(
      () => postApi.getPosts(
        discussionId: discussionId,
        offset: offset,
        limit: limit,
        sort: switch (sort) {
          PostPageSort.time => api.PostSort.time,
          PostPageSort.number => api.PostSort.number,
        },
      ),
    );
  }

  Future<PagedRepoResult<PostInfo>> getPostPage({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostPageSort sort = PostPageSort.number,
    String? nextUrl,
    CancelToken? cancelToken,
  }) async {
    try {
      final page = await postApi.listByDiscussion(
        discussionId: discussionId,
        offset: offset,
        limit: limit,
        sort: switch (sort) {
          PostPageSort.time => api.PostSort.time,
          PostPageSort.number => api.PostSort.number,
        },
        nextUrl: nextUrl,
        cancelToken: cancelToken,
      );
      if (page == null) {
        return const PagedRepoResult.failure(RepoError.empty);
      }
      await _cachePostsWithUsers(page.items);
      return PagedRepoResult.success(
        page.items,
        nextUrl: page.nextUrl,
        hasMoreOverride: page.hasMore || page.items.length >= limit,
      );
    } on FlarumTransportError catch (error) {
      return PagedRepoResult.failure(RepoError.fromTransport(error));
    }
  }

  Future<RepoResult<DiscussionPostBundle>> getInitialPostPage({
    required String discussionId,
    int replyLimit = 10,
    CancelToken? cancelToken,
  }) async {
    try {
      final page = await postApi.listInitialByDiscussion(
        discussionId: discussionId,
        replyLimit: replyLimit,
        cancelToken: cancelToken,
      );
      if (page == null || page.items.isEmpty) {
        final cached = await _cachedInitialPostBundle(discussionId);
        if (cached != null) {
          return RepoResult.success(cached, fromCache: true);
        }
        return const RepoResult.failure(RepoError.empty);
      }
      PostInfo? firstPost;
      for (final post in page.items) {
        if (post.contentType == 'comment') {
          firstPost = post;
          break;
        }
      }
      final replies = <PostInfo>[
        for (final post in page.items)
          if (firstPost == null || post.id != firstPost.id) post,
      ];
      await _cachePostsWithUsers(page.items);
      return RepoResult.success(
        DiscussionPostBundle(
          firstPost: firstPost ?? page.items.first,
          replies: replies,
          nextUrl: page.nextUrl,
          hasMore: page.hasMore || page.items.length >= replyLimit + 1,
        ),
      );
    } on FlarumTransportError catch (error) {
      final cached = await _cachedInitialPostBundle(discussionId);
      if (cached != null) {
        return RepoResult.success(cached, fromCache: true);
      }
      return RepoResult.failure(RepoError.fromTransport(error));
    }
  }

  Future<DiscussionPostBundle?> _cachedInitialPostBundle(
    String discussionId,
  ) async {
    final discussionIdInt = int.tryParse(discussionId);
    if (discussionIdInt == null) return null;
    final discussions = await discussionsDao.getByIds([discussionIdInt]);
    final discussion = discussions[discussionIdInt];
    final firstPostId = discussion?.firstPostId ?? -1;
    if (firstPostId < 0) return null;
    final rows = await resourceCacheDao.getPostsByIds([firstPostId]);
    final row = rows[firstPostId];
    if (row == null || row.deletedAt != null || row.contentHtml.isEmpty) {
      return null;
    }
    final firstPost = row.toPostInfo();
    await _attachCachedUsers([firstPost]);
    return DiscussionPostBundle(
      firstPost: firstPost,
      replies: const <PostInfo>[],
      nextUrl: null,
      hasMore: true,
    );
  }

  Future<RepoResult<Posts>> getPostsById(List<int> ids) async {
    final uniqueIds = ids.toSet().toList(growable: false);
    final cached = await resourceCacheDao.getPostsByIds(uniqueIds);
    final cacheThreshold = DateTime.now().subtract(const Duration(days: 30));
    final cachedPosts = <int, PostInfo>{};
    final missing = <int>[];

    for (final id in uniqueIds) {
      final row = cached[id];
      if (row != null &&
          row.deletedAt == null &&
          row.contentHtml.isNotEmpty &&
          !row.syncedAt.isBefore(cacheThreshold)) {
        cachedPosts[id] = row.toPostInfo();
      } else {
        missing.add(id);
      }
    }

    if (missing.isEmpty) {
      await _attachCachedUsers(cachedPosts.values);
      return RepoResult.success(Posts(cachedPosts, const {}, const {}));
    }

    final result = await RepoResult.guard(() => postApi.getPostsById(missing));
    final data = result.data;
    if (data == null) return result;

    await resourceCacheDao.upsertUsers(
      data.users.values.map((user) => user.toDbUser()).toList(growable: false),
    );
    await _cachePostsWithUsers(data.posts.values);
    cachedPosts.addAll(data.posts);
    return RepoResult.success(Posts(cachedPosts, data.users, data.discussions));
  }

  Future<RepoResult<Posts>> getPostsByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final data = await postApi.getPostsByAuthor(
        username: username,
        offset: offset,
        limit: limit,
        cancelToken: cancelToken,
      );
      if (data == null) {
        return const RepoResult.failure(RepoError.empty);
      }
      await _savePostAuthorCollection(
        username: username,
        posts: data.posts.values.toList(growable: false),
        users: data.users,
        discussions: data.discussions,
        offset: offset,
        limit: limit,
      );
      return RepoResult.success(data);
    } on FlarumTransportError catch (error) {
      final cached = await getCachedPostsByAuthor(
        username: username,
        offset: offset,
        limit: limit,
      );
      if (cached.posts.isNotEmpty) {
        return RepoResult.success(cached, fromCache: true);
      }
      return RepoResult.failure(RepoError.fromTransport(error));
    }
  }

  Future<RepoResult<PostInfo>> createPost(
    String discussionId,
    String content,
  ) async {
    final result = await RepoResult.guard(
      () => postApi.createPost(discussionId, content),
    );
    final post = result.data;
    if (post != null) {
      await _cachePostsWithUsers([post]);
    }
    return result;
  }

  Future<RepoResult<PostInfo>> likePost(String id, bool isLiked) async {
    final result = await RepoResult.guard(() => postApi.likePost(id, isLiked));
    final post = result.data;
    if (post != null) {
      await _cachePostsWithUsers([post]);
    }
    return result;
  }

  Future<Posts> getCachedPostsByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
  }) async {
    final window = await collectionDao.getWindow(
      collectionKey: PostCollectionKey.byAuthor(username),
      resourceType: CacheResourceType.post,
      offset: offset,
      limit: limit,
    );
    final ids = window
        .map((item) => int.tryParse(item.resourceId))
        .whereType<int>()
        .toList(growable: false);
    final rows = await resourceCacheDao.getPostsByIds(ids);
    final posts = <int, PostInfo>{};
    final discussionIds = <int>{};
    for (final id in ids) {
      final row = rows[id];
      if (row == null || row.deletedAt != null) continue;
      final post = row.toPostInfo();
      posts[id] = post;
      if (post.discussion >= 0) discussionIds.add(post.discussion);
    }
    await _attachCachedUsers(posts.values);
    final discussions = await discussionsDao.getByIds(discussionIds.toList());
    return Posts(posts, const {}, discussions);
  }

  Future<void> _savePostAuthorCollection({
    required String username,
    required List<PostInfo> posts,
    required Map<int, UserInfo> users,
    required Map<int, DiscussionInfo> discussions,
    required int offset,
    required int limit,
  }) async {
    final now = DateTime.now();
    await resourceCacheDao.upsertUsers(
      users.values.map((user) => user.toDbUser()).toList(growable: false),
    );
    await resourceCacheDao.upsertPosts(
      posts.map((post) => post.toDbPost()).toList(growable: false),
    );
    await discussionsDao.upsertAll(
      discussions.values
          .map(
            (discussion) => discussion.toDbDiscussion(
              syncTime: now,
              fingerprint: discussion.fingerprint,
            ),
          )
          .toList(growable: false),
    );
    await collectionDao.replaceWindow(
      collectionKey: PostCollectionKey.byAuthor(username),
      resourceType: CacheResourceType.post,
      offset: offset,
      windowLimit: limit,
      items: [
        for (var index = 0; index < posts.length; index += 1)
          DbCacheCollectionItemsCompanion.insert(
            collectionKey: PostCollectionKey.byAuthor(username),
            resourceType: CacheResourceType.post,
            resourceId: posts[index].id.toString(),
            sortIndex: offset + index,
            fingerprint: posts[index].fingerprint,
            seenAt: now,
            syncedAt: now,
          ),
      ],
      keepLimit: 500,
    );
    await collectionDao.setSyncState(
      collectionKey: PostCollectionKey.byAuthor(username),
      lastSyncAt: now,
      lastSuccessAt: now,
      ttlSeconds: 120,
    );
  }

  Future<void> _cachePostsWithUsers(Iterable<PostInfo> posts) async {
    final list = posts.toList(growable: false);
    await resourceCacheDao.upsertUsers(
      list
          .map((post) => post.user)
          .whereType<UserInfo>()
          .where(_hasCacheableUserIdentity)
          .map((user) => user.toDbUser())
          .toList(growable: false),
    );
    await resourceCacheDao.upsertPosts(
      list.map((post) => post.toDbPost()).toList(growable: false),
    );
  }

  Future<void> _attachCachedUsers(Iterable<PostInfo> posts) async {
    final list = posts.toList(growable: false);
    final ids = list
        .map((post) => post.userId)
        .where((id) => id > 0)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return;
    final rows = await resourceCacheDao.getUsersByIds(ids);
    for (final post in list) {
      final row = rows[post.userId];
      if (row != null && row.deletedAt == null) {
        post.user = row.toUserInfo();
      } else if (post.user == null && post.userId > 0) {
        post.user = UserInfo.placeholder(post.userId);
      }
    }
  }

  bool _hasCacheableUserIdentity(UserInfo user) {
    return user.id > 0 &&
        (user.username.trim().isNotEmpty ||
            user.displayName.trim().isNotEmpty ||
            user.avatarUrl.trim().isNotEmpty);
  }
}

extension on DbUser {
  UserInfo toUserInfo() {
    return UserInfo(
      id,
      username,
      displayName,
      avatarUrl,
      joinedAt ?? DateTime.utc(1980),
      discussionCount,
      commentCount,
      lastSeenAt ?? DateTime.utc(1980),
      email,
      null,
      bio,
      avatarSrcset: avatarSrcset,
    );
  }
}

extension on DbPost {
  PostInfo toPostInfo() {
    return PostInfo(
      id,
      createdAt?.toIso8601String() ?? '',
      contentHtml,
      editedAt?.toIso8601String() ?? '',
      userId,
      -1,
      discussionId,
      likesCount,
      number: number,
      contentType: contentType,
      isLiked: isLiked,
    );
  }
}

extension on PostInfo {
  String get fingerprint {
    return [
      id,
      editedAt,
      createdAt,
      likes,
      isLiked,
      contentHtml.length,
    ].join('|');
  }

  DbPostsCompanion toDbPost() {
    final created = DateTime.tryParse(createdAt);
    final edited = DateTime.tryParse(editedAt);
    final fingerprint = [
      id,
      editedAt,
      createdAt,
      likes,
      isLiked,
      contentHtml.length,
    ].join('|');
    return DbPostsCompanion.insert(
      id: Value(id),
      discussionId: discussion,
      number: Value(number),
      userId: Value(userId),
      contentType: Value(contentType),
      contentHtml: Value(contentHtml),
      createdAt: Value(created),
      editedAt: Value(edited),
      likesCount: Value(likes),
      isLiked: Value(isLiked),
      fingerprint: Value(fingerprint),
      syncedAt: DateTime.now(),
      deletedAt: const Value(null),
    );
  }
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

extension on DiscussionInfo {
  String get fingerprint {
    return [
      id,
      title,
      lastPostedAt.toUtc().toIso8601String(),
      lastPostNumber,
      commentCount,
      views,
      subscription,
      firstPostId,
    ].join('|');
  }

  DbDiscussionsCompanion toDbDiscussion({
    required DateTime syncTime,
    required String fingerprint,
  }) {
    return DbDiscussionsCompanion.insert(
      id: id,
      title: title,
      slug: '',
      commentCount: commentCount,
      participantCount: participantCount,
      viewCount: Value(views),
      authorName: Value(user?.displayName ?? ''),
      authorAvatar: Value(user?.avatarUrl ?? ''),
      createdAt: createdAt,
      lastPostedAt: Value(lastPostedAt),
      lastPostNumber: lastPostNumber,
      firstPostId: Value(firstPostId),
      likeCount: Value(firstPost?.likes ?? -1),
      posterId: user?.id ?? -1,
      lastSeenAt: syncTime,
      syncedAt: Value(syncTime),
      deletedAt: const Value(null),
      subscription: subscription,
      fingerprint: Value(fingerprint),
    );
  }
}
