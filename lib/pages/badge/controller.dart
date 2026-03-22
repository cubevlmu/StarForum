/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:get/get.dart';

class BadgeController extends GetxController {
  final RxList<BadgeCategory> categories = <BadgeCategory>[].obs;
  final RxBool isLoading = true.obs;
  bool _hasLoaded = false;
  bool _isRefreshing = false;
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  bool get hasLoaded => _hasLoaded;

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isRefreshing) {
      return;
    }
    await _load(notifyRefresher: false);
  }

  @override
  Future<void> refresh() async {
    await _load(notifyRefresher: true);
  }

  Future<void> _load({required bool notifyRefresher}) async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    isLoading.value = true;
    try {
      final result = await Api.getBadgeCategories();
      categories.assignAll(result?.list ?? const <BadgeCategory>[]);
      _hasLoaded = true;
      if (notifyRefresher) {
        refreshController.finishRefresh(IndicatorResult.success);
      }
    } catch (_) {
      if (notifyRefresher) {
        refreshController.finishRefresh(IndicatorResult.fail);
      }
      rethrow;
    } finally {
      _isRefreshing = false;
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
