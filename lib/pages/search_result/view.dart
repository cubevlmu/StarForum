/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/search/view.dart';
import 'package:star_forum/pages/search_result/controller.dart';
import 'package:star_forum/widgets/post_card.dart';
import 'package:star_forum/widgets/shared_notice.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

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
    _controllerTag = "SearchResult:${widget.keyWord}:${widget.embedded}";
    controller = Get.put(
      SearchResultController(keyWord: widget.keyWord),
      tag: _controllerTag,
    );
    _keywordController = TextEditingController(text: widget.keyWord);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.searchItems.isEmpty) {
        controller.onRefresh();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    Get.delete<SearchResultController>(tag: _controllerTag);
    super.dispose();
  }

  AppBar _appBar(BuildContext context, SearchResultController controller) {
    return AppBar(
      automaticallyImplyLeading: !widget.embedded,
      leading: widget.embedded
          ? IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_outlined),
            )
          : null,
      shape: UnderlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _keywordController,
              readOnly: true,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none),
              onTap: () {
                if (widget.embedded) {
                  widget.onEditSearch?.call();
                  return;
                }
                Navigator.of(context).pushReplacement(
                  GetPageRoute(
                    page: () => SearchPage(
                      // defaultHintSearchWord: widget.keyWord,
                      defaultInputSearchWord: widget.keyWord,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: 70,
            child: IconButton(
              onPressed: () {
                // controller.refreshController.callRefresh();
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      final showSkeleton =
          controller.isInitialLoading.value && controller.searchItems.isEmpty;
      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onLoad: controller.onLoad,
        onRefresh: controller.onRefresh,
        autoRefreshOnStart: false,
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
                const SliverToBoxAdapter(child: _SearchResultLoadingSkeleton())
              else if (controller.searchItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.embedded) {
                        widget.onEditSearch?.call();
                        return;
                      }
                      Navigator.of(context).pushReplacement(
                        GetPageRoute(
                          page: () => SearchPage(
                            defaultInputSearchWord: widget.keyWord,
                          ),
                        ),
                      );
                    },
                    child: NoticeWidget(
                      emoji: "🔍",
                      title: l10n.searchResultEmptyTitle,
                      tips: l10n.searchResultEmptyTips,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final i = controller.searchItems[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: PostCard(item: i.toItem()),
                        ),
                        if (index != controller.searchItems.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 12,
                            endIndent: 12,
                          ),
                      ],
                    );
                  }, childCount: controller.searchItems.length),
                ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.embedded) {
      return Column(
        children: [
          _appBar(context, controller),
          Expanded(child: _buildView(context)),
        ],
      );
    }
    return Scaffold(
      appBar: _appBar(context, controller),
      body: _buildView(context),
    );
  }
}

class _SearchResultLoadingSkeleton extends StatelessWidget {
  const _SearchResultLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      duration: const Duration(milliseconds: 1450),
      highlightStrength: 0.18,
      builder: (context, palette) {
        return Column(
          children: List<Widget>.generate(
            4,
            (index) => _SearchResultLoadingCard(
              pillDecoration: palette.line(),
              circleDecoration: palette.circle(),
            ),
          ),
        );
      },
    );
  }
}

class _SearchResultLoadingCard extends StatelessWidget {
  const _SearchResultLoadingCard({
    required this.pillDecoration,
    required this.circleDecoration,
  });

  final Decoration pillDecoration;
  final Decoration circleDecoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: circleDecoration,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBar(
                            decoration: pillDecoration,
                            widthFactor: 0.28,
                            height: 12,
                          ),
                          const SizedBox(height: 8),
                          SkeletonBar(
                            decoration: pillDecoration,
                            widthFactor: 0.18,
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SkeletonBar(
                  decoration: pillDecoration,
                  widthFactor: 0.9,
                  height: 16,
                ),
                const SizedBox(height: 10),
                SkeletonBar(
                  decoration: pillDecoration,
                  widthFactor: 0.82,
                  height: 12,
                ),
                const SizedBox(height: 8),
                SkeletonBar(
                  decoration: pillDecoration,
                  widthFactor: 0.68,
                  height: 12,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 28,
                      decoration: pillDecoration,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 54,
                      height: 28,
                      decoration: pillDecoration,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
