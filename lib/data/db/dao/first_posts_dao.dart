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
  ) =>
      into(dbFirstPosts).insertOnConflictUpdate(
        DbFirstPostsCompanion(
          discussionId: Value(discussionId),
          content: Value(content),
          updatedAt: Value(updatedAt),
          likeCount: Value(likeCount),
        ),
      );

  Future<DbFirstPost?> get(String discussionId) =>
      (select(dbFirstPosts)
            ..where((t) => t.discussionId.equals(discussionId)))
          .getSingleOrNull();
}
