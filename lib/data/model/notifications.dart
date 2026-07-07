/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:star_forum/data/api/flarum_links.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';

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
}

class NotificationInfoList {
  Links links;
  List<NotificationsInfo> list;

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
}

class WarningSubject extends NotificationSubject {
  final WarningInfo warning;
  WarningSubject(this.warning) : super("warnings", warning.id);
}
