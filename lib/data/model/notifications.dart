/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:forum/data/model/posts.dart';
import 'package:forum/data/model/users.dart';

import 'base.dart';

class NotificationsInfo {
  int id;
  String contentType;
  dynamic content;
  DateTime createdAt;
  bool isRead;

  UserInfo? fromUser;
  NotificationSubject? subject;

  NotificationsInfo({
    required this.id,
    required this.contentType,
    required this.content,
    required this.createdAt,
    required this.isRead,
    this.fromUser,
    this.subject,
  });

  factory NotificationsInfo.formMapAndId(Map map, int id) {
    return NotificationsInfo(
      id: id,
      contentType: map["contentType"],
      content: map["content"],
      createdAt: DateTime.parse(map["createdAt"]),
      isRead: map["isRead"] ?? false,
    );
  }

  factory NotificationsInfo.formJson(String data) {
    var base = BaseBean.formJson(data);
    return NotificationsInfo.formMapAndId(base.data.attributes, base.data.id);
  }
}

class NotificationInfoList {
  Links links;
  List<NotificationsInfo> list;

  factory NotificationInfoList.formJson(String data) {
    return NotificationInfoList.formBase(BaseListBean.formJson(data));
  }

  factory NotificationInfoList.formBase(BaseListBean base) {
    List<NotificationsInfo> list = [];
    final Map<String, Map<int, dynamic>> included = {};

    void addIncluded(String type, int id, dynamic value) {
      included.putIfAbsent(type, () => {})[id] = value;
    }

    for (var d in base.included.data ?? []) {
      switch (d.type) {
        case "users":
          addIncluded("users", d.id, UserInfo.formBaseData(d));
          break;
        case "posts":
          addIncluded("posts", d.id, PostInfo.formBaseData(d));
          break;
        case "quest-infos":
          addIncluded("quest-infos", d.id, QuestInfo.formBaseData(d));
          break;
        case "levels":
          addIncluded("levels", d.id, LevelInfo.formBaseData(d));
          break;
        case "userBadges":
          addIncluded("userBadges", d.id, UserBadgeInfo.formBaseData(d));
          break;
        case "warnings":
          addIncluded("warnings", d.id, WarningInfo.formBaseData(d));
          break;
      }
    }

    for (var d in base.data.list) {
      final n = NotificationsInfo.formMapAndId(d.attributes, d.id);

      // fromUser
      final from = d.relationships?["fromUser"]?["data"];
      if (from != null) {
        n.fromUser = included["users"]?[int.parse(from["id"])];
      }

      // subject
      final sub = d.relationships?["subject"]?["data"];
      if (sub != null) {
        final type = sub["type"];
        final id = int.parse(sub["id"]);
        final obj = included[type]?[id];

        if (obj is PostInfo) {
          n.subject = PostSubject(obj);
        } else if (obj is QuestInfo) {
          n.subject = QuestSubject(obj);
        } else if (obj is LevelInfo) {
          n.subject = LevelSubject(obj);
        } else if (obj is UserBadgeInfo) {
          n.subject = UserBadgeSubject(obj);
        } else if (obj is WarningInfo) {
          n.subject = WarningSubject(obj);
        }
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

  factory QuestInfo.formBaseData(BaseData d) {
    return QuestInfo(
      id: d.id,
      name: d.attributes["name"],
      description: d.attributes["description"],
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

  factory LevelInfo.formBaseData(BaseData d) {
    return LevelInfo(
      id: d.id,
      name: d.attributes["name"],
      minExpRequired: d.attributes["min_exp_required"] ?? 0,
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

  factory UserBadgeInfo.formBaseData(BaseData d) {
    return UserBadgeInfo(
      id: d.id,
      description: d.attributes["description"],
      assignedAt: DateTime.parse(d.attributes["assignedAt"]),
      isPrimary: (d.attributes["isPrimary"] ?? 0) == 1,
      inUserCard: d.attributes["inUserCard"] ?? false,
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

  factory WarningInfo.formBaseData(BaseData d) {
    return WarningInfo(
      id: d.id,
      userId: d.attributes["userId"],
      publicComment: d.attributes["public_comment"],
      privateComment: d.attributes["private_comment"],
      strikes: d.attributes["strikes"] ?? 0,
      createdAt: DateTime.parse(d.attributes["createdAt"]),
    );
  }
}

class WarningSubject extends NotificationSubject {
  final WarningInfo warning;
  WarningSubject(this.warning) : super("warnings", warning.id);
}
