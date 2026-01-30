/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';

class DbDiscussions extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();
  TextColumn get slug => text()();

  IntColumn get commentCount => integer()();
  IntColumn get participantCount => integer()();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  IntColumn get likeCount => integer().withDefault(const Constant(0))();

  /// 作者（discussion.user）
  TextColumn get authorName => text().withDefault(const Constant(""))();
  TextColumn get authorAvatar => text().withDefault(const Constant(""))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastPostedAt => dateTime().nullable()();
  IntColumn get lastPostNumber => integer()();
  IntColumn get posterId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
