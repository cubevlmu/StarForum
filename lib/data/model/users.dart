/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'base.dart';
import 'group_info.dart';

class UserInfo {
  int id;
  String username;
  String displayName;
  String avatarUrl;
  String joinTime;
  int discussionCount;
  int commentCount;
  String lastSeenAt;
  String email;
  String bio;
  Groups? groups;
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

  factory UserInfo.formJson(String data) {
    return UserInfo.formBaseData(BaseBean.formJson(data).data);
  }

  factory UserInfo.formBaseData(BaseData data) {
    Map m = data.attributes;
    final ifo = ExpInfo.formBaseData(data);

    final u = UserInfo(
      data.id,
      m["username"],
      m["displayName"],
      m["avatarUrl"] ?? "",
      m["joinTime"] ?? "",
      m["discussionCount"] ?? 0,
      m["commentCount"] ?? 0,
      m["lastSeenAt"] ?? "",
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
    "",
    0,
    0,
    "",
    "",
    null,
    "",
  );

  static UserInfo guestUser = UserInfo(
    -1,
    "[GUEST]",
    "[GUEST]",
    "",
    "",
    -1,
    -1,
    "",
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

  factory ExpInfo.formBaseData(BaseData data) {
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
