/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:forum/utils/string_util.dart';

import 'base.dart';
import 'group_info.dart';

class UserInfo {
  final int id;
  final String username;
  String displayName;
  String avatarUrl;
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
    this.bio,
  );

  void update(UserInfo? info) {
    if (info == null) return;
    if (displayName != info.displayName) displayName = info.displayName;
    if (avatarUrl != info.avatarUrl) avatarUrl = info.avatarUrl;
    if (discussionCount != info.discussionCount) {
      discussionCount = info.discussionCount;
    }
    if (commentCount != info.commentCount) commentCount = info.commentCount;
    if (lastSeenAt != info.lastSeenAt) lastSeenAt = info.lastSeenAt;
    if (email != info.email) email = info.email;
    if (bio != info.bio) bio = info.bio;
  }

  factory UserInfo.fromMap(Map data) {
    return UserInfo.fromBaseData(BaseData.formMap(BaseBean.fromMap(data).data));
  }

  factory UserInfo.fromBaseData(BaseData data) {
    Map m = data.attributes;
    final ifo = ExpInfo.fromBaseData(data);

    final u = UserInfo(
      data.id,
      m["username"],
      m["displayName"],
      m["avatarUrl"] ?? "",
      DateTime.tryParse(m["joinTime"] ?? "") ?? fallbackTime,
      m["discussionCount"] ?? 0,
      m["commentCount"] ?? 0,
      DateTime.tryParse(m["lastSeenAt"] ?? "") ?? fallbackTime,
      m["email"] ?? "",
      m["groups"],
      m["bio"] ?? "",
    );
    if (ifo != ExpInfo.empty) {
      u.expInfo = ifo;
    }
    return u;
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

  factory ExpInfo.fromBaseData(BaseData data) {
    Map m = data.attributes;
    return ExpInfo(
      m["expLevel"] ?? "",
      m["expTotal"] ?? 0,
      m["expPercent"] ?? 0,
      m["expNext"] ?? "",
      m["expNextNeed"] ?? 0,
    );
  }

  static ExpInfo empty = ExpInfo("", 0, 0, "", 0);
}
