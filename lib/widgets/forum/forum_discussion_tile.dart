/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/widgets/forum/forum_discussion_tags.dart';
import 'package:star_forum/widgets/forum/forum_user_avatar.dart';

class ForumDiscussionTile extends StatelessWidget {
  const ForumDiscussionTile({
    super.key,
    required this.title,
    this.excerpt,
    this.author,
    this.avatarUrl,
    this.avatar,
    this.tags = const [],
    this.meta = const [],
    this.replyCount,
    this.lastActivity,
    this.unread = false,
    this.pinned = false,
    this.compact = false,
    this.onTap,
  });

  final String title;
  final String? excerpt;
  final String? author;
  final String? avatarUrl;
  final ImageProvider? avatar;
  final List<String> tags;
  final List<ForumMetaItem> meta;
  final int? replyCount;
  final String? lastActivity;
  final bool unread;
  final bool pinned;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FUISurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unread)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FUITokens.radiusLg),
                  topRight: Radius.circular(FUITokens.radiusLg),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(
              compact ? FUITokens.gap12 : FUITokens.gap14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!compact) ...[
                  ForumUserAvatar(
                    name: author,
                    avatarUrl: avatarUrl,
                    image: avatar,
                    size: 36,
                  ),
                  const SizedBox(width: FUITokens.gap12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tags.isNotEmpty) ...[
                        ForumDiscussionTags(tags: tags),
                        const SizedBox(height: FUITokens.gap8),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pinned) ...[
                            Tooltip(
                              message:
                                  AppLocalizations.of(
                                    context,
                                  )?.discussionPinnedLabel ??
                                  'Pinned discussion',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Icon(
                                  ForumIcons.sticky,
                                  size: compact ? 15 : 16,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: FUITokens.gap6),
                          ],
                          Expanded(
                            child: Text(
                              title,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: compact ? 13 : 14,
                                height: 1.3,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (excerpt != null &&
                          excerpt!.isNotEmpty &&
                          !compact) ...[
                        const SizedBox(height: FUITokens.gap6),
                        Text(
                          excerpt!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: FUITokens.gap10),
                      Row(
                        children: [
                          Expanded(
                            child: ForumMetaRow(
                              items: [
                                if (author != null)
                                  ForumMetaItem(label: author!),
                                ...meta,
                              ],
                              singleLine: true,
                              flexibleItemIndex: author == null ? null : 0,
                            ),
                          ),
                          if (replyCount != null) ...[
                            const SizedBox(width: FUITokens.gap8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FUITokens.gap8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: unread
                                    ? colors.primarySoft
                                    : colors.surfaceAlt,
                                borderRadius: BorderRadius.circular(
                                  FUITokens.radiusFull,
                                ),
                                border: Border.all(
                                  color: unread
                                      ? colors.primary.withValues(alpha: 0.3)
                                      : colors.border,
                                ),
                              ),
                              child: Text(
                                '$replyCount',
                                style: TextStyle(
                                  color: unread
                                      ? colors.primary
                                      : colors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
