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

  Future<DbDiscussionExcerptCacheData?> get(String discussionId) => (select(
    dbDiscussionExcerptCache,
  )..where((t) => t.discussionId.equals(discussionId))).getSingleOrNull();

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

  
  Future<void> clearAll() async {
    final r = await delete(dbDiscussionExcerptCache).go();
    LogUtil.debug("[Db] Excerpts delete $r rows");
  }
}
