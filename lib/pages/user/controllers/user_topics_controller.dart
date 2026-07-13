import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/pages/user/controllers/user_profile_controller.dart';
import 'package:star_forum/utils/log_util.dart';

class UserTopicsController {
  UserTopicsController({required this.profileController});

  static const pageSize = 20;
  final UserProfileController profileController;
  final DiscussionRepository discussionRepository =
      getIt<DiscussionRepository>();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final ScrollController scrollController = ScrollController();
  final RxList<DiscussionSummary> items = <DiscussionSummary>[].obs;
  final RxBool isLoading = false.obs;
  final CancelToken _cancelToken = CancelToken();
  int _offset = 0;
  bool _hasMore = true;
  bool _syncing = false;
  bool _initialized = false;
  bool _disposed = false;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized || isLoading.value) return;
    await _restoreCached();
    await refresh();
  }

  Future<bool> _load() async {
    if (!_hasMore) return true;
    if (_syncing) return false;
    _syncing = true;
    await profileController.load();
    final username = profileController.info?.username ?? '';
    if (username.isEmpty) {
      _syncing = false;
      return false;
    }
    try {
      final result = await discussionRepository.getAuthorThemes(
        username: username,
        offset: _offset,
        limit: pageSize,
        cancelToken: _cancelToken,
      );
      if (result.isFailure) return false;
      final next = result.data ?? const <DiscussionSummary>[];
      if (next.isEmpty) {
        _hasMore = false;
        return true;
      }
      items.addAll(next);
      _offset += next.length;
      _hasMore = result.hasMore;
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE('[UserTopicsController] load failed', error, stackTrace);
      return false;
    } finally {
      _syncing = false;
    }
  }

  Future<void> refresh() async {
    isLoading.value = true;
    _offset = 0;
    _hasMore = true;
    items.clear();
    final ok = await _load();
    if (ok) {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
    _initialized = true;
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (items.isEmpty) isLoading.value = true;
    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      isLoading.value = false;
      return;
    }
    final ok = await _load();
    refreshController.finishLoad(
      !ok
          ? IndicatorResult.fail
          : _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore,
    );
    isLoading.value = false;
  }

  Future<void> _restoreCached() async {
    await profileController.load();
    final username = profileController.info?.username ?? '';
    if (username.isEmpty) return;
    final cached = await discussionRepository.getCachedAuthorThemes(
      username: username,
      offset: 0,
      limit: pageSize,
    );
    if (cached.isEmpty || _disposed) return;
    items.assignAll(cached);
    _offset = cached.length;
    _hasMore = cached.length >= pageSize;
    isLoading.value = false;
  }

  void dispose() {
    _disposed = true;
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('User topics closed.');
    }
    scrollController.dispose();
    refreshController.dispose();
  }
}
