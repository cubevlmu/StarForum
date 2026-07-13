import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';

class TagListController extends GetxController {
  final repo = getIt<TagRepo>();
  final tags = <TagInfo>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    reloadTags();
  }

  Future<void> reloadTags() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      if (!repo.isReady) await repo.syncTags();
      tags.assignAll(repo.getAllTagsForDirectory());
    } finally {
      isLoading.value = false;
    }
  }
}

class TagDetailController extends GetxController {
  TagDetailController(this.tag);

  final TagInfo tag;
  final discussionRepo = getIt<DiscussionRepository>();
  final items = <DiscussionSummary>[].obs;
  final isInitialLoading = true.obs;
  final isLoadingMore = false.obs;
  final scrollController = ScrollController();
  final refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  static const pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;

  @override
  void onReady() {
    super.onReady();
    loadInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<bool> _load({bool force = false}) async {
    try {
      final result = await discussionRepo.getDiscussByTag(
        tag: tag.slug,
        offset: _offset,
        limit: pageSize,
        force: force,
      );
      if (result.isFailure) return false;
      final next = result.data ?? const <DiscussionSummary>[];
      items.addAll(next);
      _offset += next.length;
      _hasMore = result.hasMore && next.isNotEmpty;
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[TagDetail] Failed to load ${tag.slug}',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> onRefresh() async {
    await _refresh(force: true);
  }

  Future<void> loadInitial() async {
    await _refresh(force: false);
  }

  Future<void> _refresh({required bool force}) async {
    isInitialLoading.value = true;
    _offset = 0;
    _hasMore = true;
    items.clear();
    final ok = await _load(force: force);
    if (ok) {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
    isInitialLoading.value = false;
  }

  Future<void> onLoad() async {
    if (!_hasMore || isLoadingMore.value) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    isLoadingMore.value = true;
    final ok = await _load();
    if (!ok) {
      refreshController.finishLoad(IndicatorResult.fail);
    } else if (_hasMore) {
      refreshController.finishLoad();
    } else {
      refreshController.finishLoad(IndicatorResult.noMore);
    }
    isLoadingMore.value = false;
  }
}
