/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/dao/first_posts_dao.dart';
import 'package:star_forum/data/db/dao/discussions_dao.dart';
import 'package:star_forum/data/db/dao/excerpt_dao.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:rxdart/rxdart.dart';

class DiscussionRepository {
  final DiscussionsDao discussionsDao;
  final FirstPostsDao firstPostsDao;
  final ExcerptDao excerptDao;

  DiscussionRepository(
    this.discussionsDao,
    this.firstPostsDao,
    this.excerptDao,
  );

  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime get lastSyncTime => _lastSyncTime;
  void beginSync(DateTime t) {
    _lastSyncTime = t;
  }

  Stream<List<DiscussionItem>> watchDiscussionItems({required int limit}) {
    return Rx.combineLatest2<
      List<DbDiscussion>,
      List<DbDiscussionExcerptCacheData>,
      List<DiscussionItem>
    >(discussionsDao.watchPaged(limit), excerptDao.watchAll(), (
      discussions,
      excerpts,
    ) {
      final excerptMap = {for (final e in excerpts) e.discussionId: e.excerpt};

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
          userId: d.posterId,
        );
      }).toList();
    });
  }

  Future<int> getDiscussionCount() {
    return discussionsDao.countAll();
  }

  /// TIPS: Imitate RSS client caching logic to solve the problem of server delete post.
  Future<bool> syncDiscussionPage({
    required int offset,
    required int limit,
    String sortKey = '',
    String? tagSlug,
  }) async {
    final before = await discussionsDao.countAll();

    final paged = await Api.getDiscussionList(
      sortKey,
      tagSlug: tagSlug,
      offset: offset,
      limit: limit,
    );

    if (paged == null) return false;

    final remote = paged.data.list;
    if (remote.isEmpty) return false;

    final syncTime = DateTime.now();

    await discussionsDao.upsertAll(
      remote.map((d) {
        return DbDiscussionsCompanion.insert(
          id: d.id,
          title: d.title,
          slug: "",
          commentCount: d.commentCount,
          participantCount: 0,
          viewCount: Value(d.views),
          authorName: Value(d.user?.displayName ?? ''),
          authorAvatar: Value(d.user?.avatarUrl ?? ''),
          createdAt: d.createdAt,
          lastPostedAt: Value(d.lastPostedAt),
          lastPostNumber: d.lastPostNumber,
          likeCount: Value(d.firstPost?.likes ?? -1),
          posterId: d.user?.id ?? -1,

          lastSeenAt: syncTime,
        );
      }).toList(),
    );

    if (offset == 0) {
      final minPostedAt = remote
          .map(
            (d) => d.lastPostedAt != DateTime.utc(1980)
                ? d.lastPostedAt
                : d.createdAt,
          )
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final deleted = await discussionsDao.deleteStaleInWindow(
        syncTime: syncTime,
        minPostedAt: minPostedAt,
      );

      LogUtil.info(
        '[DiscussionRepo] Discussion prune deleted $deleted stale discussions',
      );
    }

    for (final d in remote) {
      if (d.firstPost != null) {
        await _saveFirstPostAndExcerpt(d.id, d.firstPost!);
      }
    }

    final after = await discussionsDao.countAll();

    return after > before;
  }

  /// TIPS: for create discussion handler to insert the post manually in to local db.
  Future<void> manuallyInsert(DiscussionInfo d) async {
    await discussionsDao.upsert(
      DbDiscussionsCompanion.insert(
        id: d.id,
        title: d.title,
        slug: "",
        commentCount: 0,
        participantCount: 0,
        viewCount: Value(d.views),
        authorName: Value(d.user?.displayName ?? ''),
        authorAvatar: Value(d.user?.avatarUrl ?? ''),
        createdAt: d.createdAt,
        lastPostedAt: Value(d.lastPostedAt),
        lastPostNumber: d.lastPostNumber,
        likeCount: Value(-1),
        posterId: d.user?.id ?? -1,

        lastSeenAt: DateTime.now(),
      ),
    );

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

  Future<void> _saveFirstPostAndExcerpt(
    String discussionId,
    PostInfo post,
  ) async {
    final editedAt = post.editedAt.isNotEmpty
        ? DateTime.parse(post.editedAt)
        : DateTime.parse(post.createdAt);

    // await firstPostsDao.upsert(
    //   discussionId,
    //   post.contentHtml,
    //   editedAt,
    //   post.likes,
    // );

    var excerpt = htmlToPlainText(post.contentHtml);
    if (excerpt.length > 80) {
      excerpt = excerpt.substring(0, 80);
    }

    await excerptDao.upsert(
      discussionId: discussionId,
      excerpt: excerpt,
      sourceUpdatedAt: editedAt,
    );
  }

  Future<void> clearAll() async {
    await discussionsDao.clearAll();
    await excerptDao.clearAll();
  }
}
