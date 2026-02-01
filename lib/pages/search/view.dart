/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/search/controller.dart';
import 'package:forum/utils/setting_util.dart';
import 'package:forum/utils/storage_utils.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.defaultInputSearchWord});
  final String? defaultInputSearchWord;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchPageController controller;
  @override
  void initState() {
    controller = Get.put(SearchPageController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<SearchPageController>();
    super.dispose();
  }

  Widget _defaultHintView() {
    final showSearchHistory = SettingsUtil.getValue(
      SettingsStorageKeys.showSearchHistory,
      defaultValue: true,
    );

    if (!showSearchHistory) {
      return const Center(child: Text("开始搜索吧 👀"));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            const Text(
              "搜索历史",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: controller.clearAllSearchedWords,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.historySearchedWords.value,
          ),
        ),
      ],
    );
  }

  Widget _searchHintView() {
    return Obx(() => ListView(children: controller.searchSuggestionItems));
  }

  Widget _viewSelecter() {
    return Obx(() {
      if (controller.showSearchSuggest.value) {
        return _searchHintView();
      } else {
        return _defaultHintView();
      }
    });
  }

  void _init() {
    controller.defaultSearchWord = "";
    if (widget.defaultInputSearchWord != null) {
      controller.textEditingController.text = widget.defaultInputSearchWord!;
    }
  }

  Widget _buildView() {
    _init();
    return Container(child: _viewSelecter());
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      shape: UnderlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: controller.textFeildFocusNode,
                    controller: controller.textEditingController,
                    onChanged: controller.onSearchWordChanged,
                    autofocus: true,
                    onEditingComplete: () {
                      controller.search(controller.textEditingController.text);
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      suffixIcon: Obx(
                        () => Offstage(
                          offstage: controller.showEditDelete.isFalse,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              controller.textEditingController.clear();
                              controller.showEditDelete.value = false;
                              controller.showSearchSuggest.value = false;
                            },
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: "",
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: IconButton(
              onPressed: () {
                controller.search(controller.textEditingController.text);
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(child: _buildView()),
    );
  }
}
