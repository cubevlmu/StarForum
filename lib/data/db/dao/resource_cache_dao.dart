import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/tables/resource_tables.dart';

part 'resource_cache_dao.g.dart';

@DriftAccessor(
  tables: [DbUsers, DbPosts, DbTags, DbDiscussionTags, DbNotifications],
)
class ResourceCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ResourceCacheDaoMixin {
  ResourceCacheDao(super.db);

  Future<void> upsertUsers(List<DbUsersCompanion> users) async {
    final pendingById = <int, DbUsersCompanion>{};
    for (final user in users) {
      if (!user.id.present || user.id.value <= 0) continue;
      final id = user.id.value;
      final pending = pendingById[id];
      pendingById[id] = pending == null
          ? user
          : _mergePendingUser(pending, user);
    }
    if (pendingById.isEmpty) return;

    final ids = pendingById.keys.toList(growable: false);
    final current = await getUsersByIds(ids);
    final merged = <DbUsersCompanion>[];
    for (final entry in pendingById.entries) {
      final existing = current[entry.key];
      final candidate = _mergeUser(entry.value, existing);
      if (existing == null || !_matchesUser(candidate, existing)) {
        merged.add(candidate);
      }
    }
    if (merged.isEmpty) return;
    await batch((batch) => batch.insertAllOnConflictUpdate(dbUsers, merged));
  }

  DbUsersCompanion _mergePendingUser(
    DbUsersCompanion current,
    DbUsersCompanion incoming,
  ) {
    return DbUsersCompanion(
      id: incoming.id,
      username: _preferText(incoming.username, current.username),
      displayName: _preferText(incoming.displayName, current.displayName),
      avatarUrl: _preferText(incoming.avatarUrl, current.avatarUrl),
      avatarSrcset: _preferText(incoming.avatarSrcset, current.avatarSrcset),
      joinedAt: _preferDate(incoming.joinedAt, current.joinedAt),
      lastSeenAt: _preferDate(incoming.lastSeenAt, current.lastSeenAt),
      discussionCount: _preferCount(
        incoming.discussionCount,
        current.discussionCount,
      ),
      commentCount: _preferCount(incoming.commentCount, current.commentCount),
      email: _preferText(incoming.email, current.email),
      bio: _preferText(incoming.bio, current.bio),
      rawJson: incoming.rawJson.present ? incoming.rawJson : current.rawJson,
      syncedAt: incoming.syncedAt.present
          ? incoming.syncedAt
          : current.syncedAt,
      deletedAt: incoming.deletedAt.present
          ? incoming.deletedAt
          : current.deletedAt,
    );
  }

  DbUsersCompanion _mergeUser(DbUsersCompanion incoming, DbUser? current) {
    if (current == null) return incoming;

    final username = _useText(incoming.username, current.username);
    final displayName = _useText(incoming.displayName, current.displayName);
    final avatarUrl = _useText(incoming.avatarUrl, current.avatarUrl);
    final avatarSrcset = _useText(incoming.avatarSrcset, current.avatarSrcset);
    final email = _useText(incoming.email, current.email);
    final bio = _useText(incoming.bio, current.bio);

    return DbUsersCompanion.insert(
      id: Value(current.id),
      username: username,
      displayName: displayName,
      avatarUrl: Value(avatarUrl),
      avatarSrcset: Value(avatarSrcset),
      joinedAt: Value(_useDate(incoming.joinedAt, current.joinedAt)),
      lastSeenAt: Value(_useDate(incoming.lastSeenAt, current.lastSeenAt)),
      discussionCount: Value(
        _useCount(incoming.discussionCount, current.discussionCount),
      ),
      commentCount: Value(
        _useCount(incoming.commentCount, current.commentCount),
      ),
      email: Value(email),
      bio: Value(bio),
      rawJson: incoming.rawJson.present
          ? incoming.rawJson
          : Value(current.rawJson),
      syncedAt: incoming.syncedAt.present
          ? incoming.syncedAt.value
          : DateTime.now(),
      deletedAt: incoming.deletedAt.present
          ? incoming.deletedAt
          : Value(current.deletedAt),
    );
  }

  String _useText(Value<String> incoming, String current) {
    if (!incoming.present) return current;
    final value = incoming.value.trim();
    if (value.isEmpty && current.trim().isNotEmpty) return current;
    return incoming.value;
  }

  DateTime? _useDate(Value<DateTime?> incoming, DateTime? current) {
    if (!incoming.present) return current;
    final value = incoming.value;
    if (_isFallbackDate(value) && !_isFallbackDate(current)) return current;
    return value;
  }

  int _useCount(Value<int> incoming, int current) {
    if (!incoming.present) return current;
    final value = incoming.value;
    if (value <= 0 && current > 0) return current;
    return value;
  }

  bool _isFallbackDate(DateTime? value) {
    if (value == null) return true;
    return !value.isAfter(DateTime.utc(1981));
  }

  Value<String> _preferText(Value<String> incoming, Value<String> current) {
    if (incoming.present && incoming.value.trim().isNotEmpty) return incoming;
    return current.present ? current : incoming;
  }

  Value<DateTime?> _preferDate(
    Value<DateTime?> incoming,
    Value<DateTime?> current,
  ) {
    if (incoming.present && !_isFallbackDate(incoming.value)) return incoming;
    return current.present ? current : incoming;
  }

  Value<int> _preferCount(Value<int> incoming, Value<int> current) {
    if (incoming.present && (incoming.value > 0 || !current.present)) {
      return incoming;
    }
    return current.present ? current : incoming;
  }

  bool _matchesUser(DbUsersCompanion candidate, DbUser current) {
    return candidate.username.value == current.username &&
        candidate.displayName.value == current.displayName &&
        candidate.avatarUrl.value == current.avatarUrl &&
        candidate.avatarSrcset.value == current.avatarSrcset &&
        candidate.joinedAt.value == current.joinedAt &&
        candidate.lastSeenAt.value == current.lastSeenAt &&
        candidate.discussionCount.value == current.discussionCount &&
        candidate.commentCount.value == current.commentCount &&
        candidate.email.value == current.email &&
        candidate.bio.value == current.bio &&
        candidate.rawJson.value == current.rawJson &&
        candidate.deletedAt.value == current.deletedAt;
  }

  Future<DbUser?> getUser(int id) {
    return (select(dbUsers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<int, DbUser>> getUsersByIds(List<int> ids) async {
    if (ids.isEmpty) return const <int, DbUser>{};
    final rows = await (select(dbUsers)..where((t) => t.id.isIn(ids))).get();
    return {for (final row in rows) row.id: row};
  }

  Future<void> upsertPosts(List<DbPostsCompanion> posts) async {
    if (posts.isEmpty) return;
    await batch((batch) => batch.insertAllOnConflictUpdate(dbPosts, posts));
  }

  Future<Map<int, DbPost>> getPostsByIds(List<int> ids) async {
    if (ids.isEmpty) return const <int, DbPost>{};
    final rows = await (select(dbPosts)..where((t) => t.id.isIn(ids))).get();
    return {for (final row in rows) row.id: row};
  }

  Future<void> upsertTags(List<DbTagsCompanion> tags) async {
    if (tags.isEmpty) return;
    await batch((batch) => batch.insertAllOnConflictUpdate(dbTags, tags));
  }

  Future<int> countUsers() => _count('db_users');
  Future<int> countPosts() => _count('db_posts');
  Future<int> countTags() => _count('db_tags');
  Future<int> countNotifications() => _count('db_notifications');

  Future<int> _count(String table) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM $table',
    ).getSingle();
    return row.read<int>('c');
  }

  Future<List<DbTag>> getTags() {
    return select(dbTags).get();
  }

  Future<void> replaceDiscussionTags({
    required String discussionId,
    required List<DbDiscussionTagsCompanion> tags,
  }) async {
    await transaction(() async {
      await (delete(
        dbDiscussionTags,
      )..where((t) => t.discussionId.equals(discussionId))).go();
      if (tags.isNotEmpty) {
        await batch(
          (batch) => batch.insertAllOnConflictUpdate(dbDiscussionTags, tags),
        );
      }
    });
  }

  Future<void> upsertNotifications(
    List<DbNotificationsCompanion> notifications,
  ) async {
    if (notifications.isEmpty) return;
    await batch(
      (batch) =>
          batch.insertAllOnConflictUpdate(dbNotifications, notifications),
    );
  }

  Future<List<DbNotification>> getNotifications({int limit = 20}) {
    return (select(dbNotifications)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markAllNotificationsDeleted() {
    return update(
      dbNotifications,
    ).write(DbNotificationsCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<void> markNotificationRead(int id) {
    return (update(dbNotifications)..where((t) => t.id.equals(id))).write(
      DbNotificationsCompanion(isRead: const Value(true)),
    );
  }

  Future<void> markAllNotificationsRead() {
    return update(
      dbNotifications,
    ).write(DbNotificationsCompanion(isRead: const Value(true)));
  }

  Future<void> markPostDeleted(int id) {
    return (update(dbPosts)..where((t) => t.id.equals(id))).write(
      DbPostsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> clearAll() async {
    await delete(dbNotifications).go();
    await delete(dbDiscussionTags).go();
    await delete(dbTags).go();
    await delete(dbPosts).go();
    await delete(dbUsers).go();
  }

  Future<void> clearPosts() async {
    await delete(dbPosts).go();
  }

  Future<void> clearUsers() async {
    await delete(dbUsers).go();
  }

  Future<void> clearTags() async {
    await delete(dbDiscussionTags).go();
    await delete(dbTags).go();
  }

  Future<void> clearNotifications() async {
    await delete(dbNotifications).go();
  }
}
