// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_posts_dao.dart';

// ignore_for_file: type=lint
mixin _$FirstPostsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbFirstPostsTable get dbFirstPosts => attachedDatabase.dbFirstPosts;
  FirstPostsDaoManager get managers => FirstPostsDaoManager(this);
}

class FirstPostsDaoManager {
  final _$FirstPostsDaoMixin _db;
  FirstPostsDaoManager(this._db);
  $$DbFirstPostsTableTableManager get dbFirstPosts =>
      $$DbFirstPostsTableTableManager(_db.attachedDatabase, _db.dbFirstPosts);
}
