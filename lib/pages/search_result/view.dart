/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/search_result/controller.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shared_notice.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({
    super.key,
    required this.keyWord,
    this.embedded = false,
    this.onBack,
    this.onEditSearch,
  });

  final String keyWord;
  final bool embedded;
  final VoidCallback? onBack;
  final VoidCallback? onEditSearch;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  late SearchResultController controller;
  late final String _controllerTag;
  late final TextEditingController _keywordController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controllerTag = 'SearchResult:${widget.keyWord}:${widget.embedded}';
    controller = Get.isRegistered<SearchResultController>(tag: _controllerTag)
        ? Get.find<SearchResultController>(tag: _controllerTag)
        : Get.put(
            SearchResultController(keyWord: widget.keyWord),
            tag: _controllerTag,
          );
    _keywordController = TextEditingController(text: widget.keyWord);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.searchItems.isEmpty) controller.onRefresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    if (Get.isRegistered<SearchResultController>(tag: _controllerTag)) {
      Get.delete<SearchResultController>(tag: _controllerTag);
    }
    super.dispose();
  }

  void _goEdit() {
    if (widget.embedded) {
      widget.onEditSearch?.call();
      return;
    }
    Navigator.of(context).pushReplacement(
      FuiPageRoute(
        builder: (_) => SearchPage(defaultInputSearchWord: widget.keyWord),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final showSkeleton =
          controller.isInitialLoading.value && controller.searchItems.isEmpty;
      return FUIRefresh(
        controller: controller.refreshController,
        onLoad: controller.onLoad,
        onRefresh: controller.onRefresh,
        refreshOnStart: false,
        refreshEnabled: !showSkeleton,
        loadEnabled: !showSkeleton,
        childBuilder: (context, physics) {
          final effectivePhysics = showSkeleton
              ? const NeverScrollableScrollPhysics()
              : physics;
          return CustomScrollView(
            controller: controller.scrollController,
            physics: effectivePhysics,
            slivers: [
              if (showSkeleton)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: PostListLoadingSkeleton(),
                )
              else if (controller.searchItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: GestureDetector(
                    onTap: _goEdit,
                    child: NoticeWidget(
                      emoji: '🔍',
                      title: l10n.searchResultEmptyTitle,
                      tips: l10n.searchResultEmptyTips,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: ForumLayout.listItemPadding,
                      child: PostCard(item: controller.searchItems[index]),
                    ),
                    childCount: controller.searchItems.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        FUITokens.pagePadding,
        FUITokens.gap12,
        FUITokens.pagePadding,
        FUITokens.gap8,
      ),
      child: FuiPageHead(
        title: widget.keyWord,
        subtitle: AppLocalizations.of(context)!.searchStartHint,
        onNavigationPressed:
            widget.onBack ?? () => Navigator.of(context).maybePop(),
        actions: [
          FUIIconButton(
            icon: FUIIcons.search,
            variant: FUIIconButtonVariant.ghost,
            onPressed: _goEdit,
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          header,
          Expanded(child: _buildList(context)),
        ],
      );
    }
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            header,
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }
}
