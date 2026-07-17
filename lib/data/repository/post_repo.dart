/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:dio/dio.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/mappers/user_cache_mapper.dart';
import 'package:star_forum/data/db/mappers/post_cache_mapper.dart';
import 'package:star_forum/data/db/mappers/discussion_cache_mapper.dart';
import 'package:star_forum/data/db/dao/cache_collection_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/api/services/post_api.dart' as api;
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/repo_result.dart';

enum PostPageSort { timeAscending, timeDescending, number }

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
      () => RepoResult.guard(
        () => postApi.getFirstPost(discussionId),
        name: 'post.firstPost',
      ),
    );
  }

  Future<RepoResult<Posts>> getPosts({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostPageSort sort = PostPageSort.number,
  }) {
    return _requests.run(
      'posts:$discussionId:$offset:$limit:${sort.name}',
      () => RepoResult.guard(
        () => postApi.getPosts(
          discussionId: discussionId,
          offset: offset,
          limit: limit,
          sort: switch (sort) {
            PostPageSort.timeAscending => api.PostSort.timeAscending,
            PostPageSort.timeDescending => api.PostSort.timeDescending,
            PostPageSort.number => api.PostSort.number,
          },
        ),
        name: 'post.list',
      ),
    );
  }

  Future<PagedRepoResult<PostInfo>> getPostPage({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostPageSort sort = PostPageSort.number,
    CancelToken? cancelToken,
  }) {
    final pageKey = '$offset:$limit:${sort.name}';
    return _requests.run(
      'postPage:$discussionId:$pageKey',
      () => _getPostPage(
        discussionId: discussionId,
        offset: offset,
        limit: limit,
        sort: sort,
        cancelToken: cancelToken,
      ),
      coalesce: cancelToken == null,
    );
  }

  Future<PagedRepoResult<PostInfo>> _getPostPage({
    required String discussionId,
    required int offset,
    required int limit,
    required PostPageSort sort,
    required CancelToken? cancelToken,
  }) async {
    try {
      final page = await postApi.listByDiscussion(
        discussionId: discussionId,
        offset: offset,
        limit: limit,
        sort: switch (sort) {
          PostPageSort.timeAscending => api.PostSort.timeAscending,
          PostPageSort.timeDescending => api.PostSort.timeDescending,
          PostPageSort.number => api.PostSort.number,
        },
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
  }) {
    return _requests.run(
      'initialPostPage:$discussionId:$replyLimit',
      () => _getInitialPostPage(
        discussionId: discussionId,
        replyLimit: replyLimit,
        cancelToken: cancelToken,
      ),
      coalesce: cancelToken == null,
    );
  }

  Future<RepoResult<DiscussionPostBundle>> _getInitialPostPage({
    required String discussionId,
    required int replyLimit,
    required CancelToken? cancelToken,
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
    final firstPost = (await _withCachedUsers([row.toPostInfo()])).single;
    return DiscussionPostBundle(
      firstPost: firstPost,
      replies: const <PostInfo>[],
      nextUrl: null,
      hasMore: true,
    );
  }

  Future<RepoResult<Posts>> getPostsById(
    List<int> ids, {
    bool forceRemote = false,
  }) {
    final uniqueIds = ids.toSet().toList(growable: false)..sort();
    return _requests.run(
      'postsById:${forceRemote ? 'remote' : 'cached'}:${uniqueIds.join(',')}',
      () => _getPostsById(uniqueIds, forceRemote: forceRemote),
    );
  }

  Future<RepoResult<Posts>> _getPostsById(
    List<int> uniqueIds, {
    required bool forceRemote,
  }) async {
    final cached = forceRemote
        ? const <int, DbPost>{}
        : await resourceCacheDao.getPostsByIds(uniqueIds);
    final cacheThreshold = DateTime.now().subtract(const Duration(days: 30));
    final cachedPosts = <int, PostInfo>{};
    final missing = <int>[];

    for (final id in uniqueIds) {
      final row = cached[id];
      if (!forceRemote &&
          row != null &&
          row.deletedAt == null &&
          row.contentHtml.isNotEmpty &&
          !row.syncedAt.isBefore(cacheThreshold)) {
        cachedPosts[id] = row.toPostInfo();
      } else {
        missing.add(id);
      }
    }

    if (missing.isEmpty) {
      final attached = await _withCachedUsers(cachedPosts.values);
      cachedPosts
        ..clear()
        ..addEntries(attached.map((post) => MapEntry(post.id, post)));
      return RepoResult.success(
        Posts(cachedPosts, const {}, const {}),
        fromCache: true,
      );
    }

    final result = await RepoResult.guard(
      () => postApi.getPostsById(missing),
      name: 'post.byId',
    );
    final data = result.data;
    if (data == null) return result;

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
      name: 'post.create',
    );
    final post = result.data;
    if (post != null) {
      await _cachePostsWithUsers([post]);
    }
    return result;
  }

  Future<RepoResult<PostInfo>> likePost(String id, bool isLiked) async {
    final result = await RepoResult.guard(
      () => postApi.likePost(id, isLiked),
      name: 'post.like',
    );
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
    final attached = await _withCachedUsers(posts.values);
    posts
      ..clear()
      ..addEntries(attached.map((post) => MapEntry(post.id, post)));
    final discussions = await discussionsDao.getByIds(discussionIds.toList());
    return Posts(posts, const {}, discussions);
  }

  Future<void> _savePostAuthorCollection({
    required String username,
    required List<PostInfo> posts,
    required Map<int, UserInfo> users,
    required Map<int, DiscussionDetail> discussions,
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
    await collectionDao.replaceWindowAndMarkSynced(
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
      syncedAt: now,
      ttlSeconds: 120,
    );
  }

  Future<void> _cachePostsWithUsers(Iterable<PostInfo> posts) async {
    final list = posts.toList(growable: false);
    await resourceCacheDao.upsertUsers(
      list
          .map((post) => post.user)
          .whereType<UserInfo>()
          .where((user) => user.hasCacheableIdentity)
          .map((user) => user.toDbUser())
          .toList(growable: false),
    );
    await resourceCacheDao.upsertPosts(
      list.map((post) => post.toDbPost()).toList(growable: false),
    );
  }

  Future<List<PostInfo>> _withCachedUsers(Iterable<PostInfo> posts) async {
    final list = posts.toList(growable: false);
    final ids = list
        .map((post) => post.userId)
        .where((id) => id > 0)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return list;
    final rows = await resourceCacheDao.getUsersByIds(ids);
    return [
      for (final post in list)
        post.copyWith(user: _cachedUserFor(post, rows[post.userId])),
    ];
  }

  UserInfo? _cachedUserFor(PostInfo post, DbUser? row) {
    if (row != null && row.deletedAt == null) {
      return row.toUserInfo();
    }
    return post.user ??
        (post.userId > 0 ? UserInfo.placeholder(post.userId) : null);
  }
}
