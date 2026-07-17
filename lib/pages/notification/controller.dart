/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/repository/discussion_repo.dart';
import 'package:star_forum/data/repository/notification_repo.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/notification/notification_actions.dart';
import 'package:star_forum/pages/notification/notification_state.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

export 'notification_state.dart';

class NotificationListController extends GetxController {
  NotificationListController() {
    actions = NotificationActions(
      repository: notificationRepo,
      items: items,
      isInvoking: isInvoking,
      activeToolbarAction: activeToolbarAction,
      activeItemAction: activeItemAction,
      activeItemId: activeItemId,
      onCleared: _handleCleared,
    );
  }
  final items = <NotificationsInfo>[].obs;
  final Rx<NotificationTab> currentTab = NotificationTab.likes.obs;
  final repo = getIt<UserRepo>();
  final sessionState = getIt<SessionState>();
  final notificationRepo = getIt<NotificationRepository>();
  final discussionRepo = getIt<DiscussionRepository>();
  String? nextUrl;
  bool isFirstSync = true;
  final RxBool isInvoking = false.obs;
  final RxBool isInitialLoading = true.obs;
  final Rx<NotificationToolbarAction> activeToolbarAction =
      NotificationToolbarAction.none.obs;
  final Rx<NotificationItemAction> activeItemAction =
      NotificationItemAction.none.obs;
  final RxnInt activeItemId = RxnInt();
  late final NotificationActions actions;

  bool _loading = false;
  bool _hasMore = true;
  bool? _lastSessionLogin;

  void animateToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  RxBool isLogin = false.obs;

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  List<NotificationsInfo> get filteredItems {
    switch (currentTab.value) {
      case NotificationTab.likes:
        return items.where((item) => item.contentType == "postLiked").toList();
      case NotificationTab.replies:
        return items
            .where(
              (item) =>
                  item.contentType == "postMentioned" ||
                  item.contentType == "newPost" ||
                  item.contentType == "newPostByUser",
            )
            .toList();
      case NotificationTab.notices:
        return items
            .where(
              (item) =>
                  item.contentType != "postLiked" &&
                  item.contentType != "postMentioned" &&
                  item.contentType != "newPost" &&
                  item.contentType != "newPostByUser",
            )
            .toList();
    }
  }

  int unreadCountForTab(NotificationTab tab) {
    return switch (tab) {
      NotificationTab.likes =>
        items
            .where((item) => item.contentType == "postLiked" && !item.isRead)
            .length,
      NotificationTab.replies =>
        items
            .where(
              (item) =>
                  (item.contentType == "postMentioned" ||
                      item.contentType == "newPost" ||
                      item.contentType == "newPostByUser") &&
                  !item.isRead,
            )
            .length,
      NotificationTab.notices =>
        items
            .where(
              (item) =>
                  item.contentType != "postLiked" &&
                  item.contentType != "postMentioned" &&
                  item.contentType != "newPost" &&
                  item.contentType != "newPostByUser" &&
                  !item.isRead,
            )
            .length,
    };
  }

  bool get hasUnreadItems => items.any((item) => !item.isRead);

  void selectTab(NotificationTab tab) {
    if (currentTab.value == tab) return;
    currentTab.value = tab;
  }

  @override
  void onInit() {
    super.onInit();
    final loggedIn = sessionState.current.isAuthenticated;
    _lastSessionLogin = loggedIn;
    isLogin.value = loggedIn;
    sessionState.state.addListener(_handleSessionChanged);
    _restoreCachedNotifications();
  }

  void _handleSessionChanged() {
    final loggedIn = sessionState.current.isAuthenticated;
    if (_lastSessionLogin == loggedIn) return;
    _lastSessionLogin = loggedIn;
    unawaited(handleLoginStateChanged(loggedIn));
  }

  Future<void> _restoreCachedNotifications() async {
    if (!repo.isLogin) {
      isInitialLoading.value = false;
      return;
    }
    final cached = await notificationRepo.getCachedNotifications();
    if (cached.isEmpty || isClosed) return;
    items.assignAll(cached);
    isInitialLoading.value = false;
  }

  @override
  void onClose() {
    sessionState.state.removeListener(_handleSessionChanged);
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<void> handleLoginStateChanged(bool loggedIn) async {
    isLogin.value = loggedIn;

    if (!loggedIn) {
      items.clear();
      nextUrl = null;
      _hasMore = true;
      _loading = false;
      isInitialLoading.value = false;
      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    isFirstSync = true;
    isInitialLoading.value = true;
    refreshController.finishRefresh(IndicatorResult.success);
    refreshController.resetFooter();

    if (_loading) {
      return;
    }

    await onRefresh();
  }

  Future<void> onRefresh() async {
    if (_loading) {
      refreshController.finishRefresh(IndicatorResult.fail);
      refreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    try {
      _loading = true;

      nextUrl = null;
      _hasMore = true;

      if (!repo.isLogin) {
        LogUtil.error("[NotifyPage] refresh failed, user not login.");
        if (!isFirstSync) {
          SnackbarUtils.showMessage(
            msg: AppLocalizations.of(Get.context!)!.authUserNotLogin,
          );
        }
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        isInitialLoading.value = false;
        return;
      }

      final result = await notificationRepo.getNotifications();

      if (result.isTokenExpired) {
        if (!isFirstSync) {
          LogUtil.error(
            "[NotifyPage] Notification api return 401 for token expired error.",
          );
          repo.logout();
          SnackbarUtils.showMessage(
            msg: AppLocalizations.of(Get.context!)!.authLoginExpired,
          );
        } else {
          LogUtil.debug(
            "[NotifyPage] Notification api return 401 but in firstSync.",
          );
        }
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        isInitialLoading.value = false;
        return;
      }

      final list = result.data;
      if (list == null) {
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        isInitialLoading.value = false;
        return;
      }

      items.clear();
      items.addAll(list);
      nextUrl = result.nextUrl;
      _hasMore = result.hasMore;

      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.finishLoad(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
      if (isFirstSync) {
        isFirstSync = false;
      }
    } catch (e, s) {
      LogUtil.errorE("[NotifyPage] refresh failed", e, s);
      refreshController.finishRefresh(IndicatorResult.fail);
      refreshController.finishLoad(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> onLoad() async {
    if (items.isEmpty) {
      isInitialLoading.value = true;
    }

    if (_loading) {
      refreshController.finishLoad(IndicatorResult.fail);
      isInitialLoading.value = false;
      return;
    }

    if (!_hasMore || nextUrl == null || nextUrl!.isEmpty) {
      refreshController.finishLoad(IndicatorResult.noMore);
      isInitialLoading.value = false;
      return;
    }

    try {
      _loading = true;

      if (!repo.isLogin) {
        LogUtil.error("[NotifyPage] refresh failed, user not login.");
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.authUserNotLogin,
        );
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        isInitialLoading.value = false;
        return;
      }

      final result = await notificationRepo.getNotifications(url: nextUrl);

      if (result.isTokenExpired) {
        LogUtil.error(
          "[NotifyPage] Notification api return 401 for token expired error.",
        );
        repo.logout();
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.authLoginExpired,
        );
        refreshController.finishLoad(IndicatorResult.fail);
        isInitialLoading.value = false;
        return;
      }

      final list = result.data;
      if (list == null) {
        refreshController.finishLoad(IndicatorResult.fail);
        isInitialLoading.value = false;
        return;
      }

      items.addAll(list);
      nextUrl = result.nextUrl;
      _hasMore = result.hasMore;

      refreshController.finishLoad(
        _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
      );
    } catch (e, s) {
      LogUtil.errorE("[NotifyPage] load failed", e, s);
      refreshController.finishLoad(IndicatorResult.fail);
    } finally {
      _loading = false;
      isInitialLoading.value = false;
    }
  }

  Future<bool> checkAsRead(int id) async {
    return actions.markRead(id);
  }

  Future<void> readAll() => actions.readAll();

  Future<void> clearAll() => actions.clearAll();

  void _handleCleared() {
    nextUrl = null;
    _hasMore = false;
  }

  Future<DiscussionSummary?> naviToDisPage(int discussion) async {
    return naviToDisPageByItem(discussion: discussion, itemId: null);
  }

  Future<DiscussionSummary?> naviToDisPageByItem({
    required int discussion,
    required int? itemId,
  }) async {
    if (isInvoking.value) {
      return null;
    }
    isInvoking.value = true;
    activeItemId.value = itemId;
    activeItemAction.value = NotificationItemAction.openDiscussion;

    try {
      final result = await discussionRepo.getDiscussionById(
        discussion.toString(),
      );
      final r = result.data;
      if (r == null) {
        LogUtil.error(
          "[NotifyPage] Failed to get discussion detail by discussion id : $discussion",
        );
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(
            Get.context!,
          )!.notificationFetchDiscussionFailed,
        );
        return null;
      }
      return r.toSummary();
    } catch (e, s) {
      LogUtil.errorE(
        "[UserPage] Failed to fetch discussion information with id: $discussion with error:",
        e,
        s,
      );
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(
          Get.context!,
        )!.notificationFetchDiscussionFailed,
      );
      return null;
    } finally {
      activeItemId.value = null;
      activeItemAction.value = NotificationItemAction.none;
      isInvoking.value = false;
    }
  }
}

class NotificationPageController extends NotificationListController {}
