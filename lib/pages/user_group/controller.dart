/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/group_info.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/utils/log_util.dart';

class UserGroupController extends GetxController {
  final RxBool isInitialLoading = true.obs;
  final RxBool isCriteriaLoading = false.obs;
  final RxList<UserInfo> users = <UserInfo>[].obs;
  final RxList<GroupInfo> groups = <GroupInfo>[].obs;
  final RxString searchText = ''.obs;
  final RxnInt selectedGroupId = RxnInt();
  final Rx<UserDirectorySort> sort = UserDirectorySort.username.obs;
  final userRepo = getIt<UserRepo>();
  final ScrollController scrollController = ScrollController();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  static const int _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;
  Timer? _refreshTimer;

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

  List<GroupInfo> get availableGroups {
    final result = <int, GroupInfo>{
      for (final group in groups) group.id: group,
    };
    for (final user in users) {
      final userGroups = user.groups?.list ?? const <GroupInfo>[];
      for (final group in userGroups) {
        if (group.id > 0 && group.name.trim().isNotEmpty) {
          result[group.id] = group;
        }
      }
    }
    final list = result.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  List<UserInfo> get filteredUsers {
    final keyword = searchText.value.trim().toLowerCase();
    return users.where((user) {
      if (keyword.isNotEmpty) {
        final hit =
            user.displayName.toLowerCase().contains(keyword) ||
            user.username.toLowerCase().contains(keyword);
        if (!hit) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(_loadGroups());
    _restoreCachedUsers();
    onRefresh(useSkeleton: true);
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (!_loading && !isClosed) unawaited(onRefresh());
    });
  }

  Future<void> _loadGroups({bool force = false}) async {
    final result = await userRepo.getUserGroups(force: force);
    final data = result.data;
    if (data == null || isClosed) return;
    groups.assignAll(data.where((group) => group.id > 0));
  }

  Future<void> _restoreCachedUsers() async {
    final cached = await userRepo.getCachedUserDirectory(
      limit: _pageSize,
      sort: sort.value,
      groupId: selectedGroupId.value,
    );
    if (cached.isEmpty || isClosed) return;
    users.assignAll(cached);
    _offset = cached.length;
    isInitialLoading.value = false;
    isCriteriaLoading.value = false;
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
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
      final result = await userRepo.getUserDirectory(
        limit: _pageSize,
        offset: _offset,
        sort: sort.value,
        groupId: selectedGroupId.value,
      );
      if (result.isFailure) {
        _finishRefreshSafe(IndicatorResult.fail);
        return;
      }
      final data = result.data ?? const <UserInfo>[];
      users.assignAll(data);
      _hasMore = result.hasMore;
      _offset = data.length;
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
      final result = await userRepo.getUserDirectory(
        limit: _pageSize,
        offset: _offset,
        sort: sort.value,
        groupId: selectedGroupId.value,
      );
      if (result.isFailure) {
        _finishLoadSafe(IndicatorResult.fail);
        return;
      }
      final next = result.data ?? const <UserInfo>[];
      if (next.isNotEmpty) {
        users.addAll(next);
        _offset += next.length;
      }
      _hasMore = result.hasMore;
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

  Future<void> updateGroup(int? value) async {
    if (selectedGroupId.value == value) return;
    selectedGroupId.value = value;
    await reloadForCriteriaChange();
  }

  Future<void> updateSort(UserDirectorySort value) async {
    sort.value = value;
    await reloadForCriteriaChange();
  }

  Future<void> reloadForCriteriaChange() async {
    isCriteriaLoading.value = true;
    await Future<void>.delayed(Duration.zero);
    if (!isClosed) {
      users.clear();
      if (scrollController.hasClients) scrollController.jumpTo(0);
      await _restoreCachedUsers();
      await onRefresh(useSkeleton: true);
    }
  }
}
