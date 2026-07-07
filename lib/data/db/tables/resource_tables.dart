import 'package:drift/drift.dart';

class DbUsers extends Table {
  IntColumn get id => integer()();
  TextColumn get username => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().withDefault(const Constant(''))();
  TextColumn get avatarSrcset => text().withDefault(const Constant(''))();
  DateTimeColumn get joinedAt => dateTime().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  IntColumn get discussionCount => integer().withDefault(const Constant(0))();
  IntColumn get commentCount => integer().withDefault(const Constant(0))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get bio => text().withDefault(const Constant(''))();
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get syncedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbPosts extends Table {
  IntColumn get id => integer()();
  IntColumn get discussionId => integer()();
  IntColumn get number => integer().withDefault(const Constant(0))();
  IntColumn get userId => integer().withDefault(const Constant(-1))();
  TextColumn get contentType => text().withDefault(const Constant('comment'))();
  TextColumn get contentHtml => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  IntColumn get likesCount => integer().withDefault(const Constant(0))();
  BoolColumn get isLiked => boolean().withDefault(const Constant(false))();
  TextColumn get fingerprint => text().withDefault(const Constant(''))();
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get syncedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbTags extends Table {
  IntColumn get id => integer()();
  TextColumn get slug => text()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant(''))();
  TextColumn get icon => text().withDefault(const Constant(''))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get discussionCount => integer().withDefault(const Constant(0))();
  IntColumn get parentId => integer().nullable()();
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get syncedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbDiscussionTags extends Table {
  TextColumn get discussionId => text()();
  IntColumn get tagId => integer()();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {discussionId, tagId};
}

class DbNotifications extends Table {
  IntColumn get id => integer()();
  TextColumn get type => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  IntColumn get fromUserId => integer().nullable()();
  TextColumn get subjectType => text().nullable()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get contentJson => text().nullable()();
  TextColumn get cachedTitle => text().nullable()();
  TextColumn get cachedDesc => text().nullable()();
  TextColumn get fingerprint => text().withDefault(const Constant(''))();
  TextColumn get rawJson => text().nullable()();
  DateTimeColumn get syncedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
