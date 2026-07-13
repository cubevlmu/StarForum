/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'package:star_forum/utils/string_util.dart';
import 'package:flutter/foundation.dart';

import 'group_info.dart';

const _notProvided = Object();

@immutable
class UserInfo {
  final int id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String avatarSrcset;
  final DateTime joinTime;
  final DateTime lastSeenAt;
  final int discussionCount;
  final int commentCount;
  final String email;
  final String bio;
  final Groups? groups;
  final ExpInfo? expInfo;

  const UserInfo(
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
    this.expInfo,
  });

  UserInfo copyWith({
    int? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    DateTime? joinTime,
    int? discussionCount,
    int? commentCount,
    DateTime? lastSeenAt,
    String? email,
    Object? groups = _notProvided,
    String? bio,
    String? avatarSrcset,
    Object? expInfo = _notProvided,
  }) {
    return UserInfo(
      id ?? this.id,
      username ?? this.username,
      displayName ?? this.displayName,
      avatarUrl ?? this.avatarUrl,
      joinTime ?? this.joinTime,
      discussionCount ?? this.discussionCount,
      commentCount ?? this.commentCount,
      lastSeenAt ?? this.lastSeenAt,
      email ?? this.email,
      identical(groups, _notProvided) ? this.groups : groups as Groups?,
      bio ?? this.bio,
      avatarSrcset: avatarSrcset ?? this.avatarSrcset,
      expInfo: identical(expInfo, _notProvided)
          ? this.expInfo
          : expInfo as ExpInfo?,
    );
  }

  UserInfo mergedWith(UserInfo? info) {
    if (info == null) return this;
    final nextDisplayName = info.displayName.trim();
    final nextAvatarUrl = info.avatarUrl.trim();
    final nextAvatarSrcset = info.avatarSrcset.trim();
    return copyWith(
      displayName: nextDisplayName.isNotEmpty ? info.displayName : displayName,
      avatarUrl: nextAvatarUrl.isNotEmpty ? info.avatarUrl : avatarUrl,
      avatarSrcset: nextAvatarSrcset.isNotEmpty
          ? info.avatarSrcset
          : avatarSrcset,
      discussionCount: info.discussionCount > 0 || discussionCount <= 0
          ? info.discussionCount
          : discussionCount,
      commentCount: info.commentCount > 0 || commentCount <= 0
          ? info.commentCount
          : commentCount,
      lastSeenAt: info.lastSeenAt.isAfter(DateTime.utc(1981))
          ? info.lastSeenAt
          : lastSeenAt,
      email: info.email.trim().isNotEmpty ? info.email : email,
      bio: info.bio.trim().isNotEmpty ? info.bio : bio,
      groups: info.groups ?? groups,
      expInfo: info.expInfo ?? expInfo,
    );
  }

  static final UserInfo deletedUser = UserInfo(
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

  static final UserInfo guestUser = UserInfo(
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

@immutable
class ExpInfo {
  final String expLevel; // "expLevel": "锁链",
  final int expTotal; // "expTotal": 95,
  final int expPercent; // "expPercent": 45,
  final String expNext; //  "expNext": "铁",
  final int expNextNeed; //   "expNextNeed": 55,

  const ExpInfo(
    this.expLevel,
    this.expTotal,
    this.expPercent,
    this.expNext,
    this.expNextNeed,
  );

  static final ExpInfo empty = ExpInfo("", 0, 0, "", 0);
}
