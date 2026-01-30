

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
  // int recommendColumnCount = 2;

  @override
  void onInit() {
    // recommendColumnCount = SettingsUtil.getValue(
    //     SettingsStorageKeys.recommendColumnCount,
    //     defaultValue: 2);
    super.onInit();
  }

  void animateToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

//加载并追加视频推荐
  Future<bool> _addThemeListItems() async {
    // late List<TagItem> resp;
    // try {
    //   resp = await SyncApi.getTags();
    //   log("[TagListPage] Response size: ${resp.length}");
    //   // replyCount.value = resp.length;
    // } catch (e) {
    //   log("[TagListPage] load post data failed, at _addThemeListItems with : $e");
    //   return false;
    // }

    // if (resp.isEmpty) {
    //   _hasMore = false;
    //   log("[TagListPage] request empty");
    //   return true; // 请求成功，但没更多了
    // } else {
    //   pageNum+=20;
    // }

    // final int minIndex =
    //     items.length -
    //     resp.length; //必须要先求n,因为resp.replies是动态删除的,长度会变
    // for (var i = items.length - 1; i >= minIndex; i--) {
    //   if (i < 0) break;
    //   resp.removeWhere((element) {
    //     if (element.id == items[i].id) {
    //       log('same${resp.length}');
    //       return true;
    //     } else {
    //       return false;
    //     }
    //   });
    // }
    // items.addAll(resp);

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
