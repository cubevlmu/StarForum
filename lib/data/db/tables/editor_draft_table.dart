import 'package:drift/drift.dart';

class DbEditorDrafts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get forumUrl => text()();
  IntColumn get userId => integer().nullable()();
  TextColumn get target => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get primaryTagId => integer().nullable()();
  TextColumn get secondaryTagIds => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
