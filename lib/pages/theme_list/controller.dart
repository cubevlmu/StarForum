import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussions.dart';
import 'package:forum/data/model/tags.dart';
import 'package:forum/data/repository/tag_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

class ThemeListController extends GetxController {
  ThemeListController();
  final repo = getIt<TagRepo>();

  final RxInt selectId = 0.obs;
  final RxBool onLoading = false.obs;
  final RxList<TagInfo> primayTag = <TagInfo>[].obs;
  final RxList<TagInfo> tags = <TagInfo>[].obs;
  final RxList<DiscussionInfo> searchItems = <DiscussionInfo>[].obs;

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  int refreshIdx = 0;
  CacheManager cacheManager = CacheUtils.avatarCacheManager;

  static const int pageSize = 20;
  int offset = 0;
  bool _hasMore = true;
  RxBool isSearching = false.obs;

  @override
  void onInit() {
    primayTag.addAll(repo.getPrimaryTags());
    tags.addAll(repo.getTags());

    super.onInit();
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
        LogUtil.error("[ThemePage] Empty tag info.");
        SnackbarUtils.showMessage("请选择一个标签.");
        return false;
      }

      final data = await Api.getDiscussByTag(
        tag: r.slug,
        offset: offset,
        limit: pageSize,
      );

      if (data == null) {
        LogUtil.error("[ThemePage] empty response");
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
      LogUtil.errorE("[ThemePage] load error", e, s);
      return false;
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> onRefresh() async {
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
  }

  Future<void> onLoad() async {
    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    final ok = await _loadThemeList();

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

  void onTagSelectChange(int id) async {
    if (onLoading.value) return;
    onLoading.value = true;
    selectId.value = id;
    await onRefresh();
    onLoading.value = false;
  }
}
