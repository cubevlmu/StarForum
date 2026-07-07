// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_collection_dao.dart';

// ignore_for_file: type=lint
mixin _$CacheCollectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbCacheCollectionItemsTable get dbCacheCollectionItems =>
      attachedDatabase.dbCacheCollectionItems;
  $DbSyncStatesTable get dbSyncStates => attachedDatabase.dbSyncStates;
  CacheCollectionDaoManager get managers => CacheCollectionDaoManager(this);
}

class CacheCollectionDaoManager {
  final _$CacheCollectionDaoMixin _db;
  CacheCollectionDaoManager(this._db);
  $$DbCacheCollectionItemsTableTableManager get dbCacheCollectionItems =>
      $$DbCacheCollectionItemsTableTableManager(
        _db.attachedDatabase,
        _db.dbCacheCollectionItems,
      );
  $$DbSyncStatesTableTableManager get dbSyncStates =>
      $$DbSyncStatesTableTableManager(_db.attachedDatabase, _db.dbSyncStates);
}
