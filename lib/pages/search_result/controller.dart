/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart';

class SearchResultController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SearchResultController({required this.keyWord});

  final String keyWord;
  RxString emojiText = "🔍".obs;

  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  ScrollController scrollController = ScrollController();

  final List<DiscussionInfo> searchItems = [];

  static const int pageSize = 20;
  int offset = 0;
  bool _hasMore = true;
  RxBool isSearching = false.obs;
  RxBool isInitialLoading = true.obs;

  Future<bool> _loadSearchResult() async {
    if (!_hasMore) return true;
    isSearching.value = true;

    try {
      final data = await Api.searchDiscuss(
        key: keyWord,
        offset: offset,
        limit: pageSize,
      );

      if (data == null) {
        LogUtil.error("[SearchResult] empty response");
        return false;
      }

      final list = data.list;

      if (list.isEmpty) {
        _hasMore = false;
        return true;
      }

      searchItems.addAll(list);
      offset += list.length;

      if (list.length < pageSize) {
        _hasMore = false;
      }

      return true;
    } catch (e, s) {
      LogUtil.errorE("[SearchResult] load error", e, s);
      return false;
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> onRefresh() async {
    isInitialLoading.value = true;
    offset = 0;
    _hasMore = true;
    searchItems.clear();

    final ok = await _loadSearchResult();

    if (ok) {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
    isInitialLoading.value = false;
  }

  Future<void> onLoad() async {
    if (searchItems.isEmpty) {
      isInitialLoading.value = true;
    }

    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      isInitialLoading.value = false;
      return;
    }

    final ok = await _loadSearchResult();

    if (!ok) {
      refreshController.finishLoad(IndicatorResult.fail);
      isInitialLoading.value = false;
      return;
    }

    if (_hasMore) {
      refreshController.finishLoad();
    } else {
      refreshController.finishLoad(IndicatorResult.noMore);
    }
    isInitialLoading.value = false;
  }
}
