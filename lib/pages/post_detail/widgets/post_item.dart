/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forum/data/api/api.dart';
import 'package:forum/data/model/posts.dart';
import 'package:forum/data/repository/user_repo.dart';
import 'package:forum/di/injector.dart';
import 'package:forum/pages/post_detail/controller.dart';
import 'package:forum/pages/post_detail/reply_util.dart';
import 'package:forum/pages/user/view.dart';
import 'package:forum/utils/snackbar_utils.dart';
import 'package:forum/utils/string_util.dart';
import 'package:forum/widgets/avatar.dart';
import 'package:forum/widgets/content_view.dart';
import 'package:forum/widgets/icon_text_button.dart';
import 'package:get/get.dart';

class PostItemWidget extends StatefulWidget {
  const PostItemWidget({
    super.key,
    required this.reply,
    this.isUserPage = false,
  });
  final PostInfo reply;
  final bool isUserPage;

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
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(),
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
                        top: 0,
                        bottom: 0,
                        left: 5,
                      ),
                      child: Row(
                        children: [
                          StatefulBuilder(
                            builder: (context, setState) {
                              return ThumUpButton(
                                likeNum: widget.reply.likes,
                                selected: false,
                                onPressed: widget.isUserPage ? null : () async {
                                  final r = await addLikeToPost(widget.reply);
                                  if (r != null) {
                                    widget.reply.likes = r.likes;
                                    setState(() {});
                                  }
                                },
                              );
                            },
                          ),
                          if (!widget.isUserPage)
                            AddReplyButton(
                              postItem: widget.reply,
                              updateWidget: () {
                                // widget.reply.++;
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

class ThumUpButton extends StatelessWidget {
  const ThumUpButton({
    super.key,
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

class AddReplyButton extends StatelessWidget {
  const AddReplyButton({
    super.key,
    required this.postItem,
    required this.updateWidget,
  });
  final PostInfo postItem;
  final Function() updateWidget;

  @override
  Widget build(BuildContext context) {
    return IconTextButton(
      onPressed: () async {
        final controller = Get.find<PostPageController>();
        ReplyUtil.showAddReplySheet2(
          discussionId: controller.getId(),
          pi: postItem,
          newReplyItems: controller.replyItems,
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

Future<PostInfo?> addLikeToPost(PostInfo item) async {
  final repo = getIt<UserRepo>();
  if (!repo.isLogin) {
    SnackbarUtils.showMessage("请先登录!");
    return null;
  }

  try {
    final (r, rs) = await Api.likePost(item.id.toString(), true);
    if (!rs) {
      repo.logout();
      SnackbarUtils.showMessage("登录过期!");
      return null;
    }

    if (r == null) {
      log("[PostItem] failed to like post with empty response");
      SnackbarUtils.showMessageWithTitle("点赞失败", "可能是网络错误");
      return null;
    }

    SnackbarUtils.showMessage(r.likes < item.likes ? "取消点赞成功!" : "点赞成功!");
    return r;
  } catch (e) {
    log("[PostItem] failed to like post with id :${item.id}");
  }
  return null;
}
