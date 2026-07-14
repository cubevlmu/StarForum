import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/cache_keys.dart';
import 'package:star_forum/data/db/mappers/discussion_cache_mapper.dart';
import 'package:star_forum/data/model/discussions.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('persists isSticky into the home feed summary projection', () async {
    final now = DateTime.utc(2026, 7, 14);
    final detail = DiscussionDetail(
      '42',
      'Pinned topic',
      1,
      1,
      8,
      now,
      now,
      1,
      -1,
      null,
      null,
      null,
      const [],
      const {},
      const {},
      const [],
      0,
      isSticky: true,
    );
    await database.discussionsDao.upsert(
      detail.toDbDiscussion(syncTime: now, fingerprint: detail.fingerprint),
    );
    await database
        .into(database.dbCacheCollectionItems)
        .insert(
          DbCacheCollectionItemsCompanion.insert(
            collectionKey: DiscussionCollectionKey.feed(),
            resourceType: CacheResourceType.discussion,
            resourceId: detail.id,
            sortIndex: 0,
            fingerprint: detail.fingerprint,
            seenAt: now,
            syncedAt: now,
          ),
        );

    final summaries = await database.discussionsDao.watchPaged(20).first;

    expect(summaries, hasLength(1));
    expect(summaries.single.isSticky, isTrue);
  });
}
