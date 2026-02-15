/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:collection';

import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/utils/log_util.dart';

class TagRepo {
  Tags? _tags;
  bool _syncing = false;

  bool get isReady => _tags != null;

  Future<void> syncTags() async {
    if (_syncing) return;
    _syncing = true;

    try {
      final r = await Api.getTags();
      if (r == null) {
        LogUtil.error("[TagRepo] empty tag response");
        return;
      }

      _tags = r;
    } catch (e, s) {
      LogUtil.errorE("[TagRepo] syncTags failed", e, s);
    } finally {
      _syncing = false;
    }
  }

  List<TagInfo> getRootTags() {
    if (_tags == null) return const [];
    return _tags!.tags.values.toList();
  }

  TagInfo? getMiniTag(int id) {
    return _tags?.miniTags[id];
  }

  List<String> getTagNames() {
    if (_tags == null) return const [];
    return _tags!.tags.values.map((e) => e.name).toList();
  }

  List<TagInfo> getRootTagsForUI() {
    if (_tags == null) return const [];

    final Map<int, TagInfo> all = {};

    for (final root in _tags!.tags.values) {
      all[root.id] = root;
      _collect(root, all);
    }

    final Map<int, List<TagInfo>> childrenMap = {};

    for (final tag in all.values) {
      if (tag.isChild && tag.parent > 0) {
        childrenMap.putIfAbsent(tag.parent, () => []).add(tag);
      }
    }

    for (final root in _tags!.tags.values) {
      final list = childrenMap[root.id];
      if (list != null && list.isNotEmpty) {
        root.children ??= SplayTreeMap();
        for (final c in list) {
          root.children!.addAll({c.position ?? 0: c});
        }
      }
    }

    return _tags!.tags.values.toList();
  }

  void _collect(TagInfo tag, Map<int, TagInfo> all) {
    final children = tag.children;
    if (children == null) return;

    for (final c in children.values) {
      all[c.id] = c;
      _collect(c, all);
    }
  }

  List<TagInfo> getTags() {
    if (_tags == null) return const [];
    return _tags!.all.values.where((t) => t.position == -1).toList();
  }

  List<TagInfo> getPrimaryTags() {
    if (_tags == null) return const [];
    return _tags!.all.values.where((t) => t.position != -1).toList();
  }

  TagInfo? getTagById(int value) {
    if (_tags == null) return null;
    if (!_tags!.all.containsKey(value)) return null;
    return _tags!.all[value];
  }

  void clear() {
    _tags = null;
    _syncing = false;
  }
}
