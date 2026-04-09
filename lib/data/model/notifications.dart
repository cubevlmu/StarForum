/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';

import 'base.dart';

class NotificationsInfo {
  final int id;
  final String contentType;
  final DateTime createdAt;
  bool isRead;
  final JsonMap? content;

  UserInfo? fromUser;
  NotificationSubject? subject;
  String? cachedTitle;
  String? cachedDesc;

  NotificationsInfo({
    required this.id,
    required this.contentType,
    required this.createdAt,
    required this.isRead,
    this.content,
    this.fromUser,
    this.subject,
    this.cachedTitle,
    this.cachedDesc,
  });

  factory NotificationsInfo.formMapAndId(Map map, int id) {
    final attrs = JsonReader(asJsonMap(map));
    return NotificationsInfo(
      id: id,
      contentType: attrs.string("contentType"),
      createdAt: attrs.dateTime("createdAt"),
      isRead: attrs.boolean("isRead"),
      content: map["content"] is Map ? asJsonMap(map["content"]) : null,
    );
  }

  factory NotificationsInfo.fromMap(Map map) {
    var base = BaseBean.fromMap(map);
    return NotificationsInfo.formMapAndId(base.data.attributes, base.data.id);
  }
}

class NotificationInfoList {
  Links links;
  List<NotificationsInfo> list;

  factory NotificationInfoList.fromMap(Map map) {
    return NotificationInfoList.fromBase(BaseListBean.fromMap(map));
  }

  factory NotificationInfoList.fromBase(BaseListBean base) {
    final list = <NotificationsInfo>[];
    final users = <int, UserInfo>{};
    final posts = <int, PostInfo>{};
    final discussions = <int, DiscussionNotificationInfo>{};
    final quests = <int, QuestInfo>{};
    final levels = <int, LevelInfo>{};
    final badges = <int, UserBadgeInfo>{};
    final warnings = <int, WarningInfo>{};

    for (final d in base.included.data) {
      switch (d.type) {
        case "users":
          users[d.id] = UserInfo.fromBaseData(d);
          break;
        case "posts":
          posts[d.id] = PostInfo.fromBaseData(d);
          break;
        case "discussions":
          discussions[d.id] = DiscussionNotificationInfo.fromBaseData(d);
          break;
        case "quest-infos":
          quests[d.id] = QuestInfo.fromBaseData(d);
          break;
        case "levels":
          levels[d.id] = LevelInfo.fromBaseData(d);
          break;
        case "userBadges":
          badges[d.id] = UserBadgeInfo.fromBaseData(d);
          break;
        case "warnings":
          warnings[d.id] = WarningInfo.fromBaseData(d);
          break;
      }
    }

    for (var d in base.data.list) {
      final n = NotificationsInfo.formMapAndId(d.attributes, d.id);

      n.fromUser = users[d.relatedId("fromUser", -1)];

      final subjectType = d.relatedType("subject");
      final subjectId = d.relatedId("subject", -1);
      switch (subjectType) {
        case "posts":
          final post = posts[subjectId];
          if (post != null) {
            n.subject = PostSubject(post);
          } else if (subjectId >= 0) {
            n.subject = PostSubject(
              PostInfo(subjectId, '', '', '', -1, -1, -1, -1),
            );
          }
          break;
        case "discussions":
          final discussion = discussions[subjectId];
          if (discussion != null) {
            n.subject = DiscussionSubject(discussion);
          } else if (subjectId >= 0) {
            n.subject = DiscussionSubject(
              DiscussionNotificationInfo(id: subjectId, title: ''),
            );
          }
          break;
        case "users":
          final user = users[subjectId];
          if (user != null) {
            n.subject = UserSubject(
              NotificationUserInfo(
                id: user.id,
                displayName: user.displayName,
                avatarUrl: user.avatarUrl,
              ),
            );
          } else if (subjectId >= 0) {
            n.subject = UserSubject(
              NotificationUserInfo(
                id: subjectId,
                displayName: n.fromUser?.displayName ?? '',
                avatarUrl: n.fromUser?.avatarUrl ?? '',
              ),
            );
          }
          break;
        case "quest-infos":
          final quest = quests[subjectId];
          if (quest != null) {
            n.subject = QuestSubject(quest);
          } else if (subjectId >= 0) {
            n.subject = QuestSubject(
              QuestInfo(id: subjectId, name: '', description: ''),
            );
          }
          break;
        case "levels":
          final level = levels[subjectId];
          if (level != null) {
            n.subject = LevelSubject(level);
          } else if (subjectId >= 0) {
            n.subject = LevelSubject(
              LevelInfo(id: subjectId, name: '', minExpRequired: 0),
            );
          }
          break;
        case "userBadges":
          final badge = badges[subjectId];
          if (badge != null) n.subject = UserBadgeSubject(badge);
          break;
        case "warnings":
          final warning = warnings[subjectId];
          if (warning != null) n.subject = WarningSubject(warning);
          break;
      }

      list.add(n);
    }

    return NotificationInfoList(list, base.links);
  }

  NotificationInfoList(this.list, this.links);
}

abstract class NotificationSubject {
  String type;
  int id;

  NotificationSubject(this.type, this.id);
}

class PostSubject extends NotificationSubject {
  final PostInfo post;
  PostSubject(this.post) : super("posts", post.id);
}

class DiscussionNotificationInfo {
  final int id;
  final String title;

  DiscussionNotificationInfo({required this.id, required this.title});

  factory DiscussionNotificationInfo.fromBaseData(BaseData d) {
    final attrs = d.attrs;
    return DiscussionNotificationInfo(id: d.id, title: attrs.string("title"));
  }
}

class DiscussionSubject extends NotificationSubject {
  final DiscussionNotificationInfo discussion;
  DiscussionSubject(this.discussion) : super("discussions", discussion.id);
}

class NotificationUserInfo {
  final int id;
  final String displayName;
  final String avatarUrl;

  NotificationUserInfo({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
  });
}

class UserSubject extends NotificationSubject {
  final NotificationUserInfo user;
  UserSubject(this.user) : super("users", user.id);
}

class QuestSubject extends NotificationSubject {
  final QuestInfo quest;
  QuestSubject(this.quest) : super("quest-infos", quest.id);
}

class LevelSubject extends NotificationSubject {
  final LevelInfo level;
  LevelSubject(this.level) : super("levels", level.id);
}

class QuestInfo {
  final int id;
  final String name;
  final String description;

  QuestInfo({required this.id, required this.name, required this.description});

  factory QuestInfo.fromBaseData(BaseData d) {
    final attrs = d.attrs;
    return QuestInfo(
      id: d.id,
      name: attrs.string("name"),
      description: attrs.string("description"),
    );
  }
}

class LevelInfo {
  final int id;
  final String name;
  final int minExpRequired;

  LevelInfo({
    required this.id,
    required this.name,
    required this.minExpRequired,
  });

  factory LevelInfo.fromBaseData(BaseData d) {
    final attrs = d.attrs;
    return LevelInfo(
      id: d.id,
      name: attrs.string("name"),
      minExpRequired: attrs.integer("min_exp_required"),
    );
  }
}

class UserBadgeInfo {
  final int id;
  final String? description;
  final DateTime assignedAt;
  final bool isPrimary;
  final bool inUserCard;

  UserBadgeInfo({
    required this.id,
    required this.assignedAt,
    required this.isPrimary,
    required this.inUserCard,
    this.description,
  });

  factory UserBadgeInfo.fromBaseData(BaseData d) {
    final attrs = d.attrs;
    return UserBadgeInfo(
      id: d.id,
      description: attrs["description"] as String?,
      assignedAt: attrs.dateTime("assignedAt"),
      isPrimary: attrs.boolean("isPrimary"),
      inUserCard: attrs.boolean("inUserCard"),
    );
  }
}

class UserBadgeSubject extends NotificationSubject {
  final UserBadgeInfo badge;
  UserBadgeSubject(this.badge) : super("userBadges", badge.id);
}

class WarningInfo {
  final int id;
  final int userId;
  final String? publicComment;
  final String? privateComment;
  final int strikes;
  final DateTime createdAt;

  WarningInfo({
    required this.id,
    required this.userId,
    required this.strikes,
    required this.createdAt,
    this.publicComment,
    this.privateComment,
  });

  factory WarningInfo.fromBaseData(BaseData d) {
    final attrs = d.attrs;
    return WarningInfo(
      id: d.id,
      userId: attrs.integer("userId"),
      publicComment: attrs["public_comment"] as String?,
      privateComment: attrs["private_comment"] as String?,
      strikes: attrs.integer("strikes"),
      createdAt: attrs.dateTime("createdAt"),
    );
  }
}

class WarningSubject extends NotificationSubject {
  final WarningInfo warning;
  WarningSubject(this.warning) : super("warnings", warning.id);
}
