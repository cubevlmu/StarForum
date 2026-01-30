/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */
import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/data/repository/discussion_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:get/get.dart';

class PostListController extends GetxController {
  final DiscussionRepository repo = getIt<DiscussionRepository>();

  final RxList<DiscussionItem> items = <DiscussionItem>[].obs;

  late final StreamSubscription _sub;

  void animateToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  @override
  void onInit() {
    super.onInit();

    // ✅ 订阅本地数据库 + excerpt cache
    _sub = repo.watchDiscussionItems().listen((list) {
      items.assignAll(list);
    });
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
      await repo.syncDiscussionList("");
      refreshController.finishRefresh();
    } catch (e) {
      log("[PostListPage] refresh failed with execption: ${e.toString()}");
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoad() async {
    // Flarum discussion 列表本质是 offset-based
    // 你现在这个客户端可以先不实现 load-more
    refreshController.finishLoad(IndicatorResult.noMore);
  }
}
