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
  );

  factory TagInfo.formBaseData(BaseData data) {
    var m = data.attributes;
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
      m["position"] ?? 0,
      m["lastPostedAt"] ?? "",
      SplayTreeMap(),
      -1,
    );
  }

  static Tags getListFormJson(String data) {
    return getListFormBase(BaseListBean.formJson(data));
  }

  static Tags getListFormBase(BaseListBean base) {
    Map<int, TagInfo> tags = {};
    List<TagInfo> children = [];
    Map<int, TagInfo> miniTags = {};
    for (var m in base.data.list) {
      var t = TagInfo.formBaseData(m);
      if (t.position == null) {
        t.children = null;
        miniTags.addAll({t.id: t});
      // } else if (t.isChild) {
      //   int parentId = int.parse(m.relationships?["parent"]["data"]["id"]);
      //   t.parent = parentId;
      //   children.add(t);
      } else {
        tags.addAll({t.id: t});
      }
    }
      for (var tag in children) {
      var parent = tags[tag.parent];
      parent?.children?.addAll({?tag.position: tag});
    }
    SplayTreeMap<int, TagInfo> splayTreeList = SplayTreeMap();
    tags.forEach((id, tag) {
      splayTreeList.addAll({?tag.position: tag});
    });

    SplayTreeMap<int, TagInfo> positionFixedSplayTreeListList = SplayTreeMap();
    var i = 0;
    splayTreeList.forEach((position, t) {
      if (t.children?.isEmpty ?? false) {
        t.children = null;
      }
      positionFixedSplayTreeListList.addAll({i: t});
      i++;
    });

    return Tags(positionFixedSplayTreeListList, miniTags);
  }
}

class Tags {
  SplayTreeMap<int, TagInfo> tags;
  Map<int, TagInfo> miniTags;

  Tags(this.tags, this.miniTags);
}
