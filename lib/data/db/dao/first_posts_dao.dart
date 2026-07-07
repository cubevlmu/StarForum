/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/tables/first_table.dart';

part 'first_posts_dao.g.dart';

@DriftAccessor(tables: [DbFirstPosts])
class FirstPostsDao extends DatabaseAccessor<AppDatabase>
    with _$FirstPostsDaoMixin {
  FirstPostsDao(super.db);

  Future<void> upsert(
    String discussionId,
    String content,
    DateTime updatedAt,
    int likeCount,
  ) => into(dbFirstPosts).insertOnConflictUpdate(
    DbFirstPostsCompanion(
      discussionId: Value(discussionId),
      content: Value(content),
      updatedAt: Value(updatedAt),
      likeCount: Value(likeCount),
    ),
  );

  Future<DbFirstPost?> get(String discussionId) => (select(
    dbFirstPosts,
  )..where((t) => t.discussionId.equals(discussionId))).getSingleOrNull();

  Future<Map<String, DbFirstPost>> getByDiscussionIds(
    List<String> discussionIds,
  ) async {
    if (discussionIds.isEmpty) return const <String, DbFirstPost>{};
    final rows = await (select(
      dbFirstPosts,
    )..where((t) => t.discussionId.isIn(discussionIds))).get();
    return {for (final row in rows) row.discussionId: row};
  }

  Future<void> upsertAll(List<DbFirstPostsCompanion> items) async {
    if (items.isEmpty) return;
    await batch(
      (batch) => batch.insertAll(
        dbFirstPosts,
        items,
        mode: InsertMode.insertOrReplace,
      ),
    );
  }

  Future<int> deleteOlderThan(DateTime threshold) {
    return (delete(
      dbFirstPosts,
    )..where((t) => t.updatedAt.isSmallerThanValue(threshold))).go();
  }

  Future<void> clearAll() async {
    await delete(dbFirstPosts).go();
  }
}
