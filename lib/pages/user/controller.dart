/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:typed_data';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/cache_utils.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';

enum UserPageSection { info, comments, topics, badges }

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

  final int userId;
  int currentPage = 1;
  final Rxn<UserInfo> profile = Rxn<UserInfo>();
  final RxBool isProfileLoading = false.obs;
  final RxBool isCommentsLoading = false.obs;
  final RxBool isTopicsLoading = false.obs;
  final RxBool isAvatarUploading = false.obs;
  final RxBool isBioUpdating = false.obs;
  final RxBool detailsExpanded = false.obs;
  bool expAnimationPlayed = false;
  bool _infoInitialized = false;
  bool _commentsInitialized = false;
  bool _topicsInitialized = false;
  Future<void>? _profileLoadingTask;

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
    isProfileLoading.value = true;
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
      final data = await Api.getPostsByAuthor(
        username: info?.username ?? "",
        offset: _commentsOffset,
        limit: pageSize,
      );

      if (data == null) {
        LogUtil.warn("[UserPage] empty response");
        return false;
      }

      final list = data.posts.values;

      if (list.isEmpty) {
        _commentsHasMore = false;
        return true;
      }

      for (var i in list) {
        i.user = info;
        final t = htmlToPlainText(i.contentHtml);
        i.contentHtml =
            "<p>${t.substring(0, t.length > 70 ? 70 : t.length)}...</p>";
      }
      comments.addAll(list);
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
      final data = await Api.getAuthorThemes(
        username: info?.username ?? "",
        offset: _topicsOffset,
        limit: pageSize,
      );

      if (data == null) {
        LogUtil.warn("[UserPage] empty author themes response");
        return false;
      }

      final list = data.list;
      if (list.isEmpty) {
        _topicsHasMore = false;
        return true;
      }

      topics.addAll(list);
      _topicsOffset += list.length;

      if (list.length < pageSize) {
        _topicsHasMore = false;
      }

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
      case UserPageSection.badges:
        if (!_infoInitialized && _profileLoadingTask == null) {
          await loadUserData();
        }
        return;
      case UserPageSection.comments:
        if (_commentsInitialized || isCommentsLoading.value) {
          return;
        }
        await onCommentsRefresh();
        return;
      case UserPageSection.topics:
        if (_topicsInitialized || isTopicsLoading.value) {
          return;
        }
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
      final r = await Api.getDiscussionById(discussion.toString());
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
      final ok = await Api.uploadAvatar(
        userId: repo.userId,
        fileData: fileData,
        fileName: fileName,
      );
      if (!ok) {
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
      final ok = await Api.updateBio(repo.userId, bio.trim());
      if (!ok) {
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

  @override
  void onClose() {
    commentsScrollController.dispose();
    commentsRefreshController.dispose();
    topicsScrollController.dispose();
    topicsRefreshController.dispose();
    super.onClose();
  }
}
