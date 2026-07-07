/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/tables/cache_collection_table.dart';
import 'package:star_forum/data/db/tables/discussion_excerpt_cache.dart';
import 'package:star_forum/data/db/tables/discussion_table.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/utils/log_util.dart';

part 'discussions_dao.g.dart';

@DriftAccessor(
  tables: [DbDiscussions, DbCacheCollectionItems, DbDiscussionExcerptCache],
)
class DiscussionsDao extends DatabaseAccessor<AppDatabase>
    with _$DiscussionsDaoMixin {
  DiscussionsDao(super.db);

  Future<void> touchAllSeenNow() async {
    final now = DateTime.now();

    await (update(dbDiscussions)..where((t) => t.lastSeenAt.isNotNull())).write(
      DbDiscussionsCompanion(lastSeenAt: Value(now)),
    );
  }

  Future<int> countAll({
    String collectionKey = 'discussion:feed:sort=default:tag=all',
  }) async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS c
      FROM db_cache_collection_items
      WHERE collection_key = ?
        AND resource_type = ?
      ''',
      variables: [
        Variable<String>(collectionKey),
        Variable<String>(CacheResourceType.discussion),
      ],
      readsFrom: {dbCacheCollectionItems},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<int> countResources() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM db_discussions',
      readsFrom: {dbDiscussions},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<int> deleteStaleInWindow({
    required DateTime syncTime,
    required DateTime minPostedAt,
  }) {
    return (delete(dbDiscussions)..where(
          (t) =>
              t.lastSeenAt.isSmallerThanValue(syncTime) &
              t.lastPostedAt.isBiggerOrEqualValue(minPostedAt),
        ))
        .go();
  }

  Stream<List<DiscussionItem>> watchPaged(
    int limit, {
    String collectionKey = 'discussion:feed:sort=default:tag=all',
    bool showExcerpt = true,
  }) {
    return customSelect(
      '''
      SELECT d.id,
             d.title,
             COALESCE(e.excerpt, '...') AS excerpt,
             d.author_name,
             d.author_avatar,
             d.view_count,
             d.last_posted_at,
             d.created_at,
             d.comment_count,
             d.like_count,
             d.poster_id,
             d.subscription
      FROM db_cache_collection_items c
      INNER JOIN db_discussions d
        ON d.id = c.resource_id
      LEFT JOIN db_discussion_excerpt_cache e
        ON e.discussion_id = d.id
      WHERE c.collection_key = ?
        AND c.resource_type = ?
        AND d.deleted_at IS NULL
      ORDER BY c.sort_index ASC
      LIMIT ?
      ''',
      variables: [
        Variable<String>(collectionKey),
        Variable<String>(CacheResourceType.discussion),
        Variable<int>(limit),
      ],
      readsFrom: {
        dbCacheCollectionItems,
        dbDiscussions,
        dbDiscussionExcerptCache,
      },
    ).watch().map((rows) {
      return [
        for (final row in rows)
          _discussionItemFromRow(row, showExcerpt: showExcerpt),
      ];
    });
  }

  Future<void> upsertAll(List<DbDiscussionsCompanion> list) {
    return batch((b) => b.insertAllOnConflictUpdate(dbDiscussions, list));
  }

  Future<Map<int, DiscussionInfo>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const <int, DiscussionInfo>{};
    final rows = await (select(
      dbDiscussions,
    )..where((t) => t.id.isIn(ids.map((id) => id.toString())))).get();
    return {
      for (final row in rows)
        int.tryParse(row.id) ?? -1: row.toDiscussionInfo(),
    }..remove(-1);
  }

  Future<Set<String>> findIdsWithMissingAuthor(Iterable<String> ids) async {
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return const <String>{};
    final rows =
        await (select(dbDiscussions)..where(
              (t) =>
                  t.id.isIn(idList) &
                  (t.posterId.isSmallerOrEqualValue(0) |
                      t.authorName.equals('')),
            ))
            .get();
    return rows.map((row) => row.id).toSet();
  }

  Future<List<DiscussionInfo>> getCachedCollection({
    required String collectionKey,
    required int offset,
    required int limit,
  }) async {
    final rows = await customSelect(
      '''
      SELECT d.*
      FROM db_cache_collection_items c
      INNER JOIN db_discussions d
        ON d.id = c.resource_id
      WHERE c.collection_key = ?
        AND c.resource_type = ?
        AND d.deleted_at IS NULL
      ORDER BY c.sort_index ASC
      LIMIT ? OFFSET ?
      ''',
      variables: [
        Variable<String>(collectionKey),
        Variable<String>(CacheResourceType.discussion),
        Variable<int>(limit),
        Variable<int>(offset),
      ],
      readsFrom: {dbCacheCollectionItems, dbDiscussions},
    ).get();
    return [
      for (final row in rows)
        DbDiscussion(
          id: row.read<String>('id'),
          title: row.read<String>('title'),
          slug: row.read<String>('slug'),
          commentCount: row.read<int>('comment_count'),
          participantCount: row.read<int>('participant_count'),
          viewCount: row.read<int>('view_count'),
          likeCount: row.read<int>('like_count'),
          authorName: row.read<String>('author_name'),
          authorAvatar: row.read<String>('author_avatar'),
          createdAt: row.read<DateTime>('created_at'),
          lastPostedAt: row.readNullable<DateTime>('last_posted_at'),
          lastSeenAt: row.read<DateTime>('last_seen_at'),
          syncedAt: row.readNullable<DateTime>('synced_at'),
          deletedAt: row.readNullable<DateTime>('deleted_at'),
          lastPostNumber: row.read<int>('last_post_number'),
          firstPostId: row.read<int>('first_post_id'),
          posterId: row.read<int>('poster_id'),
          subscription: row.read<int>('subscription'),
          fingerprint: row.read<String>('fingerprint'),
        ).toDiscussionInfo(),
    ];
  }

  Future<int> deleteNotSeenSince(DateTime threshold) {
    return (delete(
      dbDiscussions,
    )..where((t) => t.lastSeenAt.isSmallerThanValue(threshold))).go();
  }

  Future<void> upsert(DbDiscussionsCompanion dbDiscussionsCompanion) async {
    return upsertAll([dbDiscussionsCompanion]);
  }

  Future<void> clearAll() async {
    final r = await delete(dbDiscussions).go();
    LogUtil.debug("[Db] Dicussion delete $r rows");
  }

  Future<List<String>> getAllTitle() async {
    final rows = await select(dbDiscussions).get();
    return rows.map((row) => row.title).toList();
  }

  Future<int> deleteItem(String title) {
    return (delete(dbDiscussions)..where((t) => t.title.equals(title))).go();
  }

  Future<int> updateSubscriptionIfExists(
    String discussionId,
    int subscription,
  ) {
    return (update(dbDiscussions)..where((t) => t.id.equals(discussionId)))
        .write(DbDiscussionsCompanion(subscription: Value(subscription)));
  }

  Future<int> markDeleted(String discussionId) {
    return (update(dbDiscussions)..where((t) => t.id.equals(discussionId)))
        .write(DbDiscussionsCompanion(deletedAt: Value(DateTime.now())));
  }
}

DiscussionItem _discussionItemFromRow(
  QueryRow row, {
  required bool showExcerpt,
}) {
  final posterId = row.read<int>('poster_id');
  final authorName = row.read<String>('author_name').trim();
  return DiscussionItem(
    id: row.read<String>('id'),
    title: row.read<String>('title'),
    excerpt: showExcerpt ? row.read<String>('excerpt') : '',
    authorName: authorName.isNotEmpty
        ? authorName
        : posterId > 0
        ? '#$posterId'
        : '',
    authorAvatar: row.read<String>('author_avatar'),
    viewCount: row.read<int>('view_count'),
    lastPostedAt:
        row.readNullable<DateTime>('last_posted_at') ??
        row.read<DateTime>('created_at'),
    commentCount: row.read<int>('comment_count'),
    likeCount: row.read<int>('like_count'),
    userId: posterId,
    subscription: row.read<int>('subscription'),
  );
}

extension on DbDiscussion {
  DiscussionInfo toDiscussionInfo() {
    final author = UserInfo(
      posterId,
      '',
      authorName,
      authorAvatar,
      createdAt,
      0,
      0,
      DateTime.utc(1980),
      '',
      null,
      '',
    );
    return DiscussionInfo(
      id,
      title,
      commentCount,
      participantCount,
      viewCount,
      createdAt,
      lastPostedAt ?? createdAt,
      lastPostNumber,
      firstPostId,
      author,
      null,
      null,
      firstPostId >= 0 ? [firstPostId] : const <int>[],
      {},
      {posterId: author},
      const [],
      subscription,
    );
  }
}
