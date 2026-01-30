/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/pages/post_detail/controller.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/avatar.dart';
import 'package:forum/widgets/content_view.dart';
import 'package:get/get.dart';

class PostMainWidget extends StatelessWidget {
  final DiscussionItem content;

  const PostMainWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserBox(item: content),
          IntroductionText(item: content),
          Divider(
            color: Theme.of(context).colorScheme.secondaryContainer,
            thickness: 1,
            height: 20,
          ),
        ],
      ),
    );
  }
}

class UserBox extends StatelessWidget {
  const UserBox({super.key, required this.item});
  final DiscussionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserPage(
              key: ValueKey("UserPage:${item.userId}"),
              userId: item.userId,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AvatarWidget(
              avatarUrl: item.authorAvatar,
              radius: 20,
              cacheWidthHeight: 200,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.authorName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 12,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    StringUtil.numFormat(item.viewCount),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 12,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.lastPostedAt.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IntroductionText extends StatelessWidget {
  const IntroductionText({super.key, required this.item});
  final DiscussionItem item;

  @override
  Widget build(BuildContext context) {
    final model = Get.find<PostPageController>();
    return SelectableRegion(
      magnifierConfiguration: const TextMagnifierConfiguration(),
      focusNode: FocusNode(),
      selectionControls: MaterialTextSelectionControls(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Obx(() => ContentView(content: model.content.value)),
            ),
          ],
        ),
      ),
    );
  }
}
