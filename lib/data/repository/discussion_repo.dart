/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussions.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/db/app_database.dart';
import 'package:forum/data/db/dao/first_posts_dao.dart';
import 'package:forum/data/db/dao/discussions_dao.dart';
import 'package:forum/data/db/dao/excerpt_dao.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/utils/html_utils.dart';
import 'package:rxdart/rxdart.dart';

// class _FirstPostFetchTask {
//   final String discussionId;
//   final int firstPostId;
//   _FirstPostFetchTask({required this.discussionId, required this.firstPostId});
// }

class _UpdateDetailTask {
  final String discussionId;
  final PostInfo firstPost;

  _UpdateDetailTask({required this.discussionId, required this.firstPost});
}

class DiscussionRepository {
  final DiscussionsDao discussionsDao;
  final FirstPostsDao firstPostsDao;
  final ExcerptDao excerptDao;

  DiscussionRepository(
    this.discussionsDao,
    this.firstPostsDao,
    this.excerptDao,
  );

  Stream<List<DiscussionItem>> watchDiscussionItems() {
    return Rx.combineLatest2<
      List<DbDiscussion>,
      List<DbDiscussionExcerptCacheData>,
      List<DiscussionItem>
    >(discussionsDao.watchAll(), excerptDao.watchAll(), (
      discussions,
      excerpts,
    ) {
      final excerptMap = {for (var e in excerpts) e.discussionId: e.excerpt};

      return discussions.map((d) {
        return DiscussionItem(
          id: d.id,
          title: d.title,
          excerpt: excerptMap[d.id] ?? '…',
          authorName: d.authorName,
          authorAvatar: d.authorAvatar,
          viewCount: d.viewCount,
          lastPostedAt: d.lastPostedAt ?? d.createdAt,
          commentCount: d.commentCount,
          likeCount: d.likeCount,
        );
      }).toList();
    });
  }

  Future<void> syncDiscussionList(
    String sortKey, {
    String? tagSlug,
    int pageSize = 20,
    int maxPage = 50, // 防止极端情况下死循环
  }) async {
    int offset = 0;
    int pageCount = 0;

    while (true) {
      final paged = await Api.getDiscussionList(
        sortKey,
        tagSlug: tagSlug,
        offset: offset,
        limit: pageSize,
      );

      if (paged == null) return;

      final remote = paged.data;
      if (remote.list.isEmpty) return;

      /// 1️⃣ upsert discussions
      await discussionsDao.upsertAll(
        remote.list.map((d) {
          return DbDiscussionsCompanion.insert(
            id: d.id,
            title: d.title,
            slug: d.slug,
            commentCount: d.commentCount,
            participantCount: d.participantCount,
            viewCount: Value(d.views),
            authorName: Value(d.user?.displayName ?? ""),
            authorAvatar: Value(d.user?.avatarUrl ?? ""),
            createdAt: DateTime.parse(d.createdAt),
            lastPostedAt: Value(
              d.lastPostedAt.isEmpty ? null : DateTime.parse(d.lastPostedAt),
            ),
            lastPostNumber: d.lastPostNumber,
            likeCount: Value(d.firstPost?.likes ?? 0),
          );
        }).toList(),
      );

      /// 2️⃣ firstPost / excerpt 增量更新
      final toFetch = await _collectFirstPostToFetch(remote.list);
      for (final item in toFetch) {
        await _saveFirstPostAndExcerpt(item.discussionId, item.firstPost);
      }

      /// 3️⃣ 是否还有下一页
      if (paged.nextUrl == null) {
        return;
      }

      offset += pageSize;
      pageCount++;

      if (pageCount >= maxPage) {
        log('[DiscussionRepo] syncDiscussionList stopped: reach maxPage=$maxPage');
        return;
      }
    }
  }

  Future<List<_UpdateDetailTask>> _collectFirstPostToFetch(
    List<DiscussionInfo> remote,
  ) async {
    final result = <_UpdateDetailTask>[];

    for (final d in remote) {
      if (d.firstPost == null) continue;

      final cache = await excerptDao.get(d.id);
      final discussion = await discussionsDao.getById(d.id);
      if (discussion == null) continue;

      final lastUpdated = discussion.lastPostedAt ?? discussion.createdAt;

      final shouldFetch =
          cache == null || lastUpdated.isAfter(cache.generatedAt);

      if (shouldFetch) {
        result.add(
          // _FirstPostFetchTask(
          //   discussionId: d.id,
          //   firstPostId: d.firstPost!.id,
          // ),
          _UpdateDetailTask(discussionId: d.id, firstPost: d.firstPost!),
        );
      }
    }

    return result;
  }

  Future<void> _saveFirstPostAndExcerpt(
    String discussionId,
    PostInfo post,
  ) async {
    final editedAt = post.editedAt.isNotEmpty
        ? DateTime.parse(post.editedAt)
        : DateTime.parse(post.createdAt);

    await firstPostsDao.upsert(
      discussionId,
      post.contentHtml,
      editedAt,
      post.likes,
    );

    var excerpt = htmlToPlainText(post.contentHtml);
    excerpt = excerpt.substring(0, excerpt.length > 80 ? 80 : excerpt.length);

    await excerptDao.upsert(
      discussionId: discussionId,
      excerpt: excerpt,
      sourceUpdatedAt: editedAt,
    );
  }

  Future<String?> getCachedFirstPostContent(String discussionId) async {
    final row = await firstPostsDao.get(discussionId);
    return row?.content;
  }
}
