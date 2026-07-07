import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';

class SubscriptionController extends GetxController {
  final RxList<DiscussionInfo> items = <DiscussionInfo>[].obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isCriteriaLoading = false.obs;
  final Rx<DiscussionFollowingSort> sort = DiscussionFollowingSort.hottest.obs;
  final discussionRepo = getIt<DiscussionRepository>();

  final ScrollController scrollController = ScrollController();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  static const int _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;

  @override
  void onInit() {
    super.onInit();
    _restoreCachedItems();
    onRefresh();
  }

  Future<void> _restoreCachedItems() async {
    final cached = await discussionRepo.getCachedFollowingDiscussionList(
      sort: sort.value,
      limit: _pageSize,
    );
    if (cached.isEmpty || isClosed) return;
    items.assignAll(cached);
    _offset = cached.length;
    isInitialLoading.value = false;
  }

  void _finishRefreshSafe(IndicatorResult result) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        refreshController.finishRefresh(result);
      }
    });
  }

  void _finishLoadSafe(IndicatorResult result) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        refreshController.finishLoad(result);
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    await _refreshWithSort(sort.value);
  }

  Future<void> _refreshWithSort(DiscussionFollowingSort currentSort) async {
    if (_loading) {
      _finishRefreshSafe(IndicatorResult.fail);
      return;
    }

    _loading = true;
    try {
      _offset = 0;
      _hasMore = true;

      final paged = await discussionRepo.getFollowingDiscussionList(
        sort: currentSort,
        offset: 0,
        limit: _pageSize,
      );
      if (paged.isFailure) {
        _finishRefreshSafe(IndicatorResult.fail);
        return;
      }
      final list = paged.data ?? const <DiscussionInfo>[];

      items.assignAll(list);
      _offset = list.length;
      _hasMore = paged.hasMore;

      _finishRefreshSafe(IndicatorResult.success);
      _finishLoadSafe(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[SubscriptionPage] refresh failed', e, s);
      _finishRefreshSafe(IndicatorResult.fail);
    } finally {
      _loading = false;
      isCriteriaLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> onLoad() async {
    if (_loading) {
      _finishLoadSafe(IndicatorResult.fail);
      return;
    }
    if (!_hasMore) {
      _finishLoadSafe(IndicatorResult.noMore);
      return;
    }

    _loading = true;
    try {
      final paged = await discussionRepo.getFollowingDiscussionList(
        sort: sort.value,
        offset: _offset,
        limit: _pageSize,
      );
      if (paged.isFailure) {
        _finishLoadSafe(IndicatorResult.fail);
        return;
      }
      final next = paged.data ?? const <DiscussionInfo>[];

      if (next.isNotEmpty) {
        items.addAll(next);
        _offset += next.length;
      }
      _hasMore = paged.hasMore;

      _finishLoadSafe(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[SubscriptionPage] load failed', e, s);
      _finishLoadSafe(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> updateSort(DiscussionFollowingSort value) async {
    if (sort.value == value && items.isNotEmpty) return;
    sort.value = value;
    isCriteriaLoading.value = true;
    await Future<void>.delayed(Duration.zero);
    if (!isClosed) {
      items.clear();
      await _restoreCachedItems();
      await _refreshWithSort(value);
    }
  }
}
