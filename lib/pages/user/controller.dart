/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/data/model/discussions.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/model/users.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/cache_utils.dart';
import 'package:forum/utils/html_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/utils/string_util.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UserPageController extends GetxController {
  UserPageController({required this.userId});
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  CacheManager cacheManager = CacheUtils.avatarCacheManager;
  ScrollController scrollController = ScrollController();

  final List<PostInfo> items = [];
  final Map<int, DiscussionInfo> dissItems = {};

  static const int pageSize = 20;
  int offset = 0;
  bool _hasMore = true;
  final RxBool isLoading = false.obs;
  bool _isSyncing = false;

  final repo = getIt<UserRepo>();

  final int userId;
  int currentPage = 1;
  UserInfo? info;

  Future<void> loadUserData() async {
    try {
      final r = await Api.getUserInfoByNameOrId(userId.toString());
      if (r == null) {
        LogUtil.error(
          "[UserPage] Get user information with empty response, userId $userId",
        );
        return;
      }

      if (info == null) {
        info = r;
      } else {
        info?.update(r);
      }
    } catch (e, s) {
      LogUtil.errorE(
        "[UserPage] Get user information failed with error: ",
        e,
        s,
      );
    }
  }

  Future<bool> _loadUserPosts() async {
    if (!_hasMore) return true;
    if (_isSyncing) return false;
    _isSyncing = true;

    await loadUserData();
    if (info == null) {
      LogUtil.warn("[UserPage] User info is not prepared.");
      return false;
    }

    try {
      final data = await Api.getPostsByAuthor(
        username: info?.username ?? "",
        offset: offset,
        limit: pageSize,
      );

      if (data == null) {
        LogUtil.warn("[UserPage] empty response");
        return false;
      }

      final list = data.posts.values;

      if (list.isEmpty) {
        _hasMore = false;
        return true;
      }

      for (var i in list) {
        i.user = info;
        final t = htmlToPlainText(i.contentHtml);
        i.contentHtml =
            "<p>${t.substring(0, t.length > 70 ? 70 : t.length)}...</p>";
      }
      items.addAll(list);
      dissItems.addAll(data.discussions);
      offset += list.length;

      if (list.length < pageSize) {
        _hasMore = false;
      }

      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] load error", e, s);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> onRefresh() async {
    offset = 0;
    _hasMore = true;
    items.clear();
    dissItems.clear();

    final ok = await _loadUserPosts();

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

    final ok = await _loadUserPosts();

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

  String getLastSeenAt() {
    if (info == null) {
      return "";
    }
    if (repo.isLogin) {
      if (repo.user?.id == info?.id) return "在线";
    }

    try {
      final date = DateTime.parse(info?.lastSeenAt ?? "");
      return StringUtil.timeStampToAgoDate(date.millisecondsSinceEpoch ~/ 1000);
    } catch (e, s) {
      LogUtil.errorE("[UserPage] Failed to parse last seen at time", e, s);
      return "";
    }
  }

  String getRegisterAt() {
    if (info == null) {
      return "";
    }
    try {
      final date = DateTime.parse(info?.joinTime ?? "");
      return StringUtil.timeStampToAgoDate(date.millisecondsSinceEpoch ~/ 1000);
    } catch (e, s) {
      LogUtil.errorE("[UserPage] Failed to parse last seen at time", e, s);
      return "";
    }
  }

  String buildExpString() {
    if (info == null || info?.expInfo == null) {
      return "";
    }
    final expIfo = info!.expInfo!;

    return "${expIfo.expLevel} · ${expIfo.expTotal} / ${expIfo.expTotal + expIfo.expNextNeed}";
  }

  double getExpPercent() {
    if (info == null || info?.expInfo == null) {
      return 0;
    }
    final expIfo = info!.expInfo!;

    return expIfo.expPercent / 100;
  }

  bool isMe() {
    if (info == null) return false;
    if (!repo.isLogin) return false;
    if (info?.id == repo.user?.id) return true;
    return false;
  }

  Future<DiscussionItem?> naviToDisPage(int discussion) async {
    if (isLoading.value) {
      return null;
    }
    isLoading.value = true;

    try {
      final r = await Api.getDiscussionById(discussion.toString());
      if (r == null) {
        SnackbarUtils.showMessage("获取帖子信息失败");
        return null;
      }
      r.firstPost = r.posts?[r.firstPostId];
      r.firstPost?.user = r.users?.values.first;
      return DiscussionItem(
        id: r.id,
        title: r.title,
        excerpt: r.firstPost?.contentHtml ?? "",
        lastPostedAt: DateTime.parse(r.lastPostedAt),
        authorAvatar: r.firstPost?.user?.avatarUrl ?? "",
        authorName: r.firstPost?.user?.displayName ?? "",
        viewCount: r.views,
        likeCount: r.firstPost?.likes ?? 0,
        commentCount: r.commentCount,
        userId: r.users?.keys.first ?? 0,
      );
    } catch (e, s) {
      LogUtil.errorE(
        "[UserPage] Failed to fetch discussion information with id: $discussion with error:",
        e,
        s,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
