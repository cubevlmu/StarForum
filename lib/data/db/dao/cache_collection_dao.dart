import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/tables/cache_collection_table.dart';

part 'cache_collection_dao.g.dart';

@DriftAccessor(tables: [DbCacheCollectionItems, DbSyncStates])
class CacheCollectionDao extends DatabaseAccessor<AppDatabase>
    with _$CacheCollectionDaoMixin {
  CacheCollectionDao(super.db);

  Future<int> count(String collectionKey) async {
    final row = await (customSelect(
      '''
          SELECT COUNT(*) AS c
          FROM db_cache_collection_items
          WHERE collection_key = ?
          ''',
      variables: [Variable<String>(collectionKey)],
      readsFrom: {dbCacheCollectionItems},
    )).getSingle();
    return row.read<int>('c');
  }

  Future<int> countAllItems() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM db_cache_collection_items',
      readsFrom: {dbCacheCollectionItems},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<List<DbCacheCollectionItem>> getWindow({
    required String collectionKey,
    required String resourceType,
    required int offset,
    required int limit,
  }) {
    return (select(dbCacheCollectionItems)
          ..where(
            (t) =>
                t.collectionKey.equals(collectionKey) &
                t.resourceType.equals(resourceType),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<void> replaceWindow({
    required String collectionKey,
    required String resourceType,
    required int offset,
    required int windowLimit,
    required List<DbCacheCollectionItemsCompanion> items,
    int? keepLimit,
  }) async {
    final upper = offset + windowLimit;
    await transaction(() async {
      await (delete(dbCacheCollectionItems)..where(
            (t) =>
                t.collectionKey.equals(collectionKey) &
                t.resourceType.equals(resourceType) &
                t.sortIndex.isBiggerOrEqualValue(offset) &
                t.sortIndex.isSmallerThanValue(upper),
          ))
          .go();
      if (items.isNotEmpty) {
        await batch(
          (batch) =>
              batch.insertAllOnConflictUpdate(dbCacheCollectionItems, items),
        );
      }
      if (keepLimit != null) {
        await pruneCollection(
          collectionKey: collectionKey,
          resourceType: resourceType,
          keepLimit: keepLimit,
        );
      }
    });
  }

  Future<int> pruneCollection({
    required String collectionKey,
    required String resourceType,
    required int keepLimit,
  }) {
    return (delete(dbCacheCollectionItems)..where(
          (t) =>
              t.collectionKey.equals(collectionKey) &
              t.resourceType.equals(resourceType) &
              t.sortIndex.isBiggerOrEqualValue(keepLimit),
        ))
        .go();
  }

  Future<void> prependItem({
    required String collectionKey,
    required String resourceType,
    required String resourceId,
    required String fingerprint,
    int keepLimit = 600,
  }) async {
    final now = DateTime.now();
    await transaction(() async {
      await customUpdate(
        '''
        UPDATE db_cache_collection_items
        SET sort_index = sort_index + 1
        WHERE collection_key = ?
          AND resource_type = ?
        ''',
        variables: [
          Variable<String>(collectionKey),
          Variable<String>(resourceType),
        ],
        updates: {dbCacheCollectionItems},
      );
      await into(dbCacheCollectionItems).insertOnConflictUpdate(
        DbCacheCollectionItemsCompanion.insert(
          collectionKey: collectionKey,
          resourceType: resourceType,
          resourceId: resourceId,
          sortIndex: 0,
          fingerprint: fingerprint,
          seenAt: now,
          syncedAt: now,
        ),
      );
      await pruneCollection(
        collectionKey: collectionKey,
        resourceType: resourceType,
        keepLimit: keepLimit,
      );
    });
  }

  Future<void> setSyncState({
    required String collectionKey,
    String? nextUrl,
    DateTime? lastSyncAt,
    DateTime? lastSuccessAt,
    String? lastError,
    int ttlSeconds = 60,
  }) {
    return into(dbSyncStates).insertOnConflictUpdate(
      DbSyncStatesCompanion(
        collectionKey: Value(collectionKey),
        nextUrl: Value(nextUrl),
        lastSyncAt: Value(lastSyncAt),
        lastSuccessAt: Value(lastSuccessAt),
        lastError: Value(lastError),
        ttlSeconds: Value(ttlSeconds),
      ),
    );
  }

  Future<void> clearAll() async {
    await delete(dbCacheCollectionItems).go();
    await delete(dbSyncStates).go();
  }

  Future<void> clearResourceType(String resourceType) async {
    await (delete(
      dbCacheCollectionItems,
    )..where((t) => t.resourceType.equals(resourceType))).go();
  }
}
