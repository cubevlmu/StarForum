/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussion_item.dart';

import 'package:star_forum/pages/home/view.dart';
import 'package:star_forum/pages/notification/view.dart';
import 'package:star_forum/pages/theme_list/view.dart';
import 'package:star_forum/pages/account/view.dart';
import 'package:get/get.dart';

enum DetailPaneEntryType {
  discussion,
  user,
  settings,
  login,
  setup,
  image,
  editor,
}

@immutable
class DetailPaneEntry {
  const DetailPaneEntry._({
    required this.entryId,
    required this.type,
    this.discussion,
    this.userId,
    this.imageUrl,
    this.editorTitle,
    this.editorInitialContent,
    this.editorOnSubmitReply,
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

  const DetailPaneEntry.login({required int entryId})
    : this._(entryId: entryId, type: DetailPaneEntryType.login);

  const DetailPaneEntry.setup({required int entryId})
    : this._(entryId: entryId, type: DetailPaneEntryType.setup);

  const DetailPaneEntry.image({required int entryId, required String imageUrl})
    : this._(
        entryId: entryId,
        type: DetailPaneEntryType.image,
        imageUrl: imageUrl,
      );

  const DetailPaneEntry.editor({
    required int entryId,
    String? title,
    String? initialContent,
    Future<bool> Function(String content)? onSubmitReply,
  }) : this._(
         entryId: entryId,
         type: DetailPaneEntryType.editor,
         editorTitle: title,
         editorInitialContent: initialContent,
         editorOnSubmitReply: onSubmitReply,
       );

  final int entryId;
  final DetailPaneEntryType type;
  final DiscussionItem? discussion;
  final int? userId;
  final String? imageUrl;
  final String? editorTitle;
  final String? editorInitialContent;
  final Future<bool> Function(String content)? editorOnSubmitReply;
}

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;
  final RxList<DetailPaneEntry> detailStack = <DetailPaneEntry>[].obs;
  final RxBool isHomeSearchActive = false.obs;
  final RxnString homeSearchKeyword = RxnString();
  int _detailEntrySeed = 0;

  final List<Widget Function()> pageBuilders = [
    () => const HomePage(),
    () => const TagListPage(),
    () => const NotificationPage(),
    () => const AccountPage(),
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

  void showLoginDetail() {
    if (currentDetail?.type == DetailPaneEntryType.login) {
      return;
    }
    detailStack.add(DetailPaneEntry.login(entryId: _nextDetailEntryId()));
  }

  void showSetupDetail() {
    if (currentDetail?.type == DetailPaneEntryType.setup) {
      return;
    }
    detailStack.add(DetailPaneEntry.setup(entryId: _nextDetailEntryId()));
  }

  void showImageDetail(String imageUrl) {
    final current = currentDetail;
    if (current?.type == DetailPaneEntryType.image &&
        current?.imageUrl == imageUrl) {
      return;
    }
    detailStack.add(
        DetailPaneEntry.image(entryId: _nextDetailEntryId(), imageUrl: imageUrl),
    );
  }

  void showEditorDetail() {
    if (currentDetail?.type == DetailPaneEntryType.editor) {
      return;
    }
    detailStack.add(DetailPaneEntry.editor(entryId: _nextDetailEntryId()));
  }

  void showReplyEditorDetail({
    required String title,
    required String initialContent,
    required Future<bool> Function(String content) onSubmitReply,
  }) {
    detailStack.add(
      DetailPaneEntry.editor(
        entryId: _nextDetailEntryId(),
        title: title,
        initialContent: initialContent,
        onSubmitReply: onSubmitReply,
      ),
    );
  }

  DetailPaneEntry? get currentDetail {
    if (detailStack.isEmpty) return null;
    return detailStack.last;
  }

  bool get canPopDetail => detailStack.length > 1;

  void popDetail() {
    if (detailStack.isEmpty) return;
    detailStack.removeLast();
  }

  void closeDetail() {
    if (detailStack.isEmpty) return;
    detailStack.clear();
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
