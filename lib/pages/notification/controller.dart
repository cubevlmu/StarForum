/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/api/api.dart';
import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

enum NotificationTab { likes, replies, notices }

enum NotificationToolbarAction { none, readAll, clearAll }

enum NotificationItemAction { none, markRead, openDiscussion }

class NotificationPageController extends GetxController {
  NotificationPageController();
  int currentPage = 1;

  final items = <NotificationsInfo>[].obs;
  final Rx<NotificationTab> currentTab = NotificationTab.likes.obs;
  final repo = getIt<UserRepo>();
  String? nextUrl;
  bool loading = false;
  bool isFirstSync = true;
  final RxBool isInvoking = false.obs;
  final RxBool isInitialLoading = true.obs;
  final Rx<NotificationToolbarAction> activeToolbarAction =
      NotificationToolbarAction.none.obs;
  final Rx<NotificationItemAction> activeItemAction =
      NotificationItemAction.none.obs;
  final RxnInt activeItemId = RxnInt();

  bool _loading = false;
  bool _hasMore = true;

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
                  item.contentType == "newPostByUser",
            )
            .toList();
      case NotificationTab.notices:
        return items
            .where(
              (item) =>
                  item.contentType != "postLiked" &&
                  item.contentType != "postMentioned" &&
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
    isLogin.value = repo.isLogin;
    super.onInit();
  }

  @override
  void onClose() {
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

      final (r, rs) = await Api.getNotification();

      if (!rs) {
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

      if (r == null) {
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        isInitialLoading.value = false;
        return;
      }

      items.clear();
      items.addAll(r.list);
      nextUrl = r.links.next;
      _hasMore = nextUrl != null;

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

      final (r, rs) = await Api.getNotification(url: nextUrl);

      if (!rs) {
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

      if (r == null) {
        refreshController.finishLoad(IndicatorResult.fail);
        isInitialLoading.value = false;
        return;
      }

      items.addAll(r.list);
      nextUrl = r.links.next;
      _hasMore = nextUrl != null;

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
    if (isInvoking.value) return false;
    isInvoking.value = true;
    activeItemId.value = id;
    activeItemAction.value = NotificationItemAction.markRead;
    try {
      final r = await Api.setNotificationIsRead(id.toString());
      if (r == null) {
        LogUtil.error("[NotifyPage] Failed to check as read for $id");
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.notificationMarkReadFailed,
        );
        return false;
      }

      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationMarkReadSuccess,
      );
      final item = items.firstWhere((i) {
        return i.id == id;
      });
      var idx = items.indexOf(item);
      items.remove(item);
      item.isRead = true;
      items.insert(idx, item);

      return true;
    } catch (e, s) {
      LogUtil.errorE(
        "[NotifyPage] Failed to check as read for $id with error.",
        e,
        s,
      );
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationMarkReadFailed,
      );
      return false;
    } finally {
      activeItemId.value = null;
      activeItemAction.value = NotificationItemAction.none;
      isInvoking.value = false;
    }
  }

  void readAll() async {
    if (isInvoking.value) return;

    final isAllRead = items.isNotEmpty && items.every((item) => item.isRead);
    if (isAllRead) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationMarkAllReadNoNeed,
      );
      return;
    }

    isInvoking.value = true;
    activeToolbarAction.value = NotificationToolbarAction.readAll;

    try {
      final r = await Api.readAllNotification();
      if (!r) {
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.notificationMarkAllReadFailed,
        );
        return;
      }

      for (var item in items) {
        item.isRead = true;
      }
      items.refresh();
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationMarkReadSuccess,
      );
    } catch (e, s) {
      LogUtil.errorE("[NotifyPage] Failed to make all read with error:", e, s);
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationMarkAllReadFailed,
      );
    } finally {
      activeToolbarAction.value = NotificationToolbarAction.none;
      isInvoking.value = false;
    }
  }

  void clearAll() async {
    if (isInvoking.value) return;
    isInvoking.value = true;
    activeToolbarAction.value = NotificationToolbarAction.clearAll;

    try {
      final r = await Api.clearAllNotification();
      if (!r) {
        SnackbarUtils.showMessage(
          msg: AppLocalizations.of(Get.context!)!.notificationClearAllFailed,
        );
        LogUtil.error("[NotifyPage] Failed to clear all notifications");
        return;
      }

      items.clear();

      nextUrl = null;
      loading = false;
      LogUtil.debug("[NotifyPage] Cleared.");
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationClearAllSuccess,
      );
    } catch (e, s) {
      LogUtil.errorE(
        "[NotifyPage] Failed to clear all notifications with error:",
        e,
        s,
      );
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(Get.context!)!.notificationClearAllFailed,
      );
    } finally {
      activeToolbarAction.value = NotificationToolbarAction.none;
      isInvoking.value = false;
    }
  }

  Future<DiscussionItem?> naviToDisPage(int discussion) async {
    return naviToDisPageByItem(discussion: discussion, itemId: null);
  }

  Future<DiscussionItem?> naviToDisPageByItem({
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
      final r = await Api.getDiscussionById(discussion.toString());
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
