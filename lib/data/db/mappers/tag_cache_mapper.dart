import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/model/tags.dart';

extension TagInfoCacheMapper on TagInfo {
  DbTagsCompanion toDbTag({DateTime? syncedAt}) {
    return DbTagsCompanion.insert(
      id: Value(id),
      slug: slug,
      name: name,
      color: Value(color),
      icon: Value(icon),
      position: Value(position ?? -1),
      discussionCount: Value(discussionCount),
      parentId: Value(parentId),
      syncedAt: syncedAt ?? DateTime.now(),
      deletedAt: const Value(null),
    );
  }
}

extension DbTagCacheMapper on DbTag {
  TagInfo toTagInfo() {
    return TagInfo(
      name,
      id,
      '',
      slug,
      discussionCount,
      position == -1 ? null : position,
      '',
      null,
      -1,
      parentId != null,
      parentId,
      true,
      icon: icon,
      color: color,
    );
  }
}
