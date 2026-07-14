/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:star_forum/data/db/perf_query_interceptor.dart';
import 'package:star_forum/data/perf/perf_log.dart';
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
  static const String fileName = 'forum.db';

  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 10;

  Future<File> exportSnapshot(File destination) async {
    await destination.parent.create(recursive: true);
    if (await destination.exists()) await destination.delete();
    await customStatement('VACUUM INTO ?', [destination.path]);
    return destination;
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createPerformanceIndexes();
    },
    onUpgrade: (m, from, to) async {
      await transaction(() async {
        if (from < 7) {
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
        }
        if (from < 8) {
          await _migrateIdentityColumns(m);
        }
        if (from < 9) {
          await _createPerformanceIndexes();
        }
        if (from < 10) {
          await _ensureColumn(
            'db_discussions',
            'is_sticky',
            'INTEGER NOT NULL DEFAULT 0',
          );
        }
      });
    },
  );

  Future<void> _migrateIdentityColumns(Migrator migrator) async {
    await customStatement(
      'ALTER TABLE db_discussions RENAME TO db_discussions_v7',
    );
    await migrator.createTable(dbDiscussions);
    await customStatement('''
      INSERT INTO db_discussions (
        id,
        title,
        slug,
        comment_count,
        participant_count,
        view_count,
        like_count,
        author_name,
        author_avatar,
        author_resolved,
        created_at,
        last_posted_at,
        last_seen_at,
        synced_at,
        deleted_at,
        last_post_number,
        first_post_id,
        poster_id,
        subscription,
        fingerprint
      )
      SELECT
        id,
        title,
        slug,
        comment_count,
        participant_count,
        view_count,
        like_count,
        author_name,
        author_avatar,
        CASE WHEN poster_id > 0 THEN 1 ELSE 0 END,
        created_at,
        last_posted_at,
        last_seen_at,
        synced_at,
        deleted_at,
        last_post_number,
        first_post_id,
        CASE WHEN poster_id > 0 THEN poster_id ELSE NULL END,
        subscription,
        fingerprint
      FROM db_discussions_v7
    ''');
    await customStatement('DROP TABLE db_discussions_v7');

    await customStatement('ALTER TABLE db_posts RENAME TO db_posts_v7');
    await migrator.createTable(dbPosts);
    await customStatement('''
      INSERT INTO db_posts (
        id,
        discussion_id,
        number,
        user_id,
        content_type,
        content_html,
        created_at,
        edited_at,
        likes_count,
        is_liked,
        fingerprint,
        raw_json,
        synced_at,
        deleted_at
      )
      SELECT
        id,
        discussion_id,
        number,
        CASE WHEN user_id > 0 THEN user_id ELSE NULL END,
        content_type,
        content_html,
        created_at,
        edited_at,
        likes_count,
        is_liked,
        fingerprint,
        raw_json,
        synced_at,
        deleted_at
      FROM db_posts_v7
    ''');
    await customStatement('DROP TABLE db_posts_v7');
  }

  Future<void> _createPerformanceIndexes() async {
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_cache_collection_window
      ON db_cache_collection_items (
        collection_key,
        resource_type,
        sort_index
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_posts_discussion_number
      ON db_posts (discussion_id, number)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_notifications_active_created
      ON db_notifications (deleted_at, created_at DESC)
    ''');
  }

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
    final file = File(p.join(dir.path, AppDatabase.fileName));
    LogUtil.info("[Database] Sqlite file start at ${file.path}");
    PerfLog.gauge(
      'storage.sqlite.bytes',
      file.existsSync() ? file.lengthSync() : 0,
    );
    return NativeDatabase.createInBackground(
      file,
    ).interceptWith(PerfQueryInterceptor(file));
  });
}
