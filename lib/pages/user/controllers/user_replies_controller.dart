import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/user/controllers/user_profile_controller.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

class UserRepliesController {
  UserRepliesController({required this.profileController});

  static const pageSize = 20;
  final UserProfileController profileController;
  final PostRepository postRepository = getIt<PostRepository>();
  final DiscussionRepository discussionRepository =
      getIt<DiscussionRepository>();
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final ScrollController scrollController = ScrollController();
  final RxList<PostInfo> items = <PostInfo>[].obs;
  final RxMap<int, DiscussionDetail> discussions =
      <int, DiscussionDetail>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOpeningDiscussion = false.obs;
  final CancelToken _cancelToken = CancelToken();
  int _offset = 0;
  bool _hasMore = true;
  bool _syncing = false;
  bool _initialized = false;
  bool _disposed = false;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized || isLoading.value) return;
    await _restoreCached();
    await refresh();
  }

  Future<bool> _load() async {
    if (!_hasMore) return true;
    if (_syncing) return false;
    _syncing = true;
    await profileController.load();
    final username = profileController.info?.username ?? '';
    if (username.isEmpty) {
      _syncing = false;
      return false;
    }
    try {
      final result = await postRepository.getPostsByAuthor(
        username: username,
        offset: _offset,
        limit: pageSize,
        cancelToken: _cancelToken,
      );
      final data = result.data;
      if (data == null) return false;
      final next = data.posts.values;
      if (next.isEmpty) {
        _hasMore = false;
        return true;
      }
      _append(next);
      discussions.addAll(data.discussions);
      _offset += next.length;
      if (next.length < pageSize) _hasMore = false;
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE('[UserRepliesController] load failed', error, stackTrace);
      return false;
    } finally {
      _syncing = false;
    }
  }

  Future<void> refresh() async {
    isLoading.value = true;
    _offset = 0;
    _hasMore = true;
    items.clear();
    discussions.clear();
    final ok = await _load();
    if (ok) {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
    _initialized = true;
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (items.isEmpty) isLoading.value = true;
    if (!_hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      isLoading.value = false;
      return;
    }
    final ok = await _load();
    refreshController.finishLoad(
      !ok
          ? IndicatorResult.fail
          : _hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore,
    );
    isLoading.value = false;
  }

  Future<void> _restoreCached() async {
    await profileController.load();
    final username = profileController.info?.username ?? '';
    if (username.isEmpty) return;
    final data = await postRepository.getCachedPostsByAuthor(
      username: username,
      offset: 0,
      limit: pageSize,
    );
    final cached = data.posts.values;
    if (cached.isEmpty || _disposed) return;
    items.clear();
    discussions.clear();
    _append(cached);
    discussions.addAll(data.discussions);
    _offset = cached.length;
    _hasMore = cached.length >= pageSize;
    isLoading.value = false;
  }

  void _append(Iterable<PostInfo> posts) {
    items.addAll(
      posts.map((post) {
        final text = htmlToPlainText(post.contentHtml);
        final length = text.length > 70 ? 70 : text.length;
        return post.copyWith(
          user: profileController.info,
          contentHtml: '<p>${text.substring(0, length)}...</p>',
        );
      }),
    );
  }

  Future<DiscussionSummary?> openDiscussion(int discussionId) async {
    if (isOpeningDiscussion.value) return null;
    isOpeningDiscussion.value = true;
    try {
      final result = await discussionRepository.getDiscussionById(
        discussionId.toString(),
      );
      final discussion = result.data;
      if (discussion == null) {
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.commonNoticeFetchPostFailed,
        );
        return null;
      }
      final firstUser = discussion.users.values.firstOrNull;
      final firstPost = discussion.posts[discussion.firstPostId]?.copyWith(
        user: firstUser,
      );
      return discussion
          .copyWith(firstPost: firstPost, user: firstUser)
          .toSummary();
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[UserRepliesController] open discussion failed',
        error,
        stackTrace,
      );
      return null;
    } finally {
      isOpeningDiscussion.value = false;
    }
  }

  void dispose() {
    _disposed = true;
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('User replies closed.');
    }
    scrollController.dispose();
    refreshController.dispose();
  }
}
