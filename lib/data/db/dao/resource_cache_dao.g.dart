// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$ResourceCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $DbUsersTable get dbUsers => attachedDatabase.dbUsers;
  $DbPostsTable get dbPosts => attachedDatabase.dbPosts;
  $DbTagsTable get dbTags => attachedDatabase.dbTags;
  $DbDiscussionTagsTable get dbDiscussionTags =>
      attachedDatabase.dbDiscussionTags;
  $DbNotificationsTable get dbNotifications => attachedDatabase.dbNotifications;
  ResourceCacheDaoManager get managers => ResourceCacheDaoManager(this);
}

class ResourceCacheDaoManager {
  final _$ResourceCacheDaoMixin _db;
  ResourceCacheDaoManager(this._db);
  $$DbUsersTableTableManager get dbUsers =>
      $$DbUsersTableTableManager(_db.attachedDatabase, _db.dbUsers);
  $$DbPostsTableTableManager get dbPosts =>
      $$DbPostsTableTableManager(_db.attachedDatabase, _db.dbPosts);
  $$DbTagsTableTableManager get dbTags =>
      $$DbTagsTableTableManager(_db.attachedDatabase, _db.dbTags);
  $$DbDiscussionTagsTableTableManager get dbDiscussionTags =>
      $$DbDiscussionTagsTableTableManager(
        _db.attachedDatabase,
        _db.dbDiscussionTags,
      );
  $$DbNotificationsTableTableManager get dbNotifications =>
      $$DbNotificationsTableTableManager(
        _db.attachedDatabase,
        _db.dbNotifications,
      );
}
