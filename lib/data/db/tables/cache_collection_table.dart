import 'package:drift/drift.dart';

class DbCacheCollectionItems extends Table {
  TextColumn get collectionKey => text()();
  TextColumn get resourceType => text()();
  TextColumn get resourceId => text()();
  IntColumn get sortIndex => integer()();
  TextColumn get fingerprint => text()();
  DateTimeColumn get seenAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {collectionKey, resourceType, resourceId};
}

class DbSyncStates extends Table {
  TextColumn get collectionKey => text()();
  TextColumn get nextUrl => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get ttlSeconds => integer().withDefault(const Constant(60))();

  @override
  Set<Column> get primaryKey => {collectionKey};
}
