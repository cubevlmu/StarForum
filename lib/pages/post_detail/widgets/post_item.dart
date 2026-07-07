/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/widgets/forum/forum_post_card.dart';
import 'package:star_forum/widgets/content_view.dart';
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
  bool _isLikeSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = widget.reply.user;
    final avatarUrl = user?.avatarUrl ?? "";
    final author = UserInfo.displayLabel(user, fallbackId: widget.reply.userId);
    final createdAt = widget.reply.editedAt.isEmpty
        ? widget.reply.createdAt
        : widget.reply.editedAt;
    final canInteract = !widget.isUserPage;
    final canOpenUser = canInteract && widget.reply.userId > 0;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FUITokens.pagePadding,
          FUITokens.gap4,
          FUITokens.pagePadding,
          FUITokens.gap4,
        ),
        child: ForumPostCard(
          author: author,
          avatarUrl: avatarUrl,
          meta: [if (createdAt.isNotEmpty) ForumMetaItem(label: createdAt)],
          content: ContentView(content: widget.reply.contentHtml),
          likeCount: widget.reply.likes,
          isLiked: widget.reply.isLiked,
          likeLabel: l10n.commonLike,
          replyLabel: l10n.postActionComment,
          likeLoading: _isLikeSubmitting,
          showReply: canInteract,
          onAuthorTap: canOpenUser
              ? () => FuiNavigation.openDetail(
                  context,
                  builder: (_) =>
                      UserPage(userId: widget.reply.userId, embedded: true),
                )
              : null,
          onLike: canInteract && !_isLikeSubmitting ? _handleLikePressed : null,
          onReply: canInteract ? () => _handleReplyPressed(context) : null,
        ),
      ),
    );
  }

  Future<void> _handleLikePressed() async {
    setState(() {
      _isLikeSubmitting = true;
    });

    try {
      final r = await ReplyUtil.addLikeToPost(widget.reply);
      if (r != null && mounted) {
        setState(() {
          widget.reply.likes = r.likes;
          widget.reply.isLiked = r.isLiked;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikeSubmitting = false;
        });
      }
    }
  }

  void _handleReplyPressed(BuildContext context) {
    final controller = Get.find<PostPageController>(
      tag: widget.controllerTag ?? "",
    );
    ReplyUtil.showAddReplySheet2(
      context: context,
      discussionId: controller.getId(),
      pi: widget.reply,
      newReplyItems: controller.newReplyItems,
      updateWidget: () {},
      scrollController: null,
    );
  }
}
