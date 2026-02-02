/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:forum/data/model/discussion_item.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/pages/post_detail/controller.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/avatar.dart';
import 'package:forum/widgets/content_view.dart';
import 'package:get/get.dart';

class PostMainWidget extends StatelessWidget {
  final DiscussionItem content;
  final PostInfo? info;

  const PostMainWidget({super.key, required this.content, required this.info});

  @override
  Widget build(BuildContext context) {
    // final like = info?.likes ?? -1;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserBox(item: content),
          _MainContent(item: content),
          // const SizedBox(height: 5),
          // like == -1
          //     ? const SizedBox.shrink()
          //     : _ThumUpButton(
          //         likeNum: like,
          //         selected: false,
          //         onPressed: () async {
          //           if (info == null) return;
          //           final r = await ReplyUtil.addLikeToPost(info!);
          //           if (r != null) {
          //             info?.likes = r.likes;
          //           }
          //         },
          //       ),
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

class _UserBox extends StatelessWidget {
  const _UserBox({required this.item});
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

class _MainContent extends StatelessWidget {
  const _MainContent({required this.item});
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

class _ThumUpButton extends StatelessWidget {
  const _ThumUpButton({
    required this.onPressed,
    required this.likeNum,
    this.selected = false,
  });
  final Function()? onPressed;
  final bool selected;
  final int likeNum;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        visualDensity: VisualDensity.comfortable,
        padding: const WidgetStatePropertyAll(EdgeInsets.all(5)),
        foregroundColor: selected == true
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary)
            : null,
        backgroundColor: selected == true
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)
            : null,
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size(10, 5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.thumb_up_rounded, size: 15),
          const SizedBox(width: 5),
          Text(StringUtil.numFormat(likeNum)),
        ],
      ),
    );
  }
}
