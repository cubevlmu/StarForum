/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:star_forum/data/db/tables/discussion_table.dart';
import 'package:star_forum/data/db/tables/first_table.dart';
import 'package:star_forum/data/db/tables/cache_collection_table.dart';
import 'package:star_forum/data/db/tables/resource_tables.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/discussion_excerpt_cache.dart';

import 'dao/discussions_dao.dart';
import 'dao/first_posts_dao.dart';
import 'dao/excerpt_dao.dart';
import 'dao/cache_collection_dao.dart';
import 'dao/resource_cache_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    DbDiscussions,
    DbFirstPosts,
    DbDiscussionExcerptCache,
    DbCacheCollectionItems,
    DbSyncStates,
    DbUsers,
    DbPosts,
    DbTags,
    DbDiscussionTags,
    DbNotifications,
  ],
  daos: [
    DiscussionsDao,
    FirstPostsDao,
    ExcerptDao,
    CacheCollectionDao,
    ResourceCacheDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      await transaction(() async {
        await customStatement('''
          CREATE TABLE IF NOT EXISTS db_first_posts (
            discussion_id TEXT NOT NULL PRIMARY KEY,
            content TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            like_count INTEGER NOT NULL
          )
        ''');
        await customStatement('''
          CREATE TABLE IF NOT EXISTS db_discussion_excerpt_cache (
            discussion_id TEXT NOT NULL PRIMARY KEY,
            excerpt TEXT NOT NULL,
            source_updated_at INTEGER NOT NULL,
            generated_at INTEGER NOT NULL
          )
        ''');
        await m.createTable(dbDiscussions);
        await _ensureColumn('db_discussions', 'synced_at', 'INTEGER');
        await _ensureColumn('db_discussions', 'deleted_at', 'INTEGER');
        await _ensureColumn(
          'db_discussions',
          'first_post_id',
          'INTEGER NOT NULL DEFAULT -1',
        );
        await _ensureColumn(
          'db_discussions',
          'fingerprint',
          "TEXT NOT NULL DEFAULT ''",
        );
        await m.createTable(dbCacheCollectionItems);
        await m.createTable(dbSyncStates);
        await m.createTable(dbUsers);
        await m.createTable(dbPosts);
        await m.createTable(dbTags);
        await m.createTable(dbDiscussionTags);
        await m.createTable(dbNotifications);
      });
    },
  );

  Future<void> _ensureColumn(
    String table,
    String column,
    String definition,
  ) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    final exists = rows.any((row) => row.read<String>('name') == column);
    if (!exists) {
      await customStatement(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'forum.db'));
    LogUtil.info("[Database] Sqlite file start at ${file.path}");
    return NativeDatabase.createInBackground(file);
  });
}
