/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */



import 'package:flutter/material.dart';
import 'package:forum/pages/search_result/view.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  SearchPageController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode textFeildFocusNode = FocusNode();
  late String defaultSearchWord;
  
  final RxBool showEditDelete = false.obs;
  final RxList<String> historySearchedWords = <String>[].obs;

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
      _saveSearchedWord(keyWord.trim());
      Navigator.of(Get.context!).pushReplacement(
        GetPageRoute(
          page: () => SearchResultPage(
            key: ValueKey('SearchResultPage:$keyWord'),
            keyWord: keyWord,
          ),
        ),
      );
    } else if (keyWord.isEmpty && defaultSearchWord.isNotEmpty) {
      setTextFieldText(defaultSearchWord);
      search(defaultSearchWord);
    }
  }

  Future<void> _refreshHistoryWord() async {
    var box = StorageUtils.history;
    // List<Widget> widgetList = [];
    // List<dynamic> list = ;
    // for (String i in list.reversed) {
    //   widgetList.add(
    //     
    // }
    final items = box.get("searchHistory", defaultValue: <String>[]).reversed;
    historySearchedWords.clear();
    historySearchedWords.addAll(items);
  }

  Future<void> _saveSearchedWord(String keyWord) async {
    var box = StorageUtils.history;
    List<dynamic> list = box.get("searchHistory", defaultValue: <String>[]);
    if (!list.contains(keyWord)) {
      list.add(keyWord);
      box.put("searchHistory", list);
    }
    _refreshHistoryWord();
  }

  Future<void> clearAllSearchedWords() async {
    var box = StorageUtils.history;
    box.put("searchHistory", <String>[]);
    _refreshHistoryWord();
  }

  Future<void> deleteSearchedWord(String word) async {
    var box = StorageUtils.history;
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

  Future<void> _initData() async {
    _refreshHistoryWord();
    textFeildFocusNode.addListener(() {
      if (textFeildFocusNode.hasFocus &&
          textEditingController.text.isNotEmpty) {
        showEditDelete.value = true;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }
}
