/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/utils/log_util.dart';

class UserGroupController extends GetxController {
  final RxBool isInitialLoading = true.obs;
  final RxBool isCriteriaLoading = false.obs;
  final RxList<UserInfo> users = <UserInfo>[].obs;
  final RxString searchText = ''.obs;
  final RxnString selectedGroup = RxnString();
  final Rx<UserSort> sort = UserSort.username.obs;
  final ScrollController scrollController = ScrollController();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  static const int _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;

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

  List<String> get availableGroups {
    final result = <String>{};
    for (final user in users) {
      final groups = user.groups?.list ?? const [];
      for (final group in groups) {
        final name = group.name.trim();
        if (name.isNotEmpty) {
          result.add(name);
        }
      }
    }
    final list = result.toList();
    list.sort();
    return list;
  }

  List<UserInfo> get filteredUsers {
    final keyword = searchText.value.trim().toLowerCase();
    final group = selectedGroup.value;
    return users.where((user) {
      if (keyword.isNotEmpty) {
        final hit =
            user.displayName.toLowerCase().contains(keyword) ||
            user.username.toLowerCase().contains(keyword);
        if (!hit) {
          return false;
        }
      }

      if (group != null && group.isNotEmpty) {
        final names = user.groups?.list.map((e) => e.name).toList() ?? const [];
        if (!names.contains(group)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    onRefresh(useSkeleton: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onRefresh({bool useSkeleton = false}) async {
    if (_loading) {
      _finishRefreshSafe(IndicatorResult.fail);
      return;
    }
    _loading = true;
    if (useSkeleton) {
      isCriteriaLoading.value = true;
    }
    try {
      _offset = 0;
      _hasMore = true;
      final data = await Api.getUserDirectory(
        limit: _pageSize,
        offset: _offset,
        sort: sort.value,
      );
      if (data != null) {
        users.assignAll(data);
        _hasMore = data.length >= _pageSize;
        _offset = data.length;
      }
      _finishRefreshSafe(IndicatorResult.success);
      _finishLoadSafe(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[UserGroupPage] refresh users failed', e, s);
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
      final data = await Api.getUserDirectory(
        limit: _pageSize,
        offset: _offset,
        sort: sort.value,
      );
      final next = data ?? const <UserInfo>[];
      if (next.isNotEmpty) {
        users.addAll(next);
        _offset += next.length;
      }
      _hasMore = next.length >= _pageSize;
      _finishLoadSafe(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE('[UserGroupPage] load more users failed', e, s);
      _finishLoadSafe(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
  }

  void updateGroup(String? value) {
    selectedGroup.value = value;
    reloadForCriteriaChange();
  }

  Future<void> updateSort(UserSort value) async {
    sort.value = value;
    await reloadForCriteriaChange();
  }

  Future<void> reloadForCriteriaChange() async {
    isCriteriaLoading.value = true;
    await Future<void>.delayed(Duration.zero);
    if (!isClosed) {
      users.clear();
      await onRefresh(useSkeleton: true);
    }
  }
}
