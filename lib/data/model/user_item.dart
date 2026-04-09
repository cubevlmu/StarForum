/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/foundation.dart';

@immutable
class UserItem {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final DateTime joinTime;

  const UserItem({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.joinTime,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    final attr = json["attributes"];

    return UserItem(
      id: json["id"],
      username: attr["username"] ?? "",
      displayName: attr["displayName"] ?? attr["username"] ?? "",
      avatarUrl: attr["avatarUrl"],
      joinTime: DateTime.parse(attr["joinTime"]),
    );
  }
}