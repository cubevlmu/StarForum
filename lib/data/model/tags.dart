/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:collection';

import 'base.dart';

class TagInfo {
  final String name;
  final int id;
  final String description;
  final String slug;
  final int discussionCount;
  final int? position;
  final String lastPostedAt;
  SplayTreeMap<int, TagInfo>? children;
  final int parent;
  final bool isChild;
  final int? parentId;
  final bool canStartDiscussion;

  TagInfo(
    this.name,
    this.id,
    this.description,
    this.slug,
    this.discussionCount,
    this.position,
    this.lastPostedAt,
    this.children,
    this.parent,
    this.isChild,
    this.parentId,
    this.canStartDiscussion
  );

  factory TagInfo.fromBaseData(BaseData data) {
    var m = data.attributes;

    int? parentId;
    if (m["isChild"] == true) {
      parentId = int.parse(data.relationships["parent"]["data"]["id"]);
    }

    return TagInfo(
      m["name"],
      data.id,
      m["description"],
      m["slug"],
      m["discussionCount"] ?? 0,
      m["position"] ?? -1,
      m["lastPostedAt"] ?? "",
      SplayTreeMap(),
      -1,
      m["isChild"] ?? false,
      parentId,
      m["canStartDiscussion"] ?? false
    );
  }

  static Tags getListFormMap(Map data) {
    return getListfromBase(BaseListBean.fromMap(data));
  }

  static Tags getListfromBase(BaseListBean base) {
    final Map<int, TagInfo> all = {};
    final Map<int, TagInfo> miniTags = {};

    for (final m in base.data.list) {
      final t = TagInfo.fromBaseData(m);

      if (t.position == null) {
        t.children = null;
        miniTags[t.id] = t;
      } else {
        all[t.id] = t;
      }
    }

    final SplayTreeMap<int, TagInfo> roots = SplayTreeMap();

    for (final t in all.values) {
      if (t.isChild && t.parentId != null) {
        final parent = all[t.parentId!];
        parent?.children ??= SplayTreeMap();
        parent?.children![t.position!] = t;
      } else {
        roots[t.position!] = t;
      }
    }

    return Tags(all, roots, miniTags);
  }
}

class Tags {
  SplayTreeMap<int, TagInfo> tags;
  Map<int, TagInfo> miniTags;
  Map<int, TagInfo> all = {};

  Tags(this.all, this.tags, this.miniTags);
}
