/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/sync/sync_status.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:get/get.dart';

class PostListController extends GetxController {
  final DiscussionRepository repo = getIt<DiscussionRepository>();
  final SyncStatusService syncStatus = getIt<SyncStatusService>();

  final RxList<DiscussionSummary> items = <DiscussionSummary>[].obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isInitialSyncing = false.obs;
  final RxBool showBackToTop = false.obs;

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
  StreamSubscription<List<DiscussionSummary>>? _sub;
  int _watchGeneration = 0;
  final CancelToken _cancelToken = CancelToken();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    SettingsUtil.keepStickyDiscussionsOnTopListenable.addListener(
      _handleStickyOrderingChanged,
    );

    _worker = ever<int>(_visibleCount, _watchItems);
    _watchItems(_visibleCount.value);
    _restorePagingState();
  }

  void _watchItems(int limit) {
    final generation = ++_watchGeneration;
    unawaited(_sub?.cancel());
    _sub = repo.watchDiscussionSummaries(limit: limit).listen((cachedItems) {
      if (generation != _watchGeneration) return;
      if (_sameItems(items, cachedItems)) {
        if (cachedItems.isNotEmpty) {
          isInitialLoading.value = false;
        }
        return;
      }
      items.assignAll(cachedItems);
      if (cachedItems.isNotEmpty) {
        isInitialLoading.value = false;
      }
    });
  }

  bool _sameItems(
    List<DiscussionSummary> current,
    List<DiscussionSummary> next,
  ) {
    if (current.length != next.length) return false;
    for (var i = 0; i < current.length; i += 1) {
      if (current[i] != next[i]) return false;
    }
    return true;
  }

  Future<void> _restorePagingState() async {
    final count = await repo.getDiscussionCount();

    if (count > 0) {
      _offset = count;
      _visibleCount.value = _pageSize;
      _hasMore = true;
      isInitialLoading.value = false;
    }
  }

  @override
  void onClose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('Post list closed.');
    }
    _worker.dispose();
    _sub?.cancel();
    scrollController.removeListener(_handleScroll);
    SettingsUtil.keepStickyDiscussionsOnTopListenable.removeListener(
      _handleStickyOrderingChanged,
    );
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    if (isInitialSyncing.value) return;
    await _refresh(force: true);
  }

  void prepareInitialSync() {
    if (!_loading) isInitialSyncing.value = true;
  }

  Future<void> loadInitial() async {
    if (_loading) return;
    isInitialSyncing.value = true;
    try {
      await _refresh(force: false);
    } finally {
      isInitialSyncing.value = false;
    }
  }

  Future<void> _refresh({required bool force}) async {
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

      final result = await repo.syncDiscussionPage(
        offset: 0,
        limit: _pageSize,
        cancelToken: _cancelToken,
        force: force,
      );
      if (result.isFailure) {
        refreshController.finishRefresh(IndicatorResult.fail);
        return;
      }
      unawaited(
        repo.cleanupDeletedDiscussions().catchError((Object e, StackTrace s) {
          LogUtil.errorE('[PostList] cleanup deleted discussions failed', e, s);
        }),
      );

      _offset = _pageSize;

      _hasMore = result.data ?? true;
      refreshController.finishRefresh(IndicatorResult.success);
    } catch (e, s) {
      LogUtil.errorE('[PostList] refresh failed', e, s);
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
      refreshController.finishLoad(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    }
  }

  Future<void> onLoad() async {
    if (_loading) {
      LogUtil.debug("[PostList] Is loading...");
      refreshController.finishLoad(.fail);
      isInitialLoading.value = false;
      return;
    }

    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      isInitialLoading.value = false;
      return;
    }
    _loading = true;

    try {
      final result = await repo.syncDiscussionPage(
        offset: _offset,
        limit: _pageSize,
        cancelToken: _cancelToken,
        reportStatus: false,
      );
      if (result.isFailure) {
        refreshController.finishLoad(IndicatorResult.fail);
        return;
      }
      _hasMore = result.data ?? false;

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
      isInitialLoading.value = false;
    }
  }

  void animateToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    final next = scrollController.offset >= 900;
    if (showBackToTop.value != next) showBackToTop.value = next;
  }

  void _handleStickyOrderingChanged() {
    _watchItems(_visibleCount.value);
  }
}
