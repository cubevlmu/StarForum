/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart';

class SearchResultController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SearchResultController({required this.keyWord});

  final String keyWord;
  RxString emojiText = "🔍".obs;
  final DiscussionRepository discussionRepo = getIt<DiscussionRepository>();

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
  final CancelToken _cancelToken = CancelToken();

  Future<bool> _loadSearchResult() async {
    if (!_hasMore) return true;
    isSearching.value = true;

    try {
      final result = await discussionRepo.searchDiscuss(
        key: keyWord,
        offset: offset,
        limit: pageSize,
        cancelToken: _cancelToken,
      );

      if (result.isFailure) {
        if (result.error?.type == RepoErrorType.cancelled) return false;
        LogUtil.error("[SearchResult] empty response");
        return false;
      }

      final list = result.data ?? const <DiscussionInfo>[];

      if (list.isEmpty) {
        _hasMore = false;
        return true;
      }

      searchItems.addAll(list);
      offset += list.length;

      _hasMore = result.hasMore;

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

  @override
  void onClose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('Search result closed.');
    }
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
