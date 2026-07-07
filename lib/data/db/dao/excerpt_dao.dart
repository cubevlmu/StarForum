/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/tables/discussion_excerpt_cache.dart';
import 'package:star_forum/utils/log_util.dart';

part 'excerpt_dao.g.dart';

@DriftAccessor(tables: [DbDiscussionExcerptCache])
class ExcerptDao extends DatabaseAccessor<AppDatabase> with _$ExcerptDaoMixin {
  ExcerptDao(super.db);

  Stream<List<DbDiscussionExcerptCacheData>> watchAll() {
    return select(dbDiscussionExcerptCache).watch();
  }

  Stream<List<DbDiscussionExcerptCacheData>> watchByDiscussionIds(
    List<String> discussionIds,
  ) {
    if (discussionIds.isEmpty) {
      return Stream.value(const <DbDiscussionExcerptCacheData>[]);
    }
    return (select(
      dbDiscussionExcerptCache,
    )..where((t) => t.discussionId.isIn(discussionIds))).watch();
  }

  Future<DbDiscussionExcerptCacheData?> get(String discussionId) => (select(
    dbDiscussionExcerptCache,
  )..where((t) => t.discussionId.equals(discussionId))).getSingleOrNull();

  Future<Set<String>> findMissingOrInvalid(Iterable<String> ids) async {
    final idList = ids.toSet().toList(growable: false);
    if (idList.isEmpty) return const <String>{};
    final rows = await (select(
      dbDiscussionExcerptCache,
    )..where((t) => t.discussionId.isIn(idList))).get();
    final found = {for (final row in rows) row.discussionId};
    final invalid = {
      for (final row in rows)
        if (_isInvalidExcerpt(row.excerpt)) row.discussionId,
    };
    return {
      for (final id in idList)
        if (!found.contains(id)) id,
      ...invalid,
    };
  }

  Future<void> upsert({
    required String discussionId,
    required String excerpt,
    required DateTime sourceUpdatedAt,
  }) => into(dbDiscussionExcerptCache).insertOnConflictUpdate(
    DbDiscussionExcerptCacheCompanion(
      discussionId: Value(discussionId),
      excerpt: Value(excerpt),
      sourceUpdatedAt: Value(sourceUpdatedAt),
      generatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> upsertAll(List<DbDiscussionExcerptCacheCompanion> items) async {
    if (items.isEmpty) return;

    await batch((batch) {
      batch.insertAll(
        dbDiscussionExcerptCache,
        items,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> clearAll() async {
    final r = await delete(dbDiscussionExcerptCache).go();
    LogUtil.debug("[Db] Excerpts delete $r rows");
  }
}

bool _isInvalidExcerpt(String value) {
  final normalized = value.trim();
  return normalized.isEmpty || normalized == '...';
}
