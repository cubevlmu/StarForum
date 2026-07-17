/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/pages/post_detail/controller.dart';
import 'package:star_forum/pages/post_detail/reply_util.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/widgets/forum/forum_post_card.dart';
import 'package:star_forum/widgets/forum/forum_post_event_tile.dart';
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
  late PostInfo _reply;

  @override
  void initState() {
    super.initState();
    _reply = widget.reply;
  }

  @override
  void didUpdateWidget(covariant PostItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reply != widget.reply) _reply = widget.reply;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _reply.user;
    final avatarUrl = user?.avatarUrl ?? "";
    final author = UserInfo.displayLabel(user, fallbackId: _reply.userId);
    final createdAt = _reply.editedAt.isEmpty
        ? _reply.createdAt
        : _reply.editedAt;
    final canInteract = !widget.isUserPage;
    final canOpenUser = canInteract && _reply.userId > 0;

    if (_reply.event case final event?) {
      return RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FUITokens.pagePadding,
            FUITokens.gap4,
            FUITokens.pagePadding,
            FUITokens.gap4,
          ),
          child: ForumPostEventTile(
            icon: switch (event.type) {
              PostEventType.discussionStickyChanged => ForumIcons.sticky,
              PostEventType.discussionStickiestChanged =>
                ForumIcons.superSticky,
              PostEventType.discussionLockChanged =>
                event.locked ? ForumIcons.locked : ForumIcons.unlocked,
              PostEventType.commentContentUnavailable => FUIIcons.warning,
              PostEventType.unsupported => ForumIcons.code,
            },
            label: switch (event.type) {
              PostEventType.discussionStickyChanged =>
                event.sticky
                    ? l10n.discussionPinnedLabel
                    : l10n.discussionUnpinnedLabel,
              PostEventType.discussionStickiestChanged =>
                event.sticky
                    ? l10n.discussionSuperPinnedLabel
                    : l10n.discussionSuperUnpinnedLabel,
              PostEventType.discussionLockChanged =>
                event.locked
                    ? l10n.discussionLockedLabel
                    : l10n.discussionUnlockedLabel,
              PostEventType.commentContentUnavailable =>
                l10n.postReplyContentUnavailable,
              PostEventType.unsupported => l10n.postEventUnsupported(
                event.sourceType,
              ),
            },
            meta: [
              ForumMetaItem(label: author),
              if (createdAt.isNotEmpty) ForumMetaItem(label: createdAt),
            ],
          ),
        ),
      );
    }

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
          content: ContentView(content: _reply.contentHtml),
          likeCount: _reply.likes,
          isLiked: _reply.isLiked,
          likeLabel: l10n.commonLike,
          replyLabel: l10n.postActionComment,
          likeLoading: _isLikeSubmitting,
          showReply: canInteract,
          onAuthorTap: canOpenUser
              ? () => FuiNavigation.openDetail(
                  context,
                  builder: (_) =>
                      UserPage(userId: _reply.userId, embedded: true),
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
      final r = await ReplyUtil.toggleLikeForPost(_reply);
      if (r != null && mounted) {
        setState(() {
          _reply = _reply.copyWith(likes: r.likes, isLiked: r.isLiked);
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
      pi: _reply,
      newReplyItems: controller.newReplyItems,
      updateWidget: controller.onReplyCreated,
      scrollController: null,
    );
  }
}
