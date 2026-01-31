

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:get/get.dart';

class ThemeListController extends GetxController {
  ThemeListController();
  List<dynamic> items = []; // TagItem

  bool _hasMore = true;
  int pageNum = 1;
  
  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  int refreshIdx = 0;
  CacheManager cacheManager = CacheUtils.avatarCacheManager;

  void animateToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  Future<bool> _addThemeListItems() async {
    return true;
  }

  Future<void> onRefresh() async {
    pageNum = 1;
    _hasMore = true;
    items.clear();

    final ok = await _addThemeListItems();

    if (ok) {
      refreshController.finishRefresh();
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoad() async {
    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    final ok = await _addThemeListItems();

    if (!ok) {
      refreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    if (_hasMore) {
      refreshController.finishLoad();
    } else {
      refreshController.finishLoad(IndicatorResult.noMore);
    }
  }
}
