/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'base.dart';

class GroupInfo {
  final int id;
  final String name;
  final String color;
  final String icon;

  factory GroupInfo.fromBaseData(BaseData data) {
    var m = data.attributes;
    return GroupInfo(
      id: data.id,
      name: m["namePlural"] ?? "",
      color: m["color"] ?? "#FFFFFF",
      icon: m["icon"] ?? "",
    );
  }

  GroupInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class Groups {
  final List<GroupInfo> list;

  factory Groups.fromBase(BaseListBean base) {
    final groups = Groups(list: []);
    for (var m in base.data.list) {
      var g = GroupInfo.fromBaseData(m);
      groups.list.add(g);
    }
    return groups;
  }

  factory Groups.fromMap(Map map) {
    return Groups.fromBase(BaseListBean.fromMap(map));
  }

  Groups({required this.list});
}
