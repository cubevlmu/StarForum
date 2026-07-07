/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

class GroupInfo {
  final int id;
  final String name;
  final String color;
  final String icon;

  GroupInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class Groups {
  final List<GroupInfo> list;

  Groups({required this.list});
}
