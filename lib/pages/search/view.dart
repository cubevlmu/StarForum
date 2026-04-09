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
    final l10n = AppLocalizations.of(context)!;
    final showSearchHistory = SettingsUtil.getValue(
      SettingsStorageKeys.showSearchHistory,
      defaultValue: true,
    );

    if (!showSearchHistory) {
      return Center(child: Text(l10n.searchStartHint));
    }

    return Obx(() {
      final history = controller.historySearchedWords;
      if (history.isEmpty) {
        return _SearchEmptyView(
          title: l10n.searchHistoryTitle,
          message: l10n.searchStartHint,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: history.length + 1,
        separatorBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(height: 4);
          }
          return const Divider(height: 1, thickness: 0.5);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SearchHistoryHeader(
              title: l10n.searchHistoryTitle,
              onClear: controller.clearAllSearchedWords,
            );
          }

          final word = history[index - 1];
          return _SearchHistoryItem(
            word: word,
            onTap: () {
              controller.setTextFieldText(word);
              controller.search(word);
            },
            onDelete: () => controller.deleteSearchedWord(word),
          );
        },
      );
    });
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

class _SearchHistoryHeader extends StatelessWidget {
  const _SearchHistoryHeader({required this.title, required this.onClear});

  final String title;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(AppLocalizations.of(context)!.searchHistoryClearAction),
          ),
        ],
      ),
    );
  }
}

class _SearchHistoryItem extends StatelessWidget {
  const _SearchHistoryItem({
    required this.word,
    required this.onTap,
    required this.onDelete,
  });

  final String word;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history_rounded),
      title: Text(word, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.close_rounded),
        tooltip: AppLocalizations.of(context)!.searchHistoryDeleteAction,
      ),
      onTap: onTap,
    );
  }
}

class _SearchEmptyView extends StatelessWidget {
  const _SearchEmptyView({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
