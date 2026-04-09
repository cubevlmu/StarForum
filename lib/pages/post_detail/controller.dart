/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

enum ReplySort { like, time }

class PostPageController extends GetxController {
  PostPageController({required this.discussion, required});

  final DiscussionItem discussion;
  final RxInt viewCount = 0.obs;

  final RxInt replyCount = 0.obs;
  final RxString sortTypeText = AppLocalizations.of(
    Get.context!,
  )!.postSortByHot.obs;
  final RxString content = AppLocalizations.of(
    Get.context!,
  )!.postContentLoadingHtml.obs;

  final RxList<PostInfo> replyItems = <PostInfo>[].obs;
  final RxList<PostInfo> newReplyItems = <PostInfo>[].obs;
  final RxBool isReplyLoading = true.obs;
  final RxInt subscription = 0.obs;
  final RxBool isFollowUpdating = false.obs;

  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final repo = getIt<DiscussionRepository>();
  final userRepo = getIt<UserRepo>();
  final ScrollController scrollController = ScrollController();
  final Rxn<PostInfo> firstPost = Rxn<PostInfo>();

  bool get canUseInteractiveActions => userRepo.isLogin;

  @override
  void onInit() async {
    viewCount.value = discussion.viewCount;
    subscription.value = discussion.subscription;
    try {
      final discussionInfo = await Api.getDiscussionById(discussion.id);
      if (discussionInfo != null) {
        viewCount.value = discussionInfo.views;
      }

      final r = await Api.getFirstPost(discussion.id);
      if (r == null) {
        LogUtil.error(
          "[PostDetail] Failed to fetch post content (content is null).",
        );
        final l10n = AppLocalizations.of(Get.context!)!;
        content.value = l10n.postContentUnavailableHtml;
        SnackbarUtils.showMessage(msg: l10n.postContentUnavailable);
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

  Future<bool> toggleDiscussionFollow() async {
    if (isFollowUpdating.value) {
      return false;
    }

    final targetFollow = subscription.value != 1;
    isFollowUpdating.value = true;
    try {
      final ok = await Api.setDiscussionFollow(discussion.id, targetFollow);
      if (!ok) {
        return false;
      }

      final nextValue = targetFollow ? 1 : 0;
      subscription.value = nextValue;
      await repo.updateSubscriptionIfExists(
        discussionId: discussion.id,
        subscription: nextValue,
      );
      return true;
    } finally {
      isFollowUpdating.value = false;
    }
  }

  static const int _pageSize = 10;
  int _offset = 1;
  bool _hasMore = true;
  bool _loading = false;

  ReplySort _replySort = ReplySort.like;

  void toggleSort() {
    if (_replySort == ReplySort.like) {
      _replySort = ReplySort.time;
      sortTypeText.value = AppLocalizations.of(Get.context!)!.postSortByTime;
    } else {
      _replySort = ReplySort.like;
      sortTypeText.value = AppLocalizations.of(Get.context!)!.postSortByHot;
    }
    onReplyRefresh();
  }

  Future<void> onReplyRefresh() async {
    if (_loading) return;

    isReplyLoading.value = true;
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
    isReplyLoading.value = false;
  }

  Future<void> onReplyLoad() async {
    if (replyItems.isEmpty && newReplyItems.isEmpty) {
      isReplyLoading.value = true;
    }

    if (_loading) {
      refreshController.finishLoad(IndicatorResult.fail);
      isReplyLoading.value = false;
      return;
    }

    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      isReplyLoading.value = false;
      return;
    }

    final ok = await _loadReplies();

    refreshController.finishLoad(
      ok
          ? (_hasMore ? IndicatorResult.success : IndicatorResult.noMore)
          : IndicatorResult.fail,
    );
    isReplyLoading.value = false;
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

  Future<void> showAddReplySheet(BuildContext context) async {
    await ReplyUtil.showAddReplySheet(
      context: context,
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
