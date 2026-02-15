/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/tables/discussion_table.dart';
import 'package:star_forum/utils/log_util.dart';

part 'discussions_dao.g.dart';

@DriftAccessor(tables: [DbDiscussions])
class DiscussionsDao extends DatabaseAccessor<AppDatabase>
    with _$DiscussionsDaoMixin {
  DiscussionsDao(super.db);

  Future<void> touchAllSeenNow() async {
    final now = DateTime.now();

    await (update(dbDiscussions)..where((t) => t.lastSeenAt.isNotNull())).write(
      DbDiscussionsCompanion(lastSeenAt: Value(now)),
    );
  }

  Future<int> countAll() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM db_discussions',
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

  Stream<List<DbDiscussion>> watchPaged(int limit) {
    return (select(dbDiscussions)
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.lastPostedAt,
              mode: OrderingMode.desc,
            ),
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Future<void> upsertAll(List<DbDiscussionsCompanion> list) {
    return batch((b) => b.insertAllOnConflictUpdate(dbDiscussions, list));
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
}
