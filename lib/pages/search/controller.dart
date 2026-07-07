/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/pages/search_result/view.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  SearchPageController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode textFeildFocusNode = FocusNode();
  late String defaultSearchWord;

  final RxBool showEditDelete = false.obs;
  final RxList<String> historySearchedWords = <String>[].obs;
  final box = StorageUtils.history;
  ValueChanged<String>? onSearchRequested;
  bool _isClosed = false;

  void onSearchWordChanged(String keyWord) {
    if (keyWord.isNotEmpty) {
      showEditDelete.value = true;
    } else {
      showEditDelete.value = false;
    }
  }

  void search(String keyWord) {
    if (keyWord.trim().isNotEmpty) {
      LogUtil.debug("[SearchPage] user trigger search with keyword : $keyWord");
      final safeKeyWord = keyWord.trim();
      _saveSearchedWord(safeKeyWord);
      if (onSearchRequested != null) {
        onSearchRequested!.call(safeKeyWord);
        return;
      }
      Navigator.of(Get.context!).pushReplacement(
        FuiPageRoute(
          builder: (_) => SearchResultPage(
            key: ValueKey('SearchResultPage:$safeKeyWord'),
            keyWord: safeKeyWord,
          ),
        ),
      );
    } else if (keyWord.isEmpty && defaultSearchWord.isNotEmpty) {
      setTextFieldText(defaultSearchWord);
      search(defaultSearchWord);
    }
  }

  Future<void> _refreshHistoryWord() async {
    final items = box.get("searchHistory", defaultValue: <String>[]).reversed;
    historySearchedWords.clear();
    historySearchedWords.addAll(items);
  }

  Future<void> _saveSearchedWord(String keyWord) async {
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    if (!list.contains(keyWord)) {
      list.add(keyWord);
      box.put("searchHistory", list);
    }
    _refreshHistoryWord();
  }

  Future<void> clearAllSearchedWords() async {
    box.put("searchHistory", <String>[]);
    _refreshHistoryWord();
  }

  Future<void> deleteSearchedWord(String word) async {
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    list.remove(word);
    box.put("searchHistory", list);
    _refreshHistoryWord();
  }

  void setTextFieldText(String text) {
    textEditingController.text = text;
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  void _initData() {
    _refreshHistoryWord();
    textFeildFocusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (_isClosed) return;
    if (textFeildFocusNode.hasFocus && textEditingController.text.isNotEmpty) {
      showEditDelete.value = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onClose() {
    _isClosed = true;
    textFeildFocusNode.removeListener(_handleFocusChanged);
    textEditingController.dispose();
    textFeildFocusNode.dispose();
    onSearchRequested = null;
    super.onClose();
  }
}
