// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'excerpt_dao.dart';

// ignore_for_file: type=lint
mixin _$ExcerptDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbDiscussionExcerptCacheTable get dbDiscussionExcerptCache =>
      attachedDatabase.dbDiscussionExcerptCache;
  ExcerptDaoManager get managers => ExcerptDaoManager(this);
}

class ExcerptDaoManager {
  final _$ExcerptDaoMixin _db;
  ExcerptDaoManager(this._db);
  $$DbDiscussionExcerptCacheTableTableManager get dbDiscussionExcerptCache =>
      $$DbDiscussionExcerptCacheTableTableManager(
        _db.attachedDatabase,
        _db.dbDiscussionExcerptCache,
      );
}
