// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussions_dao.dart';

// ignore_for_file: type=lint
mixin _$DiscussionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbDiscussionsTable get dbDiscussions => attachedDatabase.dbDiscussions;
  DiscussionsDaoManager get managers => DiscussionsDaoManager(this);
}

class DiscussionsDaoManager {
  final _$DiscussionsDaoMixin _db;
  DiscussionsDaoManager(this._db);
  $$DbDiscussionsTableTableManager get dbDiscussions =>
      $$DbDiscussionsTableTableManager(_db.attachedDatabase, _db.dbDiscussions);
}
