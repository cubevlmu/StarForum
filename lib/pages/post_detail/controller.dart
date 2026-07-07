/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

enum ReplySort { like, time }

class PostPageController extends GetxController {
  PostPageController({required this.discussion});

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
  final discussionRepo = getIt<DiscussionRepository>();
  final postRepo = getIt<PostRepository>();
  final userRepo = getIt<UserRepo>();
  final ScrollController scrollController = ScrollController();
  final Rxn<PostInfo> firstPost = Rxn<PostInfo>();
  final CancelToken _cancelToken = CancelToken();

  bool get canUseInteractiveActions => userRepo.isLogin;

  @override
  void onInit() {
    super.onInit();
    viewCount.value = discussion.viewCount;
    subscription.value = discussion.subscription;
    unawaited(_loadInitialPosts());
    unawaited(_loadMetadata());
  }

  Future<void> _loadInitialPosts() async {
    try {
      isReplyLoading.value = true;
      final result = await postRepo.getInitialPostPage(
        discussionId: discussion.id,
        replyLimit: _pageSize,
        cancelToken: _cancelToken,
      );
      if (result.error?.type == RepoErrorType.cancelled) return;
      final bundle = result.data;
      final r = bundle?.firstPost;
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
      replyItems.assignAll(bundle!.replies);
      replyCount.value = replyItems.length;
      _offset = bundle.replies.length + 1;
      _nextUrl = bundle.nextUrl;
      _hasMore = bundle.hasMore;
    } catch (e, s) {
      LogUtil.errorE(
        "[PostDetail] Failed to fetch post content with error.",
        e,
        s,
      );
    } finally {
      isReplyLoading.value = false;
    }
  }

  Future<void> _loadMetadata() async {
    final result = await discussionRepo.getDiscussionById(
      discussion.id,
      cancelToken: _cancelToken,
    );
    if (result.error?.type == RepoErrorType.cancelled) return;
    final info = result.data;
    if (info == null || isClosed) return;
    viewCount.value = info.views;
    subscription.value = info.subscription;
  }

  Future<bool> toggleDiscussionFollow() async {
    if (isFollowUpdating.value) {
      return false;
    }

    final targetFollow = subscription.value != 1;
    isFollowUpdating.value = true;
    try {
      final result = await discussionRepo.setDiscussionFollow(
        discussionId: discussion.id,
        follow: targetFollow,
      );
      if (result.isFailure) {
        return false;
      }

      final nextValue = targetFollow ? 1 : 0;
      subscription.value = nextValue;
      return true;
    } finally {
      isFollowUpdating.value = false;
    }
  }

  static const int _pageSize = 10;
  int _offset = 1;
  String? _nextUrl;
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

    replyItems.clear();
    newReplyItems.clear();
    await _loadInitialPosts();
    final ok = firstPost.value != null;

    _finishRefreshSafely(ok ? IndicatorResult.success : IndicatorResult.fail);

    _finishLoadSafely(
      _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
    );
    _setReplyLoadingSafely(false);
  }

  Future<void> onReplyLoad() async {
    if (replyItems.isEmpty && newReplyItems.isEmpty) {
      isReplyLoading.value = true;
    }

    if (_loading) {
      _finishLoadSafely(IndicatorResult.fail);
      _setReplyLoadingSafely(false);
      return;
    }

    if (!_hasMore) {
      _finishLoadSafely(IndicatorResult.noMore);
      _setReplyLoadingSafely(false);
      return;
    }

    final ok = await _loadReplies();

    _finishLoadSafely(
      ok
          ? (_hasMore ? IndicatorResult.success : IndicatorResult.noMore)
          : IndicatorResult.fail,
    );
    _setReplyLoadingSafely(false);
  }

  Future<bool> _loadReplies({bool reset = false}) async {
    try {
      _loading = true;

      final result = await postRepo.getPostPage(
        discussionId: discussion.id,
        offset: _offset,
        limit: _pageSize,
        sort: switch (_replySort) {
          ReplySort.like => PostPageSort.number,
          ReplySort.time => PostPageSort.time,
        },
        nextUrl: reset ? null : _nextUrl,
        cancelToken: _cancelToken,
      );
      if (result.error?.type == RepoErrorType.cancelled) return false;
      final list = result.data;
      if (list == null) {
        LogUtil.error(
          "[PostDetailPage] Response data is empty, maybe no more posts in this discussion",
        );
        return false;
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
      _nextUrl = result.nextUrl;
      _hasMore = result.hasMore;

      return true;
    } catch (e, s) {
      LogUtil.errorE("[PostPage] Failed to load replies.", e, s);
      return false;
    } finally {
      _loading = false;
    }
  }

  void _finishRefreshSafely(IndicatorResult result) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      refreshController.finishRefresh(result);
    });
  }

  void _finishLoadSafely(IndicatorResult result) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      refreshController.finishLoad(result);
    });
  }

  void _setReplyLoadingSafely(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      isReplyLoading.value = value;
    });
  }

  Future<void> showAddReplySheet(BuildContext context) async {
    await ReplyUtil.showAddReplySheet(
      context: context,
      discussionId: discussion.id,
      replyTargetTitle: discussion.title,
      newReplyItems: newReplyItems,
      updateWidget: () {},
      scrollController: scrollController,
    );
  }

  @override
  void onClose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('Post detail closed.');
    }
    refreshController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  String getId() {
    return discussion.id;
  }
}
