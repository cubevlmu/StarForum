/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:collection';

import 'package:star_forum/data/db/dao/resource_cache_dao.dart';
import 'package:star_forum/data/db/mappers/tag_cache_mapper.dart';
import 'package:star_forum/data/api/services/tag_api.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/utils/log_util.dart';

class TagRepo {
  TagRepo(this.tagApi, this.resourceCacheDao);

  final TagApi tagApi;
  final ResourceCacheDao resourceCacheDao;
  Tags? _tags;
  Future<void>? _syncTask;

  bool get isReady => _tags != null;

  Future<void> syncTags() async {
    final activeTask = _syncTask;
    if (activeTask != null) {
      await activeTask;
      return;
    }
    final task = _performSync();
    _syncTask = task;
    try {
      await task;
    } finally {
      if (identical(_syncTask, task)) _syncTask = null;
    }
  }

  Future<void> _performSync() async {
    try {
      await _restoreCachedTags();
      final r = await tagApi.list();
      if (r == null) {
        LogUtil.error("[TagRepo] empty tag response");
        return;
      }
      _tags = r;
      await resourceCacheDao.upsertTags(
        [
          ...r.all.values,
          ...r.miniTags.values,
        ].map((tag) => tag.toDbTag()).toList(growable: false),
      );
    } catch (e, s) {
      LogUtil.errorE("[TagRepo] syncTags failed", e, s);
    }
  }

  Future<void> _restoreCachedTags() async {
    if (_tags != null) return;
    final rows = await resourceCacheDao.getTags();
    if (rows.isEmpty) return;
    final all = <int, TagInfo>{};
    final miniTags = <int, TagInfo>{};
    for (final row in rows) {
      final tag = row.toTagInfo();
      if (tag.position == null || tag.position == -1) {
        miniTags[tag.id] = tag;
      } else {
        all[tag.id] = tag;
      }
    }
    final roots = SplayTreeMap<int, TagInfo>();
    for (final tag in all.values) {
      if (tag.isChild && tag.parentId != null) {
        final parent = all[tag.parentId!];
        parent?.children ??= SplayTreeMap<int, TagInfo>();
        parent?.children?[tag.position ?? 0] = tag;
      } else {
        roots[tag.position ?? 0] = tag;
      }
    }
    _tags = Tags(all, roots, miniTags);
  }

  List<TagInfo> getRootTags() {
    return getRootTagsForUI();
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
    return _tags!.tags.values.toList(growable: false);
  }

  List<TagInfo> getTags() {
    if (_tags == null) return const [];
    return _tags!.miniTags.values.toList();
  }

  List<TagInfo> getPrimaryTags() {
    if (_tags == null) return const [];
    return _tags!.all.values.where((t) => t.position != -1).toList();
  }

  List<TagInfo> getAllTagsForDirectory() {
    if (_tags == null) return const [];
    final result = <TagInfo>[];
    final seen = <int>{};
    final roots = getRootTagsForUI();
    for (final root in roots) {
      if (seen.add(root.id)) result.add(root);
      final children = root.children?.values.toList() ?? const <TagInfo>[];
      for (final child in children) {
        if (seen.add(child.id)) result.add(child);
      }
    }
    final remaining = <TagInfo>[
      ..._tags!.all.values.where((tag) => !seen.contains(tag.id)),
      ..._tags!.miniTags.values.where((tag) => !seen.contains(tag.id)),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    result.addAll(remaining);
    return result;
  }

  TagInfo? getTagById(int value) {
    if (_tags == null) return null;
    if (!_tags!.all.containsKey(value)) return null;
    return _tags!.all[value];
  }

  void clear() {
    _tags = null;
    _syncTask = null;
  }
}
