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
    this.canStartDiscussion,
  );

  factory TagInfo.fromBaseData(BaseData data) {
    final m = data.attrs;

    int? parentId;
    if (m.boolean("isChild") && data.relationships.containsKey("parent")) {
      final id = data.relatedId("parent", -1);
      parentId = id >= 0 ? id : null;
    }

    return TagInfo(
      m.string("name"),
      data.id,
      m.string("description"),
      m.string("slug"),
      m.integer("discussionCount"),
      m.contains("position") ? m.integer("position", -1) : null,
      m.string("lastPostedAt"),
      SplayTreeMap(),
      -1,
      m.boolean("isChild"),
      parentId,
      m.boolean("canStartDiscussion", true),
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
