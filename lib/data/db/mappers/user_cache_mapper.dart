import 'package:drift/drift.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/model/users.dart';

extension UserInfoCacheMapper on UserInfo {
  bool get hasCacheableIdentity {
    return id > 0 &&
        (username.trim().isNotEmpty ||
            displayName.trim().isNotEmpty ||
            avatarUrl.trim().isNotEmpty);
  }

  String get fingerprint {
    return [
      id,
      username,
      displayName,
      avatarUrl,
      discussionCount,
      commentCount,
      lastSeenAt.toUtc().toIso8601String(),
    ].join('|');
  }

  DbUsersCompanion toDbUser() {
    return DbUsersCompanion.insert(
      id: Value(id),
      username: username,
      displayName: displayName,
      avatarUrl: Value(avatarUrl),
      avatarSrcset: Value(avatarSrcset),
      joinedAt: Value(joinTime),
      lastSeenAt: Value(lastSeenAt),
      discussionCount: Value(discussionCount),
      commentCount: Value(commentCount),
      email: Value(email),
      bio: Value(bio),
      syncedAt: DateTime.now(),
      deletedAt: const Value(null),
    );
  }
}

extension DbUserCacheMapper on DbUser {
  UserInfo toUserInfo() {
    return UserInfo(
      id,
      username,
      displayName,
      avatarUrl,
      joinedAt ?? DateTime.utc(1980),
      discussionCount,
      commentCount,
      lastSeenAt ?? DateTime.utc(1980),
      email,
      null,
      bio,
      avatarSrcset: avatarSrcset,
    );
  }
}
