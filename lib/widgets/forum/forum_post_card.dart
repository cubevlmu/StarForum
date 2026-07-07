/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/widgets/forum/forum_user_avatar.dart';

class ForumPostCard extends StatelessWidget {
  const ForumPostCard({
    super.key,
    required this.author,
    required this.content,
    this.avatarUrl,
    this.avatar,
    this.title,
    this.tags = const [],
    this.meta = const [],
    this.floor,
    this.likeCount,
    this.likeLabel,
    this.replyLabel = 'Reply',
    this.main = false,
    this.likeLoading = false,
    this.isLiked = false,
    this.showReply = true,
    this.showMore = false,
    this.onAuthorTap,
    this.onReply,
    this.onLike,
    this.onMore,
  });

  final String author;
  final Widget content;
  final String? avatarUrl;
  final ImageProvider? avatar;
  final String? title;
  final List<String> tags;
  final List<ForumMetaItem> meta;
  final int? floor;
  final int? likeCount;
  final String? likeLabel;
  final String replyLabel;
  final bool main;
  final bool likeLoading;
  final bool isLiked;
  final bool showReply;
  final bool showMore;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onReply;
  final VoidCallback? onLike;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FUISurface(
      padding: EdgeInsets.zero,
      borderRadius: main ? FUITokens.radiusXl : FUITokens.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags row
                if (tags.isNotEmpty) ...[
                  Wrap(
                    spacing: FUITokens.gap6,
                    runSpacing: FUITokens.gap4,
                    children: [
                      for (final tag in tags)
                        FUITag(
                          label: tag,
                          variant: tag == tags.first
                              ? FUITagVariant.primary
                              : FUITagVariant.neutral,
                        ),
                    ],
                  ),
                  const SizedBox(height: FUITokens.gap8),
                ],
                // Title
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: main ? 20 : 16,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: FUITokens.gap10),
                ],
                // Author row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AuthorAvatar(
                      author: author,
                      avatarUrl: avatarUrl,
                      avatar: avatar,
                      size: main ? 40 : 36,
                      onTap: onAuthorTap,
                    ),
                    const SizedBox(width: FUITokens.gap10),
                    Expanded(
                      child: _AuthorBlock(
                        author: author,
                        meta: meta,
                        onTap: onAuthorTap,
                      ),
                    ),
                    if (floor != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FUITokens.gap8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                            FUITokens.radiusFull,
                          ),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          '#$floor',
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (showMore) ...[
                      const SizedBox(width: FUITokens.gap6),
                      _SmallIconButton(
                        icon: ForumIcons.more,
                        onPressed: onMore,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: FUITokens.gap10),
                // Content
                DefaultTextStyle(
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: main ? 14 : 13,
                    height: 1.5,
                  ),
                  child: content,
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: colors.border),
          // Action bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FUITokens.gap8,
              vertical: FUITokens.gap6,
            ),
            child: Row(
              children: [
                _PostActionButton(
                  icon: isLiked ? ForumIcons.likeFilled : ForumIcons.like,
                  label: likeLabel ?? 'Like',
                  count: likeCount,
                  onPressed: onLike,
                  loading: likeLoading,
                  active: isLiked,
                ),
                if (showReply) ...[
                  const SizedBox(width: FUITokens.gap6),
                  _PostActionButton(
                    icon: ForumIcons.reply,
                    label: replyLabel,
                    onPressed: onReply,
                  ),
                ],
                if (main) ...[
                  const SizedBox(width: FUITokens.gap6),
                  _PostActionButton(
                    icon: ForumIcons.share,
                    label: 'Share',
                    onPressed: () {},
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    this.count,
    this.loading = false,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final int? count;
  final bool loading;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onPressed == null && !loading;
    final fg = disabled
        ? colors.textDisabled
        : active
        ? colors.primary
        : colors.textSecondary;
    final countText = count != null ? ' $count' : '';

    return Tooltip(
      message: label,
      child: Material(
        color: active ? colors.primarySoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FUITokens.radiusMd),
          side: active
              ? BorderSide(color: colors.primary.withValues(alpha: 0.28))
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(FUITokens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FUITokens.gap8,
              vertical: FUITokens.gap6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                else
                  Icon(icon, size: 16, color: fg),
                if (count != null) ...[
                  const SizedBox(width: FUITokens.gap4),
                  Text(
                    countText.trim(),
                    style: TextStyle(
                      color: fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: colors.textTertiary),
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.author,
    this.avatarUrl,
    required this.avatar,
    required this.size,
    this.onTap,
  });

  final String author;
  final String? avatarUrl;
  final ImageProvider? avatar;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = ForumUserAvatar(
      name: author,
      avatarUrl: avatarUrl,
      image: avatar,
      size: size,
    );
    if (onTap == null) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}

class _AuthorBlock extends StatelessWidget {
  const _AuthorBlock({required this.author, required this.meta, this.onTap});

  final String author;
  final List<ForumMetaItem> meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: onTap == null ? colors.textPrimary : colors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 2),
          ForumMetaRow(items: meta),
        ],
      ],
    );

    if (onTap == null) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}
