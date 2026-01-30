/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/search/view.dart';
import 'package:forum/pages/search_result/controller.dart';
import 'package:forum/widgets/post_card.dart';
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
    // bottom: TabBar(
    //     controller: controller.tabController,
    //     onTap: (value) {
    //       if (controller.currentSelectedTabIndex == value) {
    //         //移动到顶部
    //         // Get.find<SearchTabViewController>(
    //         //         tag: controller.getTabTagNameByIndex(value))
    //         //     .animateToTop();
    //       }
    //       controller.currentSelectedTabIndex = value;
    //       controller.tabController.animateTo(value);
    //     },
    //     tabs: [
    //       // for (var i in SearchType.values)
    //       //   Tab(
    //       //     text: i.name,
    //       //   ),
    //     ]
    //     ));
  }

  Widget _buildView(BuildContext context) {
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onLoad: controller.onLoad,
      onRefresh: controller.onRefresh,
      childBuilder: (context, physics) => ListView.builder(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        controller: controller.scrollController,
        padding: const EdgeInsets.all(0),
        physics: physics,
        itemCount: controller.searchItems.length,
        itemBuilder: (context, index) {
          final i = controller.searchItems[index];
          return Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(left: 8, right: 8),
                child: PostCard(
                  item: DiscussionItem(
                    id: i.id,
                    title: i.title,
                    excerpt: i.firstPost?.contentHtml ?? "",
                    lastPostedAt: DateTime.parse(i.lastPostedAt),
                    authorAvatar: i.user?.avatarUrl ?? "",
                    authorName: i.user?.displayName ?? "",
                    viewCount: i.views,
                    commentCount: i.commentCount,
                  ),
                ),
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
        },
      ),
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
