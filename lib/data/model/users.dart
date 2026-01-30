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
  Groups? groups;

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
  );

  factory UserInfo.formJson(String data) {
    return UserInfo.formBaseData(BaseBean.formJson(data).data);
  }

  factory UserInfo.formBaseData(BaseData data) {
    Map m = data.attributes;
    return UserInfo(
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
    );
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
  );
}
