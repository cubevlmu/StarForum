/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/repository/discussion_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/post_detail/reply_util.dart';
import 'package:get/get.dart';

enum ReplySort { like, time }

class PostPageController extends GetxController {
  PostPageController({required this.postId, required});

  final String postId;

  /// ===== 状态 =====
  final RxInt replyCount = 0.obs;
  final RxString sortTypeText = "按热度".obs;
  final RxString content = "".obs;

  final List<PostInfo> replyItems = [];
  final List<PostInfo> newReplyItems = [];

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final repo = getIt<DiscussionRepository>();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    content.value = await repo.getCachedFirstPostContent(postId) ?? "<p>[Error:03]</p>";
    super.onInit();
  }

  /// ===== 分页 =====
  static const int _pageSize = 20;
  int _offset = 1;
  bool _hasMore = true;
  bool _loading = false;

  /// ===== 排序 =====
  ReplySort _replySort = ReplySort.like;

  Function()? updateWidget;

  /// ================= 排序切换 =================
  void toggleSort() {
    if (_replySort == ReplySort.like) {
      _replySort = ReplySort.time;
      sortTypeText.value = "按时间";
    } else {
      _replySort = ReplySort.like;
      sortTypeText.value = "按热度";
    }
    onReplyRefresh();
  }

  /// ================= 刷新 =================
  Future<void> onReplyRefresh() async {
    if (_loading) return;

    _offset = 1;
    _hasMore = true;
    replyItems.clear();
    newReplyItems.clear();

    final ok = await _loadReplies(reset: true);

    refreshController.finishRefresh(
      ok ? IndicatorResult.success : IndicatorResult.fail,
    );

    updateWidget?.call();
  }

  /// ================= 加载更多 =================
  Future<void> onReplyLoad() async {
    if (_loading) return;

    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    final ok = await _loadReplies();

    if (!ok) {
      refreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    refreshController.finishLoad(
      _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
    );

    updateWidget?.call();
  }

  /// ================= 核心加载逻辑 =================
  Future<bool> _loadReplies({bool reset = false}) async {
    try {
      _loading = true;

      final Posts? r = await Api.getPosts(
        discussionId: postId,
        offset: _offset,
        limit: _pageSize,
        sort: _replySort == ReplySort.like ? PostSort.number : PostSort.time,
      );

      if (r == null) {
        log("[PostDetailPage] Response data is empty, maybe no more posts in this discussion");
        return false;
      }

      final List<PostInfo> list = r.posts.values.toList();
      for (var item in list) {
        item.user = r.users[item.userId];
      }

      if (reset) {
        replyItems.clear();
      }

      if (list.isEmpty) {
        _hasMore = false;
        return true;
      }

      // 去重（防 API 返回重叠）
      final existingIds = replyItems.map((e) => e.id).toSet();
      final filtered = list.where((e) => !existingIds.contains(e.id)).toList();

      replyItems.addAll(filtered);
      replyCount.value = replyItems.length;

      _offset += list.length;

      // 少于 pageSize 说明没了
      if (list.length < _pageSize) {
        _hasMore = false;
      }

      return true;
    } catch (e) {
      log("加载评论失败: $e");
      return false;
    } finally {
      _loading = false;
    }
  }

  /// ================= 发表评论 =================
  Future<void> showAddReplySheet() async {
    // 你原来的逻辑可以直接搬进来
    await ReplyUtil.showAddReplySheet(
        discussionId: postId,
        newReplyItems: newReplyItems,
        updateWidget: updateWidget,
        scrollController: scrollController);
  }

  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  String getId() { return postId; }
}
