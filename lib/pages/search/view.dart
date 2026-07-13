/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/search/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/utils/setting_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/widgets/shared_dialog.dart';

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
    _controllerTag = 'SearchPage:${widget.embedded}:${identityHashCode(this)}';
    controller = Get.put(SearchPageController(), tag: _controllerTag);
    controller.onSearchRequested = widget.onSearchRequested;
    controller.defaultSearchWord = '';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final body = Column(
      children: [
        _SearchBar(
          controller: controller,
          embedded: widget.embedded,
          onClose: widget.onClose ?? () => Navigator.of(context).maybePop(),
        ),
        Expanded(child: _HistoryBody(controller: controller)),
      ],
    );

    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(child: body),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.embedded,
    required this.onClose,
  });

  final SearchPageController controller;
  final bool embedded;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap12,
        FUITokens.pagePadding,
        FUITokens.gap8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 44,
            child: FUIIconButton(
              icon: FUIIcons.chevronLeft,
              size: 44,
              variant: FUIIconButtonVariant.outline,
              onPressed: onClose,
            ),
          ),
          const SizedBox(width: FUITokens.gap10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                focusNode: controller.textFeildFocusNode,
                controller: controller.textEditingController,
                onChanged: controller.onSearchWordChanged,
                autofocus: false,
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchStartHint,
                  filled: true,
                  fillColor: colors.surface,
                  prefixIcon: Icon(
                    FUIIcons.search,
                    size: FUITokens.iconMd,
                    color: colors.textTertiary,
                  ),
                  suffixIcon: Obx(
                    () => controller.showEditDelete.isTrue
                        ? FUIIconButton(
                            icon: FUIIcons.close,
                            onPressed: () {
                              controller.textEditingController.clear();
                              controller.showEditDelete.value = false;
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                    borderSide: BorderSide(color: colors.primary, width: 1.4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onEditingComplete: () =>
                    controller.search(controller.textEditingController.text),
              ),
            ),
          ),
          const SizedBox(width: FUITokens.gap8),
          SizedBox.square(
            dimension: 44,
            child: FUIIconButton(
              icon: FUIIcons.search,
              tooltip: AppLocalizations.of(context)!.searchStartHint,
              size: 44,
              variant: FUIIconButtonVariant.soft,
              onPressed: () =>
                  controller.search(controller.textEditingController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.controller});

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    final showHistory = SettingsUtil.getValue(
      SettingsStorageKeys.showSearchHistory,
      defaultValue: true,
    );
    if (!showHistory) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.searchStartHint,
          style: TextStyle(color: context.colors.textTertiary, fontSize: 13),
        ),
      );
    }

    return Obx(() {
      final history = controller.historySearchedWords;
      final l10n = AppLocalizations.of(context)!;

      if (history.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FUIIcons.search,
                size: 40,
                color: context.colors.textTertiary,
              ),
              const SizedBox(height: FUITokens.gap12),
              Text(
                l10n.searchHistoryTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: FUITokens.gap6),
              Text(
                l10n.searchStartHint,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(
          FUITokens.pagePadding,
          FUITokens.gap4,
          FUITokens.pagePadding,
          FUITokens.gap24,
        ),
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 0, FUITokens.gap8),
            child: Row(
              children: [
                Text(
                  l10n.searchHistoryTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
                const Spacer(),
                FUIIconButton(
                  icon: FUIIcons.delete,
                  variant: FUIIconButtonVariant.ghost,
                  tooltip: l10n.searchHistoryClearAction,
                  onPressed: () => _confirmClear(context, l10n, controller),
                ),
              ],
            ),
          ),
          FUISurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < history.length; i++) ...[
                  if (i != 0) Divider(height: 1, color: context.colors.border),
                  FUITile(
                    title: history[i],
                    icon: Icons.history_rounded,
                    showChevron: false,
                    trailing: FUIIconButton(
                      icon: FUIIcons.close,
                      onPressed: () =>
                          controller.deleteSearchedWord(history[i]),
                    ),
                    onTap: () {
                      controller.setTextFieldText(history[i]);
                      controller.search(history[i]);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  void _confirmClear(
    BuildContext context,
    AppLocalizations l10n,
    SearchPageController controller,
  ) {
    SharedDialog.showDialog2(
      context,
      l10n.dialogConfirmTitle,
      l10n.searchHistoryClearConfirm,
      l10n.dialogNo,
      () => Navigator.pop(context),
      l10n.dialogYes,
      () {
        Navigator.pop(context);
        controller.clearAllSearchedWords();
      },
    );
  }
}
