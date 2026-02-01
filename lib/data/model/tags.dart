import 'dart:collection';

import 'base.dart';

class TagInfo {
  String name;
  int id;
  String description;
  String slug;
  String color;
  String backgroundUrl;
  String backgroundMode;
  String icon;
  int discussionCount;
  int? position;
  String lastPostedAt;
  SplayTreeMap<int, TagInfo>? children;
  int parent;
  bool isChild;
  int? parentId;
  bool canStartDiscussion;

  TagInfo(
    this.name,
    this.id,
    this.description,
    this.slug,
    this.color,
    this.backgroundUrl,
    this.backgroundMode,
    this.icon,
    this.discussionCount,
    this.position,
    this.lastPostedAt,
    this.children,
    this.parent,
    this.isChild,
    this.parentId,
    this.canStartDiscussion
  );

  factory TagInfo.formBaseData(BaseData data) {
    var m = data.attributes;

    int? parentId;
    if (m["isChild"] == true) {
      parentId = int.parse(data.relationships!["parent"]["data"]["id"]);
    }

    return TagInfo(
      m["name"],
      data.id,
      m["description"],
      m["slug"],
      m["color"],
      m["backgroundUrl"] ?? "",
      m["backgroundMode"] ?? "",
      m["icon"] ?? "",
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

  static Tags getListFormJson(String data) {
    return getListFormBase(BaseListBean.formJson(data));
  }

  static Tags getListFormBase(BaseListBean base) {
    final Map<int, TagInfo> all = {};
    final Map<int, TagInfo> miniTags = {};

    for (final m in base.data.list) {
      final t = TagInfo.formBaseData(m);

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
