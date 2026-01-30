/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:drift/drift.dart';

class DbDiscussionExcerptCache extends Table {
  TextColumn get discussionId => text()();

  /// 已生成的纯文本摘要
  TextColumn get excerpt => text()();

  /// 摘要基于的 firstPost.updatedAt
  DateTimeColumn get sourceUpdatedAt => dateTime()();

  /// 摘要生成时间（用于粗失效判断）
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {discussionId};
}
