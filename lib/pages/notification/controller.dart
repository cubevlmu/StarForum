/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/notifications.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
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
    isLogin.value = repo.isLogin();
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
    try {
      loading = true;
      items.clear();
      nextUrl = null;

      if (!repo.isLogin()) {
        log("[NotifyPage] refresh failed, user not login.");
        if (!isFirstSync) {
          SnackbarUtils.showMessage("用户未登录");
        }
        refreshController.finishRefresh(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        return;
      }
      final (r, rs) = await Api.getNotification();

      if (!rs) {
        log(
          "[NotifyPage] Notification api return 401 for token expired error.",
        );
        repo.logout();
        if (!isFirstSync) {
          SnackbarUtils.showMessage("登录状态过期，请重新登录");
        }
        refreshController.finishLoad(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        return;
      }

      if (r == null) {
        refreshController.finishRefresh(IndicatorResult.fail);

        if (isFirstSync) {
          isFirstSync = false;
        }
        return;
      }

      items.addAll(r.list);
      nextUrl = r.links.next;

      refreshController.finishRefresh();
      refreshController.resetFooter();

      if (isFirstSync) {
        isFirstSync = false;
      }
    } catch (e) {
      log("[NotifyPage] refresh failed", error: e);
      refreshController.finishRefresh(IndicatorResult.fail);
    } finally {
      loading = false;
    }
  }

  Future<void> onLoad() async {
    if (loading) return;

    if (nextUrl == null) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    if (nextUrl!.isEmpty) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      loading = true;

      final (r, rs) = await Api.getNotification(url: nextUrl);

      if (!rs) {
        log(
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

      if (nextUrl == null) {
        refreshController.finishLoad(IndicatorResult.noMore);
      } else {
        refreshController.finishLoad();
      }
    } catch (e) {
      log("[NotifyPage] load failed", error: e);
      refreshController.finishLoad(IndicatorResult.fail);
    } finally {
      loading = false;
    }
  }

  Future<bool> checkAsRead(int id) async {
    try {
      final r = await Api.setNotificationIsRead(id.toString());
      if (r == null) {
        log("[NotifyPage] Failed to check as read for $id");
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
    } catch (e) {
      log("[NotifyPage] Failed to check as read for $id with error.", error: e);
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
      await onRefresh();
    } catch (e) {
      log("[NotifyPage] Failed to make all read with error:", error: e);
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
        log("[NotifyPage] Failed to clear all notifications");
        return;
      }

      items.clear();
      nextUrl = null;
      loading = false;
      Get.rawSnackbar(message: "清理全部消息成功!");
      log("[NotifyPage] Cleared.");
    } catch (e) {
      log(
        "[NotifyPage] Failed to clear all notifications with error:",
        error: e,
      );
    } finally {
      isInvoking.value = false;
    }
  }
}
