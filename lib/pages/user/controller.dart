/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/post_repo.dart';
import 'package:star_forum/data/repository/repo_result.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';

enum UserPageSection { info, comments, topics, badges, assets }

class UserPageController extends GetxController {
  UserPageController({required this.userId});
  final EasyRefreshController commentsRefreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final EasyRefreshController topicsRefreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );
  final cacheManager = CacheUtils.avatarCacheManager;
  final ScrollController commentsScrollController = ScrollController();
  final ScrollController topicsScrollController = ScrollController();

  final Rx<UserPageSection> currentSection = UserPageSection.info.obs;
  final RxList<PostInfo> comments = <PostInfo>[].obs;
  final RxList<DiscussionInfo> topics = <DiscussionInfo>[].obs;
  final RxList<UserBadge> badges = <UserBadge>[].obs;
  final RxMap<int, DiscussionInfo> commentDiscussions =
      <int, DiscussionInfo>{}.obs;

  static const int pageSize = 20;
  int _commentsOffset = 0;
  bool _commentsHasMore = true;
  int _topicsOffset = 0;
  bool _topicsHasMore = true;
  final RxBool isLoading = false.obs;
  bool _isCommentsSyncing = false;
  bool _isTopicsSyncing = false;

  final repo = getIt<UserRepo>();
  final postRepo = getIt<PostRepository>();
  final discussionRepo = getIt<DiscussionRepository>();

  final int userId;
  int currentPage = 1;
  final Rxn<UserInfo> profile = Rxn<UserInfo>();
  final RxBool isProfileLoading = false.obs;
  final RxBool isCommentsLoading = false.obs;
  final RxBool isTopicsLoading = false.obs;
  final RxBool isBadgesLoading = false.obs;
  final RxBool isAvatarUploading = false.obs;
  final RxBool isBioUpdating = false.obs;
  final RxBool isNicknameUpdating = false.obs;
  final RxBool detailsExpanded = false.obs;
  bool expAnimationPlayed = false;
  bool _infoInitialized = false;
  bool _commentsInitialized = false;
  bool _topicsInitialized = false;
  bool _badgesInitialized = false;
  Future<void>? _profileLoadingTask;
  final CancelToken _cancelToken = CancelToken();

  UserInfo? get info => profile.value;
  set info(UserInfo? value) => profile.value = value;

  bool get hasExpData => info?.expInfo != null;

  Future<void> loadUserData() async {
    if (info != null) {
      isProfileLoading.value = false;
      return;
    }
    if (_profileLoadingTask != null) {
      await _profileLoadingTask;
      return;
    }

    final task = _loadUserDataInternal();
    _profileLoadingTask = task;
    await task;
  }

  Future<void> _loadUserDataInternal() async {
    if (userId <= 0) {
      LogUtil.warn("[UserPage] skip invalid user id: $userId");
      isProfileLoading.value = false;
      return;
    }
    isProfileLoading.value = true;
    try {
      final cached = await repo.getCachedUserInfoByNameOrId(userId.toString());
      if (cached != null && info == null) {
        info = cached;
        _infoInitialized = true;
        isProfileLoading.value = false;
      }
      final result = await repo.getUserInfoByNameOrId(
        userId.toString(),
        cancelToken: _cancelToken,
      );
      if (result.error?.type == RepoErrorType.cancelled) return;
      final r = result.data;
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
        info = info;
      }

      if (info?.expInfo == null) {
        expAnimationPlayed = true;
      }
      _infoInitialized = true;
    } catch (e, s) {
      LogUtil.errorE(
        "[UserPage] Get user information failed with error: ",
        e,
        s,
      );
    } finally {
      _profileLoadingTask = null;
      isProfileLoading.value = false;
    }
  }

  Future<bool> _loadUserComments() async {
    if (!_commentsHasMore) return true;
    if (_isCommentsSyncing) return false;
    _isCommentsSyncing = true;

    await loadUserData();
    if (info == null) {
      LogUtil.warn("[UserPage] User info is not prepared.");
      _isCommentsSyncing = false;
      return false;
    }

    try {
      final result = await postRepo.getPostsByAuthor(
        username: info?.username ?? "",
        offset: _commentsOffset,
        limit: pageSize,
        cancelToken: _cancelToken,
      );
      final data = result.data;

      if (data == null) {
        LogUtil.warn("[UserPage] empty response");
        return false;
      }

      final list = data.posts.values;

      if (list.isEmpty) {
        _commentsHasMore = false;
        return true;
      }

      _appendCommentPosts(list);
      commentDiscussions.addAll(data.discussions);
      _commentsOffset += list.length;

      if (list.length < pageSize) {
        _commentsHasMore = false;
      }

      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] load comments error", e, s);
      return false;
    } finally {
      _isCommentsSyncing = false;
    }
  }

  Future<void> onCommentsRefresh() async {
    isCommentsLoading.value = true;
    _commentsOffset = 0;
    _commentsHasMore = true;
    comments.clear();
    commentDiscussions.clear();

    final ok = await _loadUserComments();

    if (ok) {
      commentsRefreshController.finishRefresh();
      commentsRefreshController.resetFooter();
    } else {
      commentsRefreshController.finishRefresh(IndicatorResult.fail);
    }

    _commentsInitialized = true;
    isCommentsLoading.value = false;
  }

  Future<void> _restoreCachedComments() async {
    await loadUserData();
    final username = info?.username ?? '';
    if (username.isEmpty) return;
    final data = await postRepo.getCachedPostsByAuthor(
      username: username,
      offset: 0,
      limit: pageSize,
    );
    final list = data.posts.values;
    if (list.isEmpty || isClosed) return;
    comments.clear();
    commentDiscussions.clear();
    _appendCommentPosts(list);
    commentDiscussions.addAll(data.discussions);
    _commentsOffset = list.length;
    _commentsHasMore = list.length >= pageSize;
    isCommentsLoading.value = false;
  }

  void _appendCommentPosts(Iterable<PostInfo> list) {
    for (final item in list) {
      item.user = info;
      final text = htmlToPlainText(item.contentHtml);
      item.contentHtml =
          "<p>${text.substring(0, text.length > 70 ? 70 : text.length)}...</p>";
    }
    comments.addAll(list);
  }

  Future<void> onCommentsLoad() async {
    if (comments.isEmpty) {
      isCommentsLoading.value = true;
    }

    if (!_commentsHasMore) {
      commentsRefreshController.finishLoad(IndicatorResult.noMore);
      isCommentsLoading.value = false;
      return;
    }

    final ok = await _loadUserComments();

    if (!ok) {
      commentsRefreshController.finishLoad(IndicatorResult.fail);
      isCommentsLoading.value = false;
      return;
    }

    if (_commentsHasMore) {
      commentsRefreshController.finishLoad();
    } else {
      commentsRefreshController.finishLoad(IndicatorResult.noMore);
    }
    isCommentsLoading.value = false;
  }

  Future<bool> _loadUserTopics() async {
    if (!_topicsHasMore) return true;
    if (_isTopicsSyncing) return false;
    _isTopicsSyncing = true;

    await loadUserData();
    if (info == null) {
      LogUtil.warn("[UserPage] User info is not prepared.");
      _isTopicsSyncing = false;
      return false;
    }

    try {
      final result = await discussionRepo.getAuthorThemes(
        username: info?.username ?? "",
        offset: _topicsOffset,
        limit: pageSize,
        cancelToken: _cancelToken,
      );

      if (result.isFailure) {
        LogUtil.warn("[UserPage] empty author themes response");
        return false;
      }

      final list = result.data ?? const <DiscussionInfo>[];
      if (list.isEmpty) {
        _topicsHasMore = false;
        return true;
      }

      topics.addAll(list);
      _topicsOffset += list.length;

      _topicsHasMore = result.hasMore;

      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] load topics error", e, s);
      return false;
    } finally {
      _isTopicsSyncing = false;
    }
  }

  Future<void> onTopicsRefresh() async {
    isTopicsLoading.value = true;
    _topicsOffset = 0;
    _topicsHasMore = true;
    topics.clear();

    final ok = await _loadUserTopics();

    if (ok) {
      topicsRefreshController.finishRefresh();
      topicsRefreshController.resetFooter();
    } else {
      topicsRefreshController.finishRefresh(IndicatorResult.fail);
    }

    _topicsInitialized = true;
    isTopicsLoading.value = false;
  }

  Future<void> _restoreCachedTopics() async {
    await loadUserData();
    final username = info?.username ?? '';
    if (username.isEmpty) return;
    final cached = await discussionRepo.getCachedAuthorThemes(
      username: username,
      offset: 0,
      limit: pageSize,
    );
    if (cached.isEmpty || isClosed) return;
    topics.assignAll(cached);
    _topicsOffset = cached.length;
    _topicsHasMore = cached.length >= pageSize;
    isTopicsLoading.value = false;
  }

  Future<void> onTopicsLoad() async {
    if (topics.isEmpty) {
      isTopicsLoading.value = true;
    }

    if (!_topicsHasMore) {
      topicsRefreshController.finishLoad(IndicatorResult.noMore);
      isTopicsLoading.value = false;
      return;
    }

    final ok = await _loadUserTopics();

    if (!ok) {
      topicsRefreshController.finishLoad(IndicatorResult.fail);
      isTopicsLoading.value = false;
      return;
    }

    if (_topicsHasMore) {
      topicsRefreshController.finishLoad();
    } else {
      topicsRefreshController.finishLoad(IndicatorResult.noMore);
    }
    isTopicsLoading.value = false;
  }

  Future<void> loadUserBadges() async {
    if (_badgesInitialized || isBadgesLoading.value || userId <= 0) {
      return;
    }
    isBadgesLoading.value = true;
    try {
      final result = await repo.getUserBadges(
        userId,
        cancelToken: _cancelToken,
      );
      if (result.error?.type == RepoErrorType.cancelled) return;
      badges.assignAll(result.data ?? const <UserBadge>[]);
      _badgesInitialized = true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] load user badges error", e, s);
    } finally {
      isBadgesLoading.value = false;
    }
  }

  Future<void> selectSection(UserPageSection section) async {
    if (currentSection.value == section) {
      return;
    }
    currentSection.value = section;
    await ensureSectionLoaded(section);
  }

  Future<void> ensureSectionLoaded(UserPageSection section) async {
    switch (section) {
      case UserPageSection.info:
      case UserPageSection.assets:
        if (!_infoInitialized && _profileLoadingTask == null) {
          await loadUserData();
        }
        return;
      case UserPageSection.badges:
        await loadUserBadges();
        return;
      case UserPageSection.comments:
        if (_commentsInitialized || isCommentsLoading.value) {
          return;
        }
        await _restoreCachedComments();
        await onCommentsRefresh();
        return;
      case UserPageSection.topics:
        if (_topicsInitialized || isTopicsLoading.value) {
          return;
        }
        await _restoreCachedTopics();
        await onTopicsRefresh();
        return;
    }
  }

  String getLastSeenAt() {
    if (info == null) {
      return "";
    }
    if (repo.isLogin) {
      if (repo.user?.id == info?.id) {
        return AppLocalizations.of(Get.context!)!.userOnline;
      }
    }

    try {
      final date = info?.lastSeenAt ?? fallbackTime;
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
      final date = info?.joinTime ?? fallbackTime;
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

  bool shouldAnimateExp() {
    if (expAnimationPlayed) return false;
    if (info?.expInfo == null) return false;
    return true;
  }

  void markExpAnimationPlayed() {
    expAnimationPlayed = true;
  }

  bool isMe() {
    if (info == null) return false;
    if (!repo.isLogin) return false;
    if (info?.id == repo.user?.id) return true;
    return false;
  }

  void toggleDetailsExpanded() {
    detailsExpanded.value = !detailsExpanded.value;
  }

  List<String> getGroupNames() {
    return info?.groups?.list
            .map((group) => group.name.trim())
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];
  }

  String getProfileBio() {
    final bioText = info?.bio.trim() ?? "";
    if (bioText.isEmpty) {
      return AppLocalizations.of(Get.context!)!.userBioEmpty;
    }
    return bioText;
  }

  String getUsernameLabel() {
    final value = info?.username.trim() ?? "";
    return value.isEmpty ? "--" : "@$value";
  }

  String getEmailLabel() {
    final value = info?.email.trim() ?? "";
    if (value.isEmpty) {
      return AppLocalizations.of(Get.context!)!.userFieldHidden;
    }
    return value;
  }

  String getUserIdLabel() {
    final value = info?.id;
    if (value == null || value < 0) {
      return "--";
    }
    return value.toString();
  }

  Future<DiscussionItem?> naviToDisPage(int discussion) async {
    if (isLoading.value) {
      return null;
    }
    isLoading.value = true;

    try {
      final result = await discussionRepo.getDiscussionById(
        discussion.toString(),
      );
      final r = result.data;
      if (r == null) {
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.commonNoticeFetchPostFailed,
        );
        return null;
      }
      r.firstPost = r.posts[r.firstPostId];
      r.firstPost?.user = r.users.values.first;
      r.user = r.users.values.first;
      return r.toItem();
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

  Future<bool> uploadAvatarBytes({
    required Uint8List fileData,
    required String fileName,
  }) async {
    if (!isMe()) {
      return false;
    }

    final currentAvatarUrl = info?.avatarUrl ?? repo.user?.avatarUrl ?? "";
    isAvatarUploading.value = true;

    try {
      final result = await repo.uploadAvatar(
        userId: repo.userId,
        fileData: fileData,
        fileName: fileName,
      );
      if (result.isFailure) {
        return false;
      }

      if (currentAvatarUrl.isNotEmpty) {
        await cacheManager.removeFile(currentAvatarUrl);
      }
      cacheManager.store.emptyMemoryCache();

      final refreshed = await repo.refreshCurrentUser();
      if (refreshed && repo.user != null) {
        info = repo.user;
        _infoInitialized = true;
      }
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] upload avatar failed", e, s);
      return false;
    } finally {
      isAvatarUploading.value = false;
    }
  }

  Future<bool> updateBioText(String bio) async {
    if (!isMe()) {
      return false;
    }

    isBioUpdating.value = true;
    try {
      final result = await repo.updateBio(repo.userId, bio.trim());
      if (result.isFailure) {
        return false;
      }

      final refreshed = await repo.refreshCurrentUser();
      if (refreshed && repo.user != null) {
        info = repo.user;
        _infoInitialized = true;
      } else if (info != null) {
        info!.bio = bio.trim();
        info = info;
      }
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] update bio failed", e, s);
      return false;
    } finally {
      isBioUpdating.value = false;
    }
  }

  Future<bool> updateNicknameText(String nickname) async {
    if (!isMe()) {
      return false;
    }
    final username = info?.username.trim() ?? repo.user?.username.trim() ?? '';
    if (username.isEmpty) {
      return false;
    }

    isNicknameUpdating.value = true;
    try {
      final result = await repo.updateNickname(
        userId: repo.userId,
        username: username,
        nickname: nickname.trim(),
      );
      if (result.isFailure) {
        return false;
      }

      final refreshed = await repo.refreshCurrentUser();
      if (refreshed && repo.user != null) {
        info = repo.user;
        _infoInitialized = true;
      } else if (info != null) {
        info!.displayName = nickname.trim();
        info = info;
      }
      return true;
    } catch (e, s) {
      LogUtil.errorE("[UserPage] update nickname failed", e, s);
      return false;
    } finally {
      isNicknameUpdating.value = false;
    }
  }

  @override
  void onClose() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('User page closed.');
    }
    commentsScrollController.dispose();
    commentsRefreshController.dispose();
    topicsScrollController.dispose();
    topicsRefreshController.dispose();
    super.onClose();
  }
}
