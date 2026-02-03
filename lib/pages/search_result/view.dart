/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/search/view.dart';
import 'package:forum/pages/search_result/controller.dart';
import 'package:forum/widgets/post_card.dart';
import 'package:forum/widgets/shared_notice.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key, required this.keyWord});
  final String keyWord;
  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  late SearchResultController controller;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    controller = Get.put(SearchResultController(keyWord: widget.keyWord));
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<SearchResultController>();
    super.dispose();
  }

  AppBar _appBar(BuildContext context, SearchResultController controller) {
    return AppBar(
      shape: UnderlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: widget.keyWord),
              readOnly: true,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none),
              onTap: () {
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
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onLoad: controller.onLoad,
      onRefresh: controller.onRefresh,
      childBuilder: (context, physics) {
        return CustomScrollView(
          controller: controller.scrollController,
          physics: physics,
          slivers: [
            if (controller.searchItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      GetPageRoute(
                        page: () =>
                            SearchPage(defaultInputSearchWord: widget.keyWord),
                      ),
                    );
                  },
                  child: Obx(() {
                    return controller.isSearching.value
                        ? const SizedBox.shrink()
                        : NoticeWidget(
                            emoji: "🔍",
                            title: "没有找到相关内容",
                            tips: "换个关键词试试吧",
                          );
                  }),
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _appBar(context, controller),
      body: _buildView(context),
    );
  }
}
