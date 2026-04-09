import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

class TagListController extends GetxController {
  TagListController();
  final repo = getIt<TagRepo>();

  final RxInt selectId = 0.obs;
  final RxBool onLoading = true.obs;
  final RxBool isInitialLoading = true.obs;
  final RxList<TagInfo> primayTag = <TagInfo>[].obs;
  final RxList<TagInfo> tags = <TagInfo>[].obs;
  final RxList<DiscussionInfo> searchItems = <DiscussionInfo>[].obs;

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  int refreshIdx = 0;
  final cacheManager = CacheUtils.avatarCacheManager;

  static const int pageSize = 20;
  int offset = 0;
  bool _hasMore = true;
  RxBool isSearching = false.obs;
  bool _hasLoaded = false;

  @override
  void onInit() {
    _reloadTagCache();
    onLoading.value = false;
    isInitialLoading.value = false;
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  void _reloadTagCache() {
    final previousSelectedId = selectId.value;
    final primary = repo.getPrimaryTags();
    final secondary = repo.getTags();

    primayTag.assignAll(primary);
    tags.assignAll(secondary);

    if (primary.isEmpty) {
      selectId.value = 0;
      return;
    }

    final stillExists = primary.any((tag) => tag.id == previousSelectedId);
    selectId.value = stillExists ? previousSelectedId : primary.first.id;
  }

  Future<void> ensureLoaded() async {
    if (_hasLoaded || onLoading.value || selectId.value == 0) {
      return;
    }
    onLoading.value = true;
    isInitialLoading.value = true;
    try {
      await onRefresh();
      _hasLoaded = true;
    } finally {
      onLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  void animateToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  Future<bool> _loadThemeList() async {
    if (!_hasMore) return true;
    isSearching.value = true;

    try {
      final r = repo.getTagById(selectId.value);
      if (r == null) {
        LogUtil.error("[TagPage] Empty tag info.");
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.themeSelectTagHint,
        );
        return false;
      }

      final data = await Api.getDiscussByTag(
        tag: r.slug,
        offset: offset,
        limit: pageSize,
      );

      if (data == null) {
        LogUtil.error("[TagPage] empty response");
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
      LogUtil.errorE("[TagPage] load error", e, s);
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

    final ok = await _loadThemeList();

    if (ok) {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
    isInitialLoading.value = false;
    _hasLoaded = true;
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

    final ok = await _loadThemeList();

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

  Future<void> reloadTags() async {
    _reloadTagCache();
    searchItems.clear();
    offset = 0;
    _hasMore = true;
    _hasLoaded = false;
    refreshController.resetFooter();

    if (selectId.value == 0) {
      onLoading.value = false;
      isInitialLoading.value = false;
      return;
    }

    onLoading.value = true;
    try {
      await onRefresh();
    } finally {
      onLoading.value = false;
    }
  }

  void onTagSelectChange(int id) async {
    if (onLoading.value) return;
    onLoading.value = true;
    selectId.value = id;
    await onRefresh();
    onLoading.value = false;
  }
}
