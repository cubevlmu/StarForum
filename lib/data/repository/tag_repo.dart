/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/tags.dart';
import 'package:forum/utils/log_util.dart';

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
}
