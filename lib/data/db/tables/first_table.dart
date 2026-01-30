/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';

class DbFirstPosts extends Table {
  TextColumn get discussionId => text()();

  /// 原始内容（Markdown / HTML）
  TextColumn get content => text()();

  /// firstPost.updatedAt
  DateTimeColumn get updatedAt => dateTime()();
  
  /// firstPost.likeCount
  IntColumn get likeCount => integer()();

  @override
  Set<Column> get primaryKey => {discussionId};
}
