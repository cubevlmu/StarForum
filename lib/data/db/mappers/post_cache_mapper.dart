import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/model/posts.dart';

extension DbPostCacheMapper on DbPost {
  PostInfo toPostInfo() {
    return PostInfo(
      id,
      createdAt?.toIso8601String() ?? '',
      contentHtml,
      editedAt?.toIso8601String() ?? '',
      userId ?? -1,
      -1,
      discussionId,
      likesCount,
      number: number,
      contentType: contentType,
      isLiked: isLiked,
    );
  }
}

extension PostInfoCacheMapper on PostInfo {
  String get fingerprint {
    return [
      id,
      editedAt,
      createdAt,
      likes,
      isLiked,
      contentHtml.length,
    ].join('|');
  }

  DbPostsCompanion toDbPost() {
    return DbPostsCompanion.insert(
      id: Value(id),
      discussionId: discussion,
      number: Value(number),
      userId: Value(userId > 0 ? userId : null),
      contentType: Value(contentType),
      contentHtml: Value(contentHtml),
      createdAt: Value(DateTime.tryParse(createdAt)),
      editedAt: Value(DateTime.tryParse(editedAt)),
      likesCount: Value(likes),
      isLiked: Value(isLiked),
      fingerprint: Value(fingerprint),
      syncedAt: DateTime.now(),
      deletedAt: const Value(null),
    );
  }
}
