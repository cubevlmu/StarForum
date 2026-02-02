/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/repository/discussion_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/post_detail/reply_util.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

enum ReplySort { like, time }

class PostPageController extends GetxController {
  PostPageController({required this.discussion, required});

  final DiscussionItem discussion;

  final RxInt replyCount = 0.obs;
  final RxString sortTypeText = "按热度".obs;
  final RxString content = "<p>加载中...</p>".obs;

  final RxList<PostInfo> replyItems = <PostInfo>[].obs;
  final RxList<PostInfo> newReplyItems = <PostInfo>[].obs;

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final repo = getIt<DiscussionRepository>();
  final ScrollController scrollController = ScrollController();
  final Rxn<PostInfo> firstPost = Rxn<PostInfo>();

  @override
  void onInit() async {
    try {
      final r = await Api.getFirstPost(discussion.id);
      if (r == null) {
        LogUtil.error(
          "[PostDetail] Failed to fetch post content (content is null).",
        );
        content.value = "<p>内容无法获取到...可能是网络问题</p>";
        SnackbarUtils.showMessage("无法获取到贴文内容");
        return;
      }
      firstPost.value = r;
      content.value = r.contentHtml;
    } catch (e, s) {
      LogUtil.errorE(
        "[PostDetail] Failed to fetch post content with error.",
        e,
        s,
      );
    }
    super.onInit();
  }

  static const int _pageSize = 10;
  int _offset = 1;
  bool _hasMore = true;
  bool _loading = false;

  ReplySort _replySort = ReplySort.like;

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

    refreshController.finishLoad(
      _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
    );
  }

  Future<void> onReplyLoad() async {
    if (_loading) {
      refreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    final ok = await _loadReplies();

    refreshController.finishLoad(
      ok
          ? (_hasMore ? IndicatorResult.success : IndicatorResult.noMore)
          : IndicatorResult.fail,
    );
  }

  Future<bool> _loadReplies({bool reset = false}) async {
    try {
      _loading = true;

      final Posts? r = await Api.getPosts(
        discussionId: discussion.id,
        offset: _offset,
        limit: _pageSize,
        sort: _replySort == ReplySort.like ? PostSort.number : PostSort.time,
      );

      if (r == null) {
        LogUtil.error(
          "[PostDetailPage] Response data is empty, maybe no more posts in this discussion",
        );
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

      final existingIds = replyItems.map((e) => e.id).toSet();
      final filtered = list.where((e) => !existingIds.contains(e.id)).toList();

      replyItems.addAll(filtered);
      replyCount.value = replyItems.length;

      _offset += list.length;

      if (list.length < _pageSize) {
        _hasMore = false;
      }

      return true;
    } catch (e, s) {
      LogUtil.errorE("[PostPage] Failed to load replies.", e, s);
      return false;
    } finally {
      _loading = false;
    }
  }

  Future<void> showAddReplySheet() async {
    await ReplyUtil.showAddReplySheet(
      discussionId: discussion.id,
      newReplyItems: newReplyItems,
      updateWidget: () {},
      scrollController: scrollController,
    );
  }

  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  String getId() {
    return discussion.id;
  }
}
