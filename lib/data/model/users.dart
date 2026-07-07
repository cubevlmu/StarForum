/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:star_forum/utils/string_util.dart';

import 'group_info.dart';

class UserInfo {
  final int id;
  final String username;
  String displayName;
  String avatarUrl;
  String avatarSrcset;
  final DateTime joinTime;
  DateTime lastSeenAt;
  int discussionCount;
  int commentCount;
  String email;
  String bio;
  final Groups? groups;
  ExpInfo? expInfo;

  UserInfo(
    this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.joinTime,
    this.discussionCount,
    this.commentCount,
    this.lastSeenAt,
    this.email,
    this.groups,
    this.bio, {
    this.avatarSrcset = '',
  });

  void update(UserInfo? info) {
    if (info == null) return;
    final nextDisplayName = info.displayName.trim();
    final nextAvatarUrl = info.avatarUrl.trim();
    final nextAvatarSrcset = info.avatarSrcset.trim();
    if (nextDisplayName.isNotEmpty && displayName != info.displayName) {
      displayName = info.displayName;
    }
    if (nextAvatarUrl.isNotEmpty && avatarUrl != info.avatarUrl) {
      avatarUrl = info.avatarUrl;
    }
    if (nextAvatarSrcset.isNotEmpty && avatarSrcset != info.avatarSrcset) {
      avatarSrcset = info.avatarSrcset;
    }
    if ((info.discussionCount > 0 || discussionCount <= 0) &&
        discussionCount != info.discussionCount) {
      discussionCount = info.discussionCount;
    }
    if ((info.commentCount > 0 || commentCount <= 0) &&
        commentCount != info.commentCount) {
      commentCount = info.commentCount;
    }
    if (info.lastSeenAt.isAfter(DateTime.utc(1981)) &&
        lastSeenAt != info.lastSeenAt) {
      lastSeenAt = info.lastSeenAt;
    }
    if (info.email.trim().isNotEmpty && email != info.email) email = info.email;
    if (info.bio.trim().isNotEmpty && bio != info.bio) bio = info.bio;
  }

  static UserInfo deletedUser = UserInfo(
    -1,
    "[deleted]",
    "[deleted]",
    "",
    fallbackTime,
    0,
    0,
    fallbackTime,
    "",
    null,
    "",
  );

  static UserInfo guestUser = UserInfo(
    -1,
    "[GUEST]",
    "[GUEST]",
    "",
    fallbackTime,
    -1,
    -1,
    fallbackTime,
    "",
    null,
    "",
  );

  static UserInfo placeholder(int id) =>
      UserInfo(id, "", "", "", fallbackTime, 0, 0, fallbackTime, "", null, "");

  static String displayLabel(
    UserInfo? user, {
    int? fallbackId,
    String fallback = "",
  }) {
    final displayName = user?.displayName.trim() ?? "";
    if (displayName.isNotEmpty) return displayName;
    final username = user?.username.trim() ?? "";
    if (username.isNotEmpty) return username;
    final fallbackLabel = fallback.trim();
    if (fallbackLabel.isNotEmpty) return fallbackLabel;
    final id = fallbackId ?? user?.id ?? -1;
    if (id > 0) return "#$id";
    return "";
  }
}

class ExpInfo {
  final String expLevel; // "expLevel": "锁链",
  final int expTotal; // "expTotal": 95,
  final int expPercent; // "expPercent": 45,
  final String expNext; //  "expNext": "铁",
  final int expNextNeed; //   "expNextNeed": 55,

  ExpInfo(
    this.expLevel,
    this.expTotal,
    this.expPercent,
    this.expNext,
    this.expNextNeed,
  );

  static ExpInfo empty = ExpInfo("", 0, 0, "", 0);
}
