/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UserPageController extends GetxController {
  UserPageController({required this.userId});
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  CacheManager cacheManager = CacheUtils.avatarCacheManager;
  final int userId;
  int currentPage = 1;
  // List<UserVideoItem> searchItems = [];

  Future<bool> loadVideoItemWidgtLists() async {
    // late UserVideoSearch userVideoSearch;
    // try {
    //   userVideoSearch =
    //       await UserApi.getUserVideoSearch(userId: userId, pageNum: currentPage);
    // } catch (e) {
    //   log("loadVideoItemWidgtLists:$e");
    //   return false;
    // }
    // searchItems.addAll(userVideoSearch.videos);
    // currentPage++;
    return true;
  }

  Future<void> onLoad() async {
    if (await loadVideoItemWidgtLists()) {
      refreshController.finishLoad(IndicatorResult.success);
      refreshController.resetFooter();
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> onRefresh() async {
    await cacheManager.emptyCache();
    // searchItems.clear();
    currentPage = 1;
    bool success = await loadVideoItemWidgtLists();
    if (success) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }
}
