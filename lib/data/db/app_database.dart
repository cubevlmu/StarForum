/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:forum/data/db/tables/discussion_table.dart';
import 'package:forum/data/db/tables/first_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/discussion_excerpt_cache.dart';

import 'dao/discussions_dao.dart';
import 'dao/first_posts_dao.dart';
import 'dao/excerpt_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [DbDiscussions, DbFirstPosts, DbDiscussionExcerptCache],
  daos: [DiscussionsDao, FirstPostsDao, ExcerptDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 数据库版本号（⚠️ 以后改表一定要 +1）
  @override
  int get schemaVersion => 5;

  /// 迁移策略
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // ⚠️ 开发期：直接删库重建
      // await m.deleteTable();
      await m.createAll();
    },
  );
}

/// SQLite 打开方式
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'forum.db'));
    return NativeDatabase(file);
  });
}
