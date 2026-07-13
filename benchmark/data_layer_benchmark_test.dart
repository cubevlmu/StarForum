import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/api/services/api_parsing.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/perf/perf_config.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/utils/html_utils.dart';

const int _rowCount = int.fromEnvironment('BENCH_ROWS', defaultValue: 5000);
const int _iterations = int.fromEnvironment(
  'BENCH_ITERATIONS',
  defaultValue: 200,
);
const int _warmupIterations = 12;
const int _pageSize = 50;
const String _storage = String.fromEnvironment(
  'BENCH_STORAGE',
  defaultValue: 'memory',
);

void main() {
  test('data layer benchmark', () async {
    PerfConfig.configure(enabled: false);
    addTearDown(PerfConfig.reset);
    final tempDirectory = _storage == 'file'
        ? await Directory.systemTemp.createTemp('star_forum_benchmark_')
        : null;
    final executor = tempDirectory == null
        ? NativeDatabase.memory()
        : NativeDatabase.createInBackground(
            File('${tempDirectory.path}${Platform.pathSeparator}forum.db'),
          );
    final database = AppDatabase.forTesting(executor);
    addTearDown(() async {
      await database.close();
      if (tempDirectory != null && await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    _writeEvent('BENCH_CONFIG', {
      'storage': _storage,
      'rows': _rowCount,
      'posts': _rowCount * 3,
      'iterations': _iterations,
      'dartVersion': Platform.version,
      'operatingSystem': Platform.operatingSystemVersion,
    });

    await _seed(database);
    await _printQueryPlans(database);
    await _benchmarkReads(database);
    await _benchmarkWrites(database);
    await _benchmarkApiParsing();
    await _benchmarkHtmlParsing();
    await _checkRequestCoalescing();
  }, timeout: const Timeout(Duration(minutes: 10)));
}

Future<void> _seed(AppDatabase database) async {
  final now = DateTime.utc(2026, 1, 1);
  final users = <DbUsersCompanion>[];
  final discussions = <DbDiscussionsCompanion>[];
  final excerpts = <DbDiscussionExcerptCacheCompanion>[];
  final collectionItems = <DbCacheCollectionItemsCompanion>[];
  final posts = <DbPostsCompanion>[];

  for (var index = 0; index < _rowCount; index += 1) {
    final id = index + 1;
    users.add(_user(id, now: now));
    discussions.add(
      DbDiscussionsCompanion.insert(
        id: id.toString(),
        title: 'Benchmark discussion $id',
        slug: 'benchmark-discussion-$id',
        commentCount: id % 120,
        participantCount: id % 30,
        viewCount: Value(id * 3),
        likeCount: Value(id % 80),
        authorName: Value('User $id'),
        authorAvatar: Value('https://example.invalid/avatar/$id.png'),
        authorResolved: const Value(true),
        createdAt: now.add(Duration(minutes: id)),
        lastPostedAt: Value(now.add(Duration(minutes: id + 10))),
        lastSeenAt: now,
        syncedAt: Value(now),
        lastPostNumber: id % 120,
        firstPostId: Value(id * 3 - 2),
        posterId: Value(id),
        subscription: 0,
        fingerprint: Value('discussion-$id-v1'),
      ),
    );
    excerpts.add(
      DbDiscussionExcerptCacheCompanion.insert(
        discussionId: id.toString(),
        excerpt: 'Excerpt for benchmark discussion $id',
        sourceUpdatedAt: now,
        generatedAt: now,
      ),
    );
    collectionItems.add(
      DbCacheCollectionItemsCompanion.insert(
        collectionKey: _collectionKey,
        resourceType: CacheResourceType.discussion,
        resourceId: id.toString(),
        sortIndex: index,
        fingerprint: 'discussion-$id-v1',
        seenAt: now,
        syncedAt: now,
      ),
    );
    for (var postIndex = 0; postIndex < 3; postIndex += 1) {
      final postId = index * 3 + postIndex + 1;
      posts.add(
        DbPostsCompanion.insert(
          id: Value(postId),
          discussionId: id,
          number: Value(postIndex + 1),
          userId: Value(id),
          contentHtml: Value(
            '<p>Benchmark post $postId for discussion $id</p>',
          ),
          createdAt: Value(now.add(Duration(minutes: postId))),
          fingerprint: Value('post-$postId-v1'),
          syncedAt: now,
        ),
      );
    }
  }

  final watch = Stopwatch()..start();
  await database.transaction(() async {
    await _insertChunks(
      users,
      (chunk) =>
          database.batch((batch) => batch.insertAll(database.dbUsers, chunk)),
    );
    await _insertChunks(
      discussions,
      (chunk) => database.batch(
        (batch) => batch.insertAll(database.dbDiscussions, chunk),
      ),
    );
    await _insertChunks(
      excerpts,
      (chunk) => database.batch(
        (batch) => batch.insertAll(database.dbDiscussionExcerptCache, chunk),
      ),
    );
    await _insertChunks(
      collectionItems,
      (chunk) => database.batch(
        (batch) => batch.insertAll(database.dbCacheCollectionItems, chunk),
      ),
    );
    await _insertChunks(
      posts,
      (chunk) =>
          database.batch((batch) => batch.insertAll(database.dbPosts, chunk)),
    );
  });
  watch.stop();
  _writeEvent('BENCH_SEED', {
    'elapsedMs': watch.elapsedMilliseconds,
    'rssMb': _rssMb(),
  });
}

Future<void> _benchmarkReads(AppDatabase database) async {
  final maxOffset = max(1, _rowCount - _pageSize);

  await _measure(
    'collection_window_50',
    iterations: _iterations,
    operation: (iteration) => database.cacheCollectionDao.getWindow(
      collectionKey: _collectionKey,
      resourceType: CacheResourceType.discussion,
      offset: (iteration * 37) % maxOffset,
      limit: _pageSize,
    ),
  );

  await _measure(
    'discussion_join_page_50',
    iterations: _iterations,
    operation: (iteration) => database.discussionsDao.getCachedCollection(
      collectionKey: _collectionKey,
      offset: (iteration * 37) % maxOffset,
      limit: _pageSize,
    ),
  );

  await _measure(
    'users_by_ids_100',
    iterations: _iterations,
    operation: (iteration) {
      final start = (iteration * 43) % max(1, _rowCount - 100).toInt();
      return database.resourceCacheDao.getUsersByIds([
        for (var index = 0; index < 100; index += 1) start + index + 1,
      ]);
    },
  );

  await _measure(
    'posts_by_ids_100',
    iterations: _iterations,
    operation: (iteration) {
      final postCount = _rowCount * 3;
      final start = (iteration * 71) % max(1, postCount - 100).toInt();
      return database.resourceCacheDao.getPostsByIds([
        for (var index = 0; index < 100; index += 1) start + index + 1,
      ]);
    },
  );
}

Future<void> _benchmarkWrites(AppDatabase database) async {
  final now = DateTime.utc(2026, 1, 1);
  final unchangedUsers = [
    for (var id = 1; id <= min(100, _rowCount); id += 1) _user(id, now: now),
  ];

  await _measure(
    'users_upsert_unchanged_100',
    iterations: max(20, _iterations ~/ 4),
    operation: (_) => database.resourceCacheDao.upsertUsers(unchangedUsers),
  );

  await _measure(
    'users_upsert_changed_100',
    iterations: max(20, _iterations ~/ 4),
    operation: (iteration) => database.resourceCacheDao.upsertUsers([
      for (var id = 1; id <= min(100, _rowCount); id += 1)
        _user(id, now: now, revision: iteration + 2),
    ]),
  );

  await _measure(
    'replace_collection_window_50',
    iterations: max(20, _iterations ~/ 4),
    operation: (iteration) {
      final syncedAt = now.add(Duration(seconds: iteration));
      return database.cacheCollectionDao.replaceWindowAndMarkSynced(
        collectionKey: _collectionKey,
        resourceType: CacheResourceType.discussion,
        offset: 0,
        windowLimit: _pageSize,
        items: [
          for (var index = 0; index < _pageSize; index += 1)
            DbCacheCollectionItemsCompanion.insert(
              collectionKey: _collectionKey,
              resourceType: CacheResourceType.discussion,
              resourceId: (index + 1).toString(),
              sortIndex: index,
              fingerprint: 'discussion-${index + 1}-v$iteration',
              seenAt: syncedAt,
              syncedAt: syncedAt,
            ),
        ],
        keepLimit: 600,
        nextUrl: '/api/discussions?page[offset]=50',
        syncedAt: syncedAt,
        ttlSeconds: 30,
      );
    },
  );
}

Future<void> _benchmarkApiParsing() async {
  final fixture = _discussionFixture(50);
  final encoded = jsonEncode(fixture);
  final smokeResult = parseDiscussions(fixture);
  expect(smokeResult, hasLength(50));
  expect(smokeResult.first.user?.id, 1);
  expect(smokeResult.first.firstPost?.id, 1);

  await _measure(
    'json_decode_discussions_50',
    iterations: _iterations,
    operation: (_) async {
      final decoded = jsonDecode(encoded) as Map<String, Object?>;
      if ((decoded['data'] as List<Object?>).length != 50) {
        throw StateError('Unexpected decoded discussion count.');
      }
    },
  );

  await _measure(
    'json_api_map_discussions_50',
    iterations: _iterations,
    operation: (_) async {
      final parsed = parseDiscussions(fixture);
      if (parsed.length != 50) {
        throw StateError('Unexpected mapped discussion count.');
      }
    },
  );

  await _measure(
    'json_decode_and_map_discussions_50',
    iterations: _iterations,
    operation: (_) async {
      final parsed = parseDiscussions(jsonDecode(encoded));
      if (parsed.length != 50) {
        throw StateError('Unexpected mapped discussion count.');
      }
    },
  );
}

Future<void> _benchmarkHtmlParsing() async {
  final uniqueHtml = [
    for (var index = 0; index < max(1000, _iterations); index += 1)
      '<article><h2>Topic $index</h2><p>${'content ' * 40}$index</p></article>',
  ];
  await _measure(
    'html_to_plain_text_cold',
    iterations: uniqueHtml.length,
    warmups: 0,
    operation: (iteration) async {
      htmlToPlainText(uniqueHtml[iteration]);
    },
  );

  final hotHtml = uniqueHtml.take(100).toList(growable: false);
  for (final html in hotHtml) {
    htmlToPlainText(html);
  }
  await _measure(
    'html_to_plain_text_hot',
    iterations: max(1000, _iterations * 5),
    operation: (iteration) async {
      htmlToPlainText(hotHtml[iteration % hotHtml.length]);
    },
  );
}

Future<void> _checkRequestCoalescing() async {
  final coalescer = RepoRequestCoalescer();
  var calls = 0;
  final results = await Future.wait([
    for (var index = 0; index < 100; index += 1)
      coalescer.run('same-key', () async {
        calls += 1;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 42;
      }),
  ]);
  expect(calls, 1);
  expect(results, everyElement(42));
  _writeEvent('BENCH_CHECK', {
    'name': 'request_coalescer_fan_in_100',
    'underlyingCalls': calls,
  });
}

Future<void> _printQueryPlans(AppDatabase database) async {
  await _printQueryPlan(
    database,
    'collection_window',
    '''
      SELECT *
      FROM db_cache_collection_items
      WHERE collection_key = ? AND resource_type = ?
      ORDER BY sort_index ASC
      LIMIT 50 OFFSET 2500
    ''',
    [
      Variable<String>(_collectionKey),
      Variable<String>(CacheResourceType.discussion),
    ],
  );
  await _printQueryPlan(
    database,
    'discussion_join_page',
    '''
      SELECT d.*
      FROM db_cache_collection_items c
      INNER JOIN db_discussions d ON d.id = c.resource_id
      LEFT JOIN db_users u ON u.id = d.poster_id AND u.deleted_at IS NULL
      WHERE c.collection_key = ?
        AND c.resource_type = ?
        AND d.deleted_at IS NULL
      ORDER BY c.sort_index ASC
      LIMIT 50 OFFSET 2500
    ''',
    [
      Variable<String>(_collectionKey),
      Variable<String>(CacheResourceType.discussion),
    ],
  );
  await _printQueryPlan(
    database,
    'posts_by_discussion',
    '''
      SELECT * FROM db_posts
      WHERE discussion_id = ? AND deleted_at IS NULL
      ORDER BY number ASC
    ''',
    [const Variable<int>(100)],
  );
}

Future<void> _printQueryPlan(
  AppDatabase database,
  String name,
  String sql,
  List<Variable<Object>> variables,
) async {
  final rows = await database
      .customSelect('EXPLAIN QUERY PLAN $sql', variables: variables)
      .get();
  _writeEvent('BENCH_EXPLAIN', {
    'name': name,
    'details': [for (final row in rows) row.data['detail']],
  });
}

Future<void> _measure(
  String name, {
  required int iterations,
  required Future<void> Function(int iteration) operation,
  int warmups = _warmupIterations,
}) async {
  for (var iteration = 0; iteration < warmups; iteration += 1) {
    await operation(iteration % iterations);
  }

  final samples = <int>[];
  final rssBefore = ProcessInfo.currentRss;
  final total = Stopwatch()..start();
  for (var iteration = 0; iteration < iterations; iteration += 1) {
    final watch = Stopwatch()..start();
    await operation(iteration);
    watch.stop();
    samples.add(watch.elapsedMicroseconds);
  }
  total.stop();
  samples.sort();
  final totalUs = total.elapsedMicroseconds;
  final rssDelta = ProcessInfo.currentRss - rssBefore;
  _writeEvent('BENCH_RESULT', {
    'name': name,
    'iterations': iterations,
    'totalMs': totalUs / 1000,
    'meanUs': totalUs / iterations,
    'p50Us': _percentile(samples, 0.50),
    'p95Us': _percentile(samples, 0.95),
    'opsPerSecond': iterations * Duration.microsecondsPerSecond / totalUs,
    'rssDeltaKb': rssDelta / 1024,
  });
}

DbUsersCompanion _user(int id, {required DateTime now, int revision = 1}) {
  return DbUsersCompanion.insert(
    id: Value(id),
    username: 'user$id',
    displayName: 'User $id v$revision',
    avatarUrl: Value('https://example.invalid/avatar/$id.png'),
    joinedAt: Value(now.subtract(Duration(days: id % 1000))),
    lastSeenAt: Value(now.add(Duration(minutes: id))),
    discussionCount: Value(id % 500),
    commentCount: Value(id % 2000),
    email: Value('user$id@example.invalid'),
    bio: Value('Benchmark user $id'),
    rawJson: Value('{"id":$id,"revision":$revision}'),
    syncedAt: now,
    deletedAt: const Value(null),
  );
}

Map<String, Object?> _discussionFixture(int count) {
  final timestamp = DateTime.utc(2026, 1, 1).toIso8601String();
  return <String, Object?>{
    'data': [
      for (var index = 1; index <= count; index += 1)
        <String, Object?>{
          'type': 'discussions',
          'id': index.toString(),
          'attributes': <String, Object?>{
            'title': 'Benchmark discussion $index',
            'commentCount': index % 100,
            'participantCount': index % 20,
            'viewCount': index * 10,
            'createdAt': timestamp,
            'lastPostedAt': timestamp,
            'lastPostNumber': index % 100,
          },
          'relationships': <String, Object?>{
            'user': _relationship('users', index),
            'lastPostedUser': _relationship('users', index),
            'firstPost': _relationship('posts', index),
            'tags': <String, Object?>{
              'data': [
                <String, Object?>{'type': 'tags', 'id': '${index % 5 + 1}'},
              ],
            },
          },
        },
    ],
    'included': <Map<String, Object?>>[
      for (var index = 1; index <= count; index += 1)
        <String, Object?>{
          'type': 'users',
          'id': index.toString(),
          'attributes': <String, Object?>{
            'username': 'user$index',
            'displayName': 'User $index',
            'avatarUrl': 'https://example.invalid/avatar/$index.png',
            'joinTime': timestamp,
            'lastSeenAt': timestamp,
            'discussionCount': index,
            'commentCount': index * 2,
          },
        },
      for (var index = 1; index <= count; index += 1)
        <String, Object?>{
          'type': 'posts',
          'id': index.toString(),
          'attributes': <String, Object?>{
            'number': 1,
            'createdAt': timestamp,
            'contentType': 'comment',
            'contentHtml': '<p>Benchmark first post $index</p>',
            'likesCount': index % 20,
            'isLiked': false,
          },
          'relationships': <String, Object?>{
            'user': _relationship('users', index),
            'discussion': _relationship('discussions', index),
          },
        },
      for (var index = 1; index <= 5; index += 1)
        <String, Object?>{
          'type': 'tags',
          'id': index.toString(),
          'attributes': <String, Object?>{
            'name': 'Tag $index',
            'slug': 'tag-$index',
            'discussionCount': count,
            'position': index,
          },
        },
    ],
    'links': <String, Object?>{
      'first': '/api/discussions?page[offset]=0',
      'next': '/api/discussions?page[offset]=$count',
    },
  };
}

Map<String, Object?> _relationship(String type, int id) {
  return <String, Object?>{
    'data': <String, Object?>{'type': type, 'id': id.toString()},
  };
}

Future<void> _insertChunks<T>(
  List<T> values,
  Future<void> Function(List<T> chunk) insert,
) async {
  const chunkSize = 500;
  for (var offset = 0; offset < values.length; offset += chunkSize) {
    await insert(
      values.sublist(offset, min(offset + chunkSize, values.length)),
    );
  }
}

int _percentile(List<int> sortedSamples, double percentile) {
  final index = ((sortedSamples.length - 1) * percentile).round();
  return sortedSamples[index];
}

double _rssMb() => ProcessInfo.currentRss / (1024 * 1024);

void _writeEvent(String type, Map<String, Object?> values) {
  stdout.writeln('$type ${jsonEncode(values)}');
}

const String _collectionKey = 'discussion:feed:sort=benchmark:tag=all';
