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
import 'package:star_forum/data/db/tables/resource_tables.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/db/mappers/discussion_cache_mapper.dart';
import 'package:star_forum/data/db/mappers/tag_cache_mapper.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/utils/log_util.dart';

part 'discussions_dao.g.dart';

@DriftAccessor(
  tables: [
    DbDiscussions,
    DbCacheCollectionItems,
    DbDiscussionExcerptCache,
    DbUsers,
  ],
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

  Stream<List<DiscussionSummary>> watchPaged(
    int limit, {
    String collectionKey = 'discussion:feed:sort=default:tag=all',
    bool showExcerpt = true,
    bool keepStickyOnTop = true,
  }) {
    return customSelect(
      '''
      SELECT d.id,
             d.title,
             COALESCE(e.excerpt, '') AS excerpt,
             COALESCE(
               NULLIF(u.display_name, ''),
               NULLIF(u.username, ''),
               d.author_name
             ) AS author_name,
             COALESCE(NULLIF(u.avatar_url, ''), d.author_avatar) AS author_avatar,
             d.view_count,
             d.last_posted_at,
             d.created_at,
             d.comment_count,
             d.like_count,
             d.poster_id,
             d.subscription,
             d.is_sticky
      FROM db_discussions d
      LEFT JOIN db_cache_collection_items c
        ON d.id = c.resource_id
       AND c.collection_key = ?
       AND c.resource_type = ?
      LEFT JOIN db_discussion_excerpt_cache e
        ON e.discussion_id = d.id
      LEFT JOIN db_users u
        ON u.id = d.poster_id AND u.deleted_at IS NULL
      WHERE d.deleted_at IS NULL
        AND (
          c.resource_id IS NOT NULL
          OR (? = 1 AND d.is_sticky = 1)
        )
      ORDER BY
        CASE WHEN ? = 1 THEN d.is_sticky ELSE 0 END DESC,
        COALESCE(c.sort_index, 2147483647) ASC,
        d.last_posted_at DESC
      LIMIT ?
      ''',
      variables: [
        Variable<String>(collectionKey),
        Variable<String>(CacheResourceType.discussion),
        Variable<int>(keepStickyOnTop ? 1 : 0),
        Variable<int>(keepStickyOnTop ? 1 : 0),
        Variable<int>(limit),
      ],
      readsFrom: {
        dbCacheCollectionItems,
        dbDiscussions,
        dbDiscussionExcerptCache,
        dbUsers,
        attachedDatabase.dbDiscussionTags,
        attachedDatabase.dbTags,
      },
    ).watch().asyncMap((rows) async {
      final tagsByDiscussion = await _tagsByDiscussionIds(
        rows.map((row) => row.read<String>('id')).toList(growable: false),
      );
      return [
        for (final row in rows)
          _discussionItemFromRow(
            row,
            showExcerpt: showExcerpt,
            tags: tagsByDiscussion[row.read<String>('id')] ?? const [],
          ),
      ];
    });
  }

  Future<Map<String, List<TagInfo>>> _tagsByDiscussionIds(
    List<String> discussionIds,
  ) async {
    if (discussionIds.isEmpty) return const {};
    final relations = attachedDatabase.dbDiscussionTags;
    final tags = attachedDatabase.dbTags;
    final query = attachedDatabase.select(relations).join([
      innerJoin(tags, tags.id.equalsExp(relations.tagId)),
    ]);
    query
      ..where(
        relations.discussionId.isIn(discussionIds) & tags.deletedAt.isNull(),
      )
      ..orderBy([
        OrderingTerm.asc(relations.discussionId),
        OrderingTerm.asc(relations.sortIndex),
      ]);
    final result = <String, List<TagInfo>>{};
    for (final row in await query.get()) {
      final discussionId = row.readTable(relations).discussionId;
      (result[discussionId] ??= []).add(row.readTable(tags).toTagInfo());
    }
    return result;
  }

  Future<void> upsertAll(List<DbDiscussionsCompanion> list) {
    return batch((b) => b.insertAllOnConflictUpdate(dbDiscussions, list));
  }

  Future<Map<int, DiscussionDetail>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const <int, DiscussionDetail>{};
    final rows = await (select(
      dbDiscussions,
    )..where((t) => t.id.isIn(ids.map((id) => id.toString())))).get();
    return {
      for (final row in rows)
        int.tryParse(row.id) ?? -1: row.toDiscussionDetail(),
    }..remove(-1);
  }

  Future<Set<String>> findIdsWithMissingAuthor(Iterable<String> ids) async {
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return const <String>{};
    final rows = await (select(
      dbDiscussions,
    )..where((t) => t.id.isIn(idList))).get();
    final userIds = rows
        .map((row) => row.posterId)
        .whereType<int>()
        .where((id) => id > 0)
        .toSet()
        .toList(growable: false);
    final userRows = userIds.isEmpty
        ? const <DbUser>[]
        : await (select(dbUsers)..where((t) => t.id.isIn(userIds))).get();
    final users = {for (final user in userRows) user.id: user};
    return {
      for (final row in rows)
        if (!row.authorResolved || _isMissingUser(row.posterId, users)) row.id,
    };
  }

  Future<List<DiscussionDetail>> getCachedCollection({
    required String collectionKey,
    required int offset,
    required int limit,
  }) async {
    final rows = await customSelect(
      '''
      SELECT d.*,
             COALESCE(
               NULLIF(u.display_name, ''),
               NULLIF(u.username, ''),
               d.author_name
             ) AS resolved_author_name,
             COALESCE(
               NULLIF(u.avatar_url, ''),
               d.author_avatar
             ) AS resolved_author_avatar
      FROM db_cache_collection_items c
      INNER JOIN db_discussions d
        ON d.id = c.resource_id
      LEFT JOIN db_users u
        ON u.id = d.poster_id AND u.deleted_at IS NULL
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
      readsFrom: {dbCacheCollectionItems, dbDiscussions, dbUsers},
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
          authorName: row.read<String>('resolved_author_name'),
          authorAvatar: row.read<String>('resolved_author_avatar'),
          authorResolved: row.read<bool>('author_resolved'),
          createdAt: row.read<DateTime>('created_at'),
          lastPostedAt: row.readNullable<DateTime>('last_posted_at'),
          lastSeenAt: row.read<DateTime>('last_seen_at'),
          syncedAt: row.readNullable<DateTime>('synced_at'),
          deletedAt: row.readNullable<DateTime>('deleted_at'),
          lastPostNumber: row.read<int>('last_post_number'),
          firstPostId: row.read<int>('first_post_id'),
          posterId: row.readNullable<int>('poster_id'),
          subscription: row.read<int>('subscription'),
          isSticky: row.read<bool>('is_sticky'),
          fingerprint: row.read<String>('fingerprint'),
        ).toDiscussionDetail(),
    ];
  }

  Future<int> deleteNotSeenSince(DateTime threshold) {
    return (delete(dbDiscussions)..where(
          (t) =>
              t.lastSeenAt.isSmallerThanValue(threshold) &
              t.isSticky.equals(false),
        ))
        .go();
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

DiscussionSummary _discussionItemFromRow(
  QueryRow row, {
  required bool showExcerpt,
  required List<TagInfo> tags,
}) {
  final posterId = row.readNullable<int>('poster_id');
  final authorName = row.read<String>('author_name').trim();
  return DiscussionSummary(
    id: row.read<String>('id'),
    title: row.read<String>('title'),
    excerpt: showExcerpt ? row.read<String>('excerpt') : '',
    authorName: authorName.isNotEmpty
        ? authorName
        : posterId != null && posterId > 0
        ? '#$posterId'
        : '',
    authorAvatar: row.read<String>('author_avatar'),
    viewCount: row.read<int>('view_count'),
    lastPostedAt:
        row.readNullable<DateTime>('last_posted_at') ??
        row.read<DateTime>('created_at'),
    createdAt: row.read<DateTime>('created_at'),
    commentCount: row.read<int>('comment_count'),
    likeCount: row.read<int>('like_count'),
    userId: posterId ?? -1,
    subscription: row.read<int>('subscription'),
    isSticky: row.read<bool>('is_sticky'),
    tags: tags,
  );
}

bool _hasUsableIdentity(DbUser? user) {
  return user != null &&
      (user.username.trim().isNotEmpty ||
          user.displayName.trim().isNotEmpty ||
          user.avatarUrl.trim().isNotEmpty);
}

bool _isMissingUser(int? userId, Map<int, DbUser> users) {
  return userId != null && userId > 0 && !_hasUsableIdentity(users[userId]);
}
