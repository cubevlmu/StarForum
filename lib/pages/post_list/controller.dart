/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:get/get.dart';

class PostListController extends GetxController {
  final DiscussionRepository repo = getIt<DiscussionRepository>();

  final RxList<DiscussionItem> items = <DiscussionItem>[].obs;
  final RxBool onLoading = true.obs;

  final ScrollController scrollController = ScrollController();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final int _pageSize = 20;
  final RxInt _visibleCount = 20.obs;

  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;

  late final Worker _worker;
  StreamSubscription<List<DiscussionItem>>? _sub;

  @override
  void onInit() {
    super.onInit();

    _worker = ever<int>(_visibleCount, (limit) {
      _sub?.cancel();
      _sub = repo.watchDiscussionItems(limit: limit).listen(items.assignAll);
    });

    _visibleCount.value = _visibleCount.value;
    _restorePagingState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshController.callRefresh();
    });
  }

  Future<void> _restorePagingState() async {
    final count = await repo.getDiscussionCount();

    if (count > 0) {
      _offset = count;
      _visibleCount.value = _pageSize;
      _hasMore = true;
    }
  }

  @override
  void onClose() {
    _worker.dispose();
    _sub?.cancel();
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    if (_loading) {
      LogUtil.debug("[PostList] Is loading...");
      refreshController.finishRefresh(.fail);
      return;
    }

    try {
      _loading = true;
      _offset = 0;
      _hasMore = true;

      _visibleCount.value = _pageSize;

      await repo.syncDiscussionPage(offset: 0, limit: _pageSize);
      await repo.cleanupDeletedDiscussions();

      _offset = _pageSize;

      refreshController.finishRefresh(IndicatorResult.success);
    } catch (e, s) {
      LogUtil.errorE('[PostList] refresh failed', e, s);
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      _loading = false;
      refreshController.finishLoad(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    }
  }

  Future<void> onLoad() async {
    if (_loading) {
      LogUtil.debug("[PostList] Is loading...");
      refreshController.finishLoad(.fail);
      return;
    }

    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    _loading = true;

    try {
      _hasMore = await repo.syncDiscussionPage(
        offset: _offset,
        limit: _pageSize,
      );

      _offset += _pageSize;
      _visibleCount.value += _pageSize;

      refreshController.finishLoad(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[PostList] load failed', e, s);
      refreshController.finishLoad(IndicatorResult.fail);
    } finally {
      _loading = false;
    }
  }

  void animateToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
