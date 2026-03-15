/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';

import 'package:star_forum/pages/home/view.dart';
import 'package:star_forum/pages/notification/view.dart';
import 'package:star_forum/pages/account/view.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/user/controller.dart';
import 'package:get/get.dart';

enum DetailPaneEntryType { discussion, user, settings }

@immutable
class DetailPaneEntry {
  const DetailPaneEntry._({
    required this.entryId,
    required this.type,
    this.discussion,
    this.userId,
  });

  const DetailPaneEntry.discussion({
    required int entryId,
    required DiscussionItem discussion,
  }) : this._(
         entryId: entryId,
         type: DetailPaneEntryType.discussion,
         discussion: discussion,
       );

  const DetailPaneEntry.user({required int entryId, required int userId})
    : this._(entryId: entryId, type: DetailPaneEntryType.user, userId: userId);

  const DetailPaneEntry.settings({required int entryId})
    : this._(entryId: entryId, type: DetailPaneEntryType.settings);

  final int entryId;
  final DetailPaneEntryType type;
  final DiscussionItem? discussion;
  final int? userId;
}

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;
  final RxList<DetailPaneEntry> detailStack = <DetailPaneEntry>[].obs;
  final RxBool isHomeSearchActive = false.obs;
  final RxnString homeSearchKeyword = RxnString();
  int _detailEntrySeed = 0;

  List<Widget> pages = [
    const HomePage(),
    const NotificationPage(),
    const AccountPage(),
  ];

  void _initData() {
    // update(["main"]);
  }

  void onDestinationSelected(int index) {
    if (selectedIndex.value == index) return;
    if (index != 0) {
      isHomeSearchActive.value = false;
      homeSearchKeyword.value = null;
    }
    selectedIndex.value = index;
  }

  void showDiscussionDetail(DiscussionItem discussion) {
    final current = currentDetail;
    if (current?.type == DetailPaneEntryType.discussion &&
        current?.discussion?.id == discussion.id) {
      return;
    }
    detailStack.add(
      DetailPaneEntry.discussion(
        entryId: _nextDetailEntryId(),
        discussion: discussion,
      ),
    );
  }

  void showUserDetail(int userId) {
    final current = currentDetail;
    if (current?.type == DetailPaneEntryType.user &&
        current?.userId == userId) {
      return;
    }
    detailStack.add(
      DetailPaneEntry.user(entryId: _nextDetailEntryId(), userId: userId),
    );
  }

  void showSettingsDetail() {
    if (currentDetail?.type == DetailPaneEntryType.settings) {
      return;
    }
    detailStack.add(DetailPaneEntry.settings(entryId: _nextDetailEntryId()));
  }

  DetailPaneEntry? get currentDetail {
    if (detailStack.isEmpty) return null;
    return detailStack.last;
  }

  bool get canPopDetail => detailStack.length > 1;

  void popDetail() {
    if (detailStack.isEmpty) return;
    final removed = detailStack.removeLast();
    _disposeDetailEntryLater(removed);
  }

  void closeDetail() {
    if (detailStack.isEmpty) return;
    final removedEntries = List<DetailPaneEntry>.from(detailStack);
    detailStack.clear();
    for (final entry in removedEntries) {
      _disposeDetailEntryLater(entry);
    }
  }

  void _disposeDetailEntryLater(DetailPaneEntry entry) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (entry.type) {
        case DetailPaneEntryType.discussion:
          final tag = "PostPage:${entry.discussion!.id}:true";
          if (Get.isRegistered<PostPageController>(tag: tag)) {
            Get.delete<PostPageController>(tag: tag);
          }
          break;
        case DetailPaneEntryType.user:
          final tag = "user_space:${entry.userId}";
          if (Get.isRegistered<UserPageController>(tag: tag)) {
            Get.delete<UserPageController>(tag: tag);
          }
          break;
        case DetailPaneEntryType.settings:
          break;
      }
    });
  }

  int _nextDetailEntryId() {
    _detailEntrySeed += 1;
    return _detailEntrySeed;
  }

  void openHomeSearch() {
    isHomeSearchActive.value = true;
    homeSearchKeyword.value = null;
  }

  void closeHomeSearch() {
    isHomeSearchActive.value = false;
    homeSearchKeyword.value = null;
  }

  void submitHomeSearch(String keyword) {
    isHomeSearchActive.value = true;
    if (homeSearchKeyword.value == keyword) {
      homeSearchKeyword.value = '';
      Future.microtask(() {
        homeSearchKeyword.value = keyword;
      });
      return;
    }
    homeSearchKeyword.value = keyword;
  }

  void editHomeSearch() {
    homeSearchKeyword.value = null;
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
