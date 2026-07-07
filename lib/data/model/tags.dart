/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:collection';

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
  final bool canAddToDiscussion;
  final String icon;
  final String color;
  final String backgroundUrl;
  final String backgroundMode;

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
    this.canStartDiscussion, {
    this.canAddToDiscussion = true,
    this.icon = '',
    this.color = '',
    this.backgroundUrl = '',
    this.backgroundMode = '',
  });
}

class Tags {
  SplayTreeMap<int, TagInfo> tags;
  Map<int, TagInfo> miniTags;
  Map<int, TagInfo> all = {};

  Tags(this.all, this.tags, this.miniTags);
}
