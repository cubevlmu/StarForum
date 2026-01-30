/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/pages/theme_list/controller.dart';
import 'package:forum/widgets/simple_easy_refresher.dart';
import 'package:get/get.dart';

class ThemeListPage extends StatefulWidget {
  const ThemeListPage({super.key});

  @override
  State<ThemeListPage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemeListPage> {
  late ThemeListController controller;

  @override
  void initState() {
    controller = Get.put(ThemeListController());
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ThemeListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleEasyRefresher(
      easyRefreshController: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoad,
      childBuilder: (context, physics) => ListView.builder(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        controller: controller.scrollController,
        physics: physics,
        padding: const EdgeInsets.all(0),
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          // final item = controller.items[index];
          // return PostCard(item: item);
          return Column(
            children: [
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => PostPage(item: item)),
              //     );
              //   },
              //   child: TopBarItem(item: item),
              // ),
              // body: SimpleEasyRefresher(
              //   easyRefreshController: controller.refreshController,
              //   onRefresh: controller.onRefresh,
              //   onLoad: controller.onLoad,
              //   childBuilder: (context, physics) {
              //     return ListView(
              //       physics: physics,
              //       children: [
              //         const SizedBox(height: 10),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 10),
              //           child: const TopBar(),
              //         ),
              //         const SizedBox(height: 20),
              //         const Padding(
              //           padding: EdgeInsets.symmetric(horizontal: 20),
              //           child: Text(
              //             "主题",
              //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //         const SizedBox(height: 10),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 15),
              //           child: PopularTopics(),
              //         ),
              //         const SizedBox(height: 20),
              //         const Padding(
              //           padding: EdgeInsets.symmetric(horizontal: 20),
              //           child: Text(
              //             "贴文",
              //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //         const SizedBox(height: 10),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 15),
              //           child: const PostListWidget(),
              //         ),
              //         const SizedBox(height: 20),
              //       ],
              //     );
              //   },
              // ),
              // if (index != controller.items.length - 1)
              //   const Divider(
              //     height: 1,
              //     thickness: 0.5,
              //     indent: 12,
              //     endIndent: 12,
              //   ),
            ],
          );
        },
      ),
    );
  }
}

// class TagItemWidget extends StatelessWidget {
//   final TagItem tag;
//   final int idx;

//   const TagItemWidget({super.key, required this.tag, required this.idx});

//   @override
//   Widget build(BuildContext context) {
//     // return Padding(
//     //   padding: const EdgeInsets.symmetric(horizontal: 16),
//     //   child: SingleChildScrollView(
//     //     scrollDirection: Axis.horizontal,
//     //     child: Row(
//     //       crossAxisAlignment: CrossAxisAlignment.center, // 居中
//     //       children: list.asMap().entries.map((entry) {
//     //         final i = entry.key;
//     //         final d = entry.value;
//     //         final selected = _selectedIndex == i;

//     //         return Padding(
//     //           padding: const EdgeInsets.only(right: 8),
//     //           child: InkWell(
//     //             borderRadius: BorderRadius.circular(10),
//     //             onTap: () => setState(() => _selectedIndex = i),
//     //             child:
//     //           ),
//     //         );
//     //       }),
//     //     ),
//     //   ),
//     // );
//     return Chip(
//       avatar: CircleAvatar(
//         radius: 10,
//         backgroundColor: selected ? Colors.white : Colors.grey.shade700,
//         child: Text(
//           .name[0],
//           style: TextStyle(
//             fontSize: 10,
//             color: selected ? Theme.of(context).primaryColor : Colors.white,
//           ),
//         ),
//       ),
//       label: Text(
//         d.name,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: selected
//               ? Colors.white
//               : Theme.of(context).textTheme.bodyMedium?.color,
//         ),
//       ),
//       backgroundColor: selected
//           ? Theme.of(context).primaryColor
//           : Theme.of(context).cardColor,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     );
//   }
// }
