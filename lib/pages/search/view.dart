/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/search/controller.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.defaultInputSearchWord,
    this.embedded = false,
    this.onClose,
    this.onSearchRequested,
  });
  final String? defaultInputSearchWord;
  final bool embedded;
  final VoidCallback? onClose;
  final ValueChanged<String>? onSearchRequested;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchPageController controller;
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag =
        "SearchPage:${widget.embedded}:${widget.defaultInputSearchWord ?? ""}:${identityHashCode(this)}";
    controller = Get.put(
      SearchPageController(),
      tag: _controllerTag,
      permanent: false,
    );
    controller.onSearchRequested = widget.onSearchRequested;

    controller.defaultSearchWord = "";
    if (widget.defaultInputSearchWord != null) {
      controller.textEditingController.text = widget.defaultInputSearchWord!;
    }
  }

  @override
  void dispose() {
    controller.onSearchRequested = null;
    if (Get.isRegistered<SearchPageController>(tag: _controllerTag)) {
      Get.delete<SearchPageController>(tag: _controllerTag);
    }
    super.dispose();
  }

  Widget _defaultHintView() {
    final showSearchHistory = SettingsUtil.getValue(
      SettingsStorageKeys.showSearchHistory,
      defaultValue: true,
    );

    if (!showSearchHistory) {
      return Center(child: Text(AppLocalizations.of(context)!.searchStartHint));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.searchHistoryTitle,
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
            // ⭐ 很适合 Chip
            spacing: 8,
            runSpacing: 8,
            children: controller.historySearchedWords.map((word) {
              return GestureDetector(
                onTap: () {
                  controller.search(word);
                  controller.setTextFieldText(word);
                },
                child: Chip(
                  label: Text(word),
                  onDeleted: () {
                    controller.deleteSearchedWord(word);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: !widget.embedded,
      leading: widget.embedded
          ? IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.arrow_back_outlined),
            )
          : null,
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
    if (widget.embedded) {
      return Column(
        children: [
          _appBar(context),
          Expanded(
            child: SafeArea(
              top: false,
              child: Container(child: _defaultHintView()),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(child: Container(child: _defaultHintView())),
    );
  }
}
