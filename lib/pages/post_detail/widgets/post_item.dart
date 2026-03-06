/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:star_forum/widgets/content_view.dart';
import 'package:star_forum/widgets/icon_text_button.dart';
import 'package:get/get.dart';

class PostItemWidget extends StatefulWidget {
  const PostItemWidget({
    super.key,
    required this.reply,
    this.isUserPage = false,
    this.controllerTag,
  });
  final PostInfo reply;
  final bool isUserPage;
  final String? controllerTag;

  @override
  State<PostItemWidget> createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AvatarWidget(
                    avatarUrl: widget.reply.user?.avatarUrl ?? "",
                    radius: 45 / 2,
                    onPressed: () {
                      if (widget.isUserPage) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserPage(
                            key: ValueKey("UserPage:${widget.reply.userId}"),
                            userId: widget.reply.userId,
                          ),
                        ),
                      );
                    },
                    cacheWidthHeight: 200,
                    placeholder: widget.reply.user?.displayName[0] ?? "",
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.isUserPage) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserPage(
                                key: ValueKey(
                                  "UserPage:${widget.reply.userId}",
                                ),
                                userId: widget.reply.userId,
                              ),
                            ),
                          );
                        },

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.reply.user?.displayName ?? "",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(
                                    widget.reply.editedAt.isEmpty
                                        ? widget.reply.createdAt
                                        : widget.reply.editedAt,
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        right: 10,
                        left: 10,
                      ),
                      child: ContentView(content: widget.reply.contentHtml),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 0,
                        left: 5,
                      ),
                      child: Row(
                        children: [
                          StatefulBuilder(
                            builder: (context, setState) {
                              return _ThumUpButton(
                                likeNum: widget.reply.likes,
                                selected: false,
                                onPressed: widget.isUserPage
                                    ? null
                                    : () async {
                                        final r = await ReplyUtil.addLikeToPost(
                                          widget.reply,
                                        );
                                        if (r != null) {
                                          widget.reply.likes = r.likes;
                                          setState(() {});
                                        }
                                      },
                              );
                            },
                          ),
                          if (!widget.isUserPage)
                            _ReplyButton(
                              postItem: widget.reply,
                              controllerTag: widget.controllerTag ?? "",
                              updateWidget: () {
                                setState(() => ());
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
    final textTheme = Theme.of(context).textTheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        foregroundColor: selected == true
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary)
            : null,
        backgroundColor: selected == true
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)
            : null,
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size(40, 36)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.thumb_up_rounded, size: 16),
          const SizedBox(width: 6),
          Text(StringUtil.numFormat(likeNum), style: textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ReplyButton extends StatelessWidget {
  const _ReplyButton({
    required this.postItem,
    required this.controllerTag,
    required this.updateWidget,
  });
  final PostInfo postItem;
  final String controllerTag;
  final Function() updateWidget;

  @override
  Widget build(BuildContext context) {
    return IconTextButton(
      onPressed: () async {
        final controller = Get.find<PostPageController>(tag: controllerTag);
        ReplyUtil.showAddReplySheet2(
          context: context,
          discussionId: controller.getId(),
          pi: postItem,
          newReplyItems: controller.newReplyItems,
          updateWidget: updateWidget,
          scrollController: null,
        );
      },
      icon: const Padding(
        padding: EdgeInsets.all(2.0),
        child: Icon(Icons.reply, size: 15),
      ),
      text: null,
    );
  }
}
