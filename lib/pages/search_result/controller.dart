/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussions.dart';
import 'package:get/get.dart';

class SearchResultController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SearchResultController({required this.keyWord});

  final String keyWord;

  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  ScrollController scrollController = ScrollController();

  final List<DiscussionInfo> searchItems = [];

  static const int pageSize = 20;
  int offset = 0;
  bool _hasMore = true;
  
  Future<bool> _loadSearchResult() async {
    if (!_hasMore) return true;

    try {
      final data = await Api.searchDiscuss(
        key: keyWord,
        offset: offset,
        limit: pageSize,
      );

      if (data == null) {
        log("[SearchResult] empty response");
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
    } catch (e) {
      log("[SearchResult] load error: $e");
      return false;
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
