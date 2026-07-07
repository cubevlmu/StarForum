// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussions_dao.dart';

// ignore_for_file: type=lint
mixin _$DiscussionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbDiscussionsTable get dbDiscussions => attachedDatabase.dbDiscussions;
  $DbCacheCollectionItemsTable get dbCacheCollectionItems =>
      attachedDatabase.dbCacheCollectionItems;
  $DbDiscussionExcerptCacheTable get dbDiscussionExcerptCache =>
      attachedDatabase.dbDiscussionExcerptCache;
  DiscussionsDaoManager get managers => DiscussionsDaoManager(this);
}

class DiscussionsDaoManager {
  final _$DiscussionsDaoMixin _db;
  DiscussionsDaoManager(this._db);
  $$DbDiscussionsTableTableManager get dbDiscussions =>
      $$DbDiscussionsTableTableManager(_db.attachedDatabase, _db.dbDiscussions);
  $$DbCacheCollectionItemsTableTableManager get dbCacheCollectionItems =>
      $$DbCacheCollectionItemsTableTableManager(
        _db.attachedDatabase,
        _db.dbCacheCollectionItems,
      );
  $$DbDiscussionExcerptCacheTableTableManager get dbDiscussionExcerptCache =>
      $$DbDiscussionExcerptCacheTableTableManager(
        _db.attachedDatabase,
        _db.dbDiscussionExcerptCache,
      );
}
