/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/db/app_database.dart';
import 'package:forum/data/db/dao/first_posts_dao.dart';
import 'package:forum/data/db/dao/discussions_dao.dart';
import 'package:forum/data/db/dao/excerpt_dao.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/utils/html_utils.dart';
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

  // ===================== DB → UI =====================

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

  // ===================== 网络分页 =====================

  // Future<bool> syncDiscussionPage({
  //   required int offset,
  //   required int limit,
  //   String sortKey = '',
  //   String? tagSlug,
  // }) async {
  //   final paged = await Api.getDiscussionList(
  //     sortKey,
  //     tagSlug: tagSlug,
  //     offset: offset,
  //     limit: limit,
  //   );

  //   if (paged == null) return false;

  //   final remote = paged.data.list;
  //   if (remote.isEmpty) return false;

  //   await discussionsDao.upsertAll(
  //     remote.map((d) {
  //       return DbDiscussionsCompanion.insert(
  //         id: d.id,
  //         title: d.title,
  //         slug: d.slug,
  //         commentCount: d.commentCount,
  //         participantCount: d.participantCount,
  //         viewCount: Value(d.views),
  //         authorName: Value(d.user?.displayName ?? ''),
  //         authorAvatar: Value(d.user?.avatarUrl ?? ''),
  //         createdAt: DateTime.parse(d.createdAt),
  //         lastPostedAt: Value(
  //           d.lastPostedAt.isEmpty ? null : DateTime.parse(d.lastPostedAt),
  //         ),
  //         lastPostNumber: d.lastPostNumber,
  //         likeCount: Value(d.firstPost?.likes ?? 0),
  //         posterId: d.user?.id ?? -1,
  //       );
  //     }).toList(),
  //   );

  //   // 处理首帖 & 摘要
  //   for (final d in remote) {
  //     if (d.firstPost == null) continue;
  //     await _saveFirstPostAndExcerpt(d.id, d.firstPost!);
  //   }

  //   return paged.nextUrl != null;
  // }

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

    await discussionsDao.upsertAll(
      remote.map((d) {
        return DbDiscussionsCompanion.insert(
          id: d.id,
          title: d.title,
          slug: d.slug,
          commentCount: d.commentCount,
          participantCount: d.participantCount,
          viewCount: Value(d.views),
          authorName: Value(d.user?.displayName ?? ''),
          authorAvatar: Value(d.user?.avatarUrl ?? ''),
          createdAt: DateTime.parse(d.createdAt),
          lastPostedAt: Value(
            d.lastPostedAt.isEmpty ? null : DateTime.parse(d.lastPostedAt),
          ),
          lastPostNumber: d.lastPostNumber,
          likeCount: Value(d.firstPost?.likes ?? 0),
          posterId: d.user?.id ?? -1,
        );
      }).toList(),
    );

    for (final d in remote) {
      if (d.firstPost != null) {
        await _saveFirstPostAndExcerpt(d.id, d.firstPost!);
      }
    }

    final after = await discussionsDao.countAll();

    /// 🔥 是否真的新增了数据
    return after > before;
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
    if (excerpt.length > 80) {
      excerpt = excerpt.substring(0, 80);
    }

    await excerptDao.upsert(
      discussionId: discussionId,
      excerpt: excerpt,
      sourceUpdatedAt: editedAt,
    );
  }
}
