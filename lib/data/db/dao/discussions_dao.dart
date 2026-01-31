/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';
import 'package:forum/data/db/app_database.dart';
import 'package:forum/data/db/tables/discussion_table.dart';

part 'discussions_dao.g.dart';

// @DriftAccessor(tables: [DbDiscussions])
// class DiscussionsDao extends DatabaseAccessor<AppDatabase>
//     with _$DiscussionsDaoMixin {
//   DiscussionsDao(super.db);

//   Future<void> upsertAll(List<DbDiscussionsCompanion> list) =>
//       batch((b) => b.insertAllOnConflictUpdate(dbDiscussions, list));

//   Stream<List<DbDiscussion>> watchPaged(int limit) {
//     return (select(dbDiscussions)
//           ..orderBy([
//             (t) => OrderingTerm(
//               expression: t.lastPostedAt,
//               mode: OrderingMode.desc,
//             ),
//             (t) =>
//                 OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
//           ])
//           ..limit(limit))
//         .watch();
//   }

//   Stream<List<DbDiscussion>> watchAll() {
//     return (select(dbDiscussions)..orderBy([
//           (t) =>
//               OrderingTerm(expression: t.lastPostedAt, mode: OrderingMode.desc),
//           (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
//         ]))
//         .watch();
//   }

//   Future<DbDiscussion?> getById(String id) =>
//       (select(dbDiscussions)..where((t) => t.id.equals(id))).getSingleOrNull();
// }

@DriftAccessor(tables: [DbDiscussions])
class DiscussionsDao extends DatabaseAccessor<AppDatabase>
    with _$DiscussionsDaoMixin {
  DiscussionsDao(super.db);

  Future<int> countAll() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM db_discussions',
    ).getSingle();
    return row.read<int>('c');
  }

  Future<void> upsertAll(List<DbDiscussionsCompanion> list) {
    return batch((b) => b.insertAllOnConflictUpdate(dbDiscussions, list));
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
}
