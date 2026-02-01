/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */



import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussions.dart';
import 'package:forum/main.dart';
import 'package:forum/utils/log_util.dart';
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

//////////////////////////////////////////////////////////////////////
/// Designed for 海星论坛
  void _updateEmojiByKwd() {
    if (keyWord.contains("鸽子")) {
      emojiText.value = "🕊";
    } else if (keyWord.contains("海星") || keyWord.contains("草方块")) {
      emojiText.value = "⭐";
    } else if (keyWord.contains("土拔鼠")) {
      emojiText.value = "🐁";
    } else {
      if (emojiText.value == "🔍") return;
      emojiText.value = "🔍";
    }
  }
//////////////////////////////////////////////////////////////////////

  Future<bool> _loadSearchResult() async {
    if (!_hasMore) return true;
    isSearching.value = true;

    if (isStarFourmForATC) {
      _updateEmojiByKwd();
    }

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
  }

  Future<void> onLoad() async {
    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    final ok = await _loadSearchResult();

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
