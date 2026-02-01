/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/data/model/notifications.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:get/get.dart';

class NotificationPageController extends GetxController {
  NotificationPageController();
  int currentPage = 1;

  final items = <NotificationsInfo>[].obs;
  final repo = getIt<UserRepo>();
  late final StreamSubscription _sub;

  String? nextUrl;
  bool loading = false;
  bool isFirstSync = true;
  final RxBool isInvoking = false.obs;

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

  @override
  void onInit() {
    isLogin.value = repo.isLogin;
    super.onInit();
  }

  @override
  void onClose() {
    _sub.cancel();
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    if (_loading) {
      refreshController.finishRefresh(IndicatorResult.fail);
      refreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    try {
      _loading = true;

      items.clear();
      nextUrl = null;
      _hasMore = true;

      if (!repo.isLogin) {
        LogUtil.error("[NotifyPage] refresh failed, user not login.");
        if (!isFirstSync) {
          SnackbarUtils.showMessage("用户未登录");
        }
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        return;
      }

      final (r, rs) = await Api.getNotification();

      if (!rs) {
        if (!isFirstSync) {
          LogUtil.error(
            "[NotifyPage] Notification api return 401 for token expired error.",
          );
          repo.logout();
          SnackbarUtils.showMessage("登录状态过期，请重新登录");
        } else {
          LogUtil.debug(
            "[NotifyPage] Notification api return 401 but in firstSync.",
          );
        }
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        return;
      }

      if (r == null) {
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        return;
      }

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
    }
  }

  Future<void> onLoad() async {
    if (_loading) {
      refreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    if (!_hasMore || nextUrl == null || nextUrl!.isEmpty) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      _loading = true;

      if (!repo.isLogin) {
        LogUtil.error("[NotifyPage] refresh failed, user not login.");
        SnackbarUtils.showMessage("用户未登录");
        refreshController.finishRefresh(IndicatorResult.fail);
        refreshController.finishLoad(IndicatorResult.fail);

        return;
      }

      final (r, rs) = await Api.getNotification(url: nextUrl);

      if (!rs) {
        LogUtil.error(
          "[NotifyPage] Notification api return 401 for token expired error.",
        );
        repo.logout();
        SnackbarUtils.showMessage("登录状态过期，请重新登录");
        refreshController.finishLoad(IndicatorResult.fail);
        return;
      }

      if (r == null) {
        refreshController.finishLoad(IndicatorResult.fail);
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
    }
  }

  Future<bool> checkAsRead(int id) async {
    try {
      final r = await Api.setNotificationIsRead(id.toString());
      if (r == null) {
        LogUtil.error("[NotifyPage] Failed to check as read for $id");
        SnackbarUtils.showMessage("标记已读失败！");
        return false;
      }

      SnackbarUtils.showMessage("标记已读成功！");
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
      Get.rawSnackbar(message: "标记已读失败！");
      return false;
    }
  }

  void readAll() async {
    if (isInvoking.value) return;
    isInvoking.value = true;

    try {
      final r = await Api.readAllNotification();
      if (!r) {
        Get.rawSnackbar(message: "标记全部已读失败！");
        return;
      }

      Get.rawSnackbar(message: "标记已读成功！");
      for(var item in items) {
        item.isRead = true;
      }

    } catch (e, s) {
      LogUtil.errorE("[NotifyPage] Failed to make all read with error:", e, s);
    } finally {
      isInvoking.value = false;
    }
  }

  void clearAll() async {
    if (isInvoking.value) return;
    isInvoking.value = true;

    try {
      final r = await Api.clearAllNotification();
      if (!r) {
        Get.rawSnackbar(message: "清理全部消息失败");
        LogUtil.error("[NotifyPage] Failed to clear all notifications");
        return;
      }

      items.clear();
      
      nextUrl = null;
      loading = false;
      Get.rawSnackbar(message: "清理全部消息成功!");
      LogUtil.debug("[NotifyPage] Cleared.");
    } catch (e, s) {
      LogUtil.errorE(
        "[NotifyPage] Failed to clear all notifications with error:",
        e,
        s,
      );
    } finally {
      isInvoking.value = false;
    }
  }

  Future<DiscussionItem?> naviToDisPage(int discussion) async {
    if (isInvoking.value) {
      return null;
    }
    isInvoking.value = true;

    try {
      final r = await Api.getDiscussionById(discussion.toString());
      if (r == null) {
        LogUtil.error(
          "[NotifyPage] Failed to get discussion detail by discussion id : $discussion",
        );
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
      isInvoking.value = false;
    }
  }
}
