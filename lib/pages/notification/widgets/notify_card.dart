/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames
 */

import 'package:flutter/material.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/user/view.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';
import 'package:get/get.dart';
import 'package:fin_ui/fin_ui.dart';

(String, String) buildMsg(BuildContext context, NotificationsInfo info) {
  if (info.cachedTitle != null && info.cachedDesc != null) {
    return (info.cachedTitle!, info.cachedDesc!);
  }

  final result = switch (info.contentType) {
    "quest_done" => () {
      final real = info.subject as QuestSubject?;
      return (
        real?.quest.name.isNotEmpty == true
            ? real!.quest.name
            : AppLocalizations.of(context)!.notificationQuestDoneTitle,
        real?.quest.description.isNotEmpty == true
            ? real!.quest.description
            : AppLocalizations.of(context)!.notificationQuestDoneDesc,
      );
    }(),
    "newPostByUser" => () {
      final real = info.subject as DiscussionSubject?;
      return (
        AppLocalizations.of(
          context,
        )!.notificationNewPostByUserTitle(info.fromUser?.displayName ?? ""),
        AppLocalizations.of(context)!.notificationNewPostByUserDesc(
          real?.discussion.title.isNotEmpty == true
              ? real!.discussion.title
              : AppLocalizations.of(context)!.notificationDiscussionFallback,
        ),
      );
    }(),
    "newDiscussionByUser" => () {
      final real = info.subject as DiscussionSubject?;
      return (
        AppLocalizations.of(context)!.notificationNewDiscussionByUserTitle(
          info.fromUser?.displayName ?? "",
        ),
        AppLocalizations.of(context)!.notificationNewDiscussionByUserDesc(
          real?.discussion.title.isNotEmpty == true
              ? real!.discussion.title
              : AppLocalizations.of(context)!.notificationDiscussionFallback,
        ),
      );
    }(),
    "newFollower" => (
      AppLocalizations.of(
        context,
      )!.notificationNewFollowerTitle(info.fromUser?.displayName ?? ""),
      AppLocalizations.of(context)!.notificationNewFollowerDesc,
    ),
    "levelUpdated" => () {
      final real = info.subject as LevelSubject;
      return (
        AppLocalizations.of(
          context,
        )!.notificationLevelUpdatedTitle(real.level.name),
        AppLocalizations.of(
          context,
        )!.notificationLevelUpdatedDesc(real.level.minExpRequired),
      );
    }(),
    "postMentioned" => () {
      final real = info.subject as PostSubject;
      final txt = htmlToPlainText(real.post.contentHtml);
      return (
        AppLocalizations.of(context)!.notificationPostMentionedTitle,
        AppLocalizations.of(context)!.notificationPostMentionedDesc(
          txt.substring(0, txt.length > 30 ? 30 : txt.length),
        ),
      );
    }(),
    "postLiked" => () {
      final real = info.subject as PostSubject;
      final txt = htmlToPlainText(real.post.contentHtml);
      return (
        AppLocalizations.of(context)!.notificationPostLikedTitle,
        AppLocalizations.of(context)!.notificationPostLikedDesc(
          txt.substring(0, txt.length > 30 ? 30 : txt.length),
        ),
      );
    }(),
    "badgeReceived" => (
      AppLocalizations.of(context)!.notificationBadgeReceivedTitle,
      AppLocalizations.of(context)!.notificationBadgeReceivedDesc,
    ),
    "warning" => () {
      final real = info.subject as WarningSubject;
      return (
        AppLocalizations.of(
          context,
        )!.notificationWarningTitle(info.fromUser?.displayName ?? ""),
        AppLocalizations.of(context)!.notificationWarningDesc(
          real.warning.strikes,
          htmlToPlainText(real.warning.publicComment ?? ""),
        ),
      );
    }(),
    _ => () {
      LogUtil.error("[NotifyCard] Unsupported type: ${info.contentType}");
      return (
        AppLocalizations.of(context)!.notificationUnsupportedTitle,
        AppLocalizations.of(context)!.notificationUnsupportedDesc,
      );
    }(),
  };

  info.cachedTitle = result.$1;
  info.cachedDesc = result.$2;
  return result;
}

class NotifyCard extends StatelessWidget {
  final NotificationsInfo item;
  final NotificationPageController controller;

  const NotifyCard({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final (title, desc) = buildMsg(context, item);
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final typeMeta = _buildTypeMeta(context, item.contentType);
    final canOpenDiscussion =
        item.contentType == "postLiked" ||
        item.contentType == "postMentioned" ||
        item.contentType == "newPostByUser" ||
        item.contentType == "newDiscussionByUser";
    final canOpenUser = item.contentType == "newFollower";
    final titleColor = item.isRead
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    final bodyColor = item.isRead
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;
    final metaColor = item.isRead
        ? colorScheme.outline
        : colorScheme.onSurfaceVariant;

    return RepaintBoundary(
      child: Material(
        color: item.isRead ? colors.surface : colors.primarySoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FUITokens.radiusLg),
          side: BorderSide(
            color: item.isRead
                ? colors.border
                : colors.primary.withValues(alpha: 0.22),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: (canOpenDiscussion || canOpenUser)
              ? () => naviToPage(context)
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkResponse(
                  onTap: () => _openUserSpace(context),
                  radius: 26,
                  child: AvatarWidget(
                    avatarUrl: item.fromUser?.avatarUrl ?? "",
                    radius: 22,
                    placeholder: item.fromUser?.displayName[0] ?? "U",
                  ),
                ),
                const SizedBox(width: FUITokens.gap10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _NotifyTypeIcon(meta: typeMeta, dimmed: item.isRead),
                          const SizedBox(width: FUITokens.gap8),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(
                                left: FUITokens.gap6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: FUITokens.gap6),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                          height: 1.32,
                        ),
                      ),
                      const SizedBox(height: FUITokens.gap8),
                      Row(
                        children: [
                          if (item.fromUser != null)
                            Flexible(
                              child: Text(
                                item.fromUser!.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(
                                  color: metaColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: FUITokens.gap6),
                          Text(
                            "·",
                            style: textTheme.labelMedium?.copyWith(
                              color: metaColor,
                            ),
                          ),
                          const SizedBox(width: FUITokens.gap6),
                          Text(
                            _formatTime(item.createdAt),
                            style: textTheme.labelMedium?.copyWith(
                              color: metaColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: FUITokens.gap6),
                  child: Obx(() {
                    final isMarkReadLoading =
                        controller.activeItemId.value == item.id &&
                        controller.activeItemAction.value ==
                            NotificationItemAction.markRead;
                    final isOpenLoading =
                        controller.activeItemId.value == item.id &&
                        controller.activeItemAction.value ==
                            NotificationItemAction.openDiscussion;

                    return Column(
                      children: [
                        if (isMarkReadLoading)
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          )
                        else
                          FUIIconButton(
                            icon: item.isRead
                                ? FUIIcons.check
                                : FUIIcons.checkmark,
                            tooltip: item.isRead
                                ? null
                                : AppLocalizations.of(
                                    context,
                                  )!.notificationMarkReadSuccess,
                            selected: !item.isRead,
                            onPressed:
                                item.isRead ||
                                    isMarkReadLoading ||
                                    isOpenLoading
                                ? null
                                : () async {
                                    await controller.checkAsRead(item.id);
                                  },
                          ),
                        if (canOpenDiscussion || canOpenUser)
                          isOpenLoading
                              ? SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                )
                              : FUIIconButton(
                                  icon: FUIIcons.chevronRight,
                                  onPressed: () => naviToPage(context),
                                ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return StringUtil.dateTimeToAgoDate(time);
  }

  void _openUserSpace(BuildContext context) {
    FuiNavigation.openDetail(
      context,
      builder: (_) => UserPage(userId: item.fromUser?.id ?? -1, embedded: true),
    );
  }

  _NotifyTypeMeta _buildTypeMeta(BuildContext context, String contentType) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (contentType) {
      case "postMentioned":
        return _NotifyTypeMeta(
          icon: ForumIcons.mention,
          color: colorScheme.secondary,
        );
      case "postLiked":
        return _NotifyTypeMeta(icon: ForumIcons.like, color: Colors.redAccent);
      case "warning":
        return _NotifyTypeMeta(
          icon: FUIIcons.warning,
          color: colorScheme.error,
        );
      case "newPostByUser":
        return _NotifyTypeMeta(
          icon: ForumIcons.reply,
          color: colorScheme.primary,
        );
      case "newDiscussionByUser":
        return _NotifyTypeMeta(
          icon: ForumIcons.compose,
          color: colorScheme.primary,
        );
      case "newFollower":
        return _NotifyTypeMeta(
          icon: ForumIcons.follow,
          color: colorScheme.tertiary,
        );
      case "badgeReceived":
        return _NotifyTypeMeta(
          icon: ForumIcons.badge,
          color: colorScheme.tertiary,
        );
      case "levelUpdated":
        return _NotifyTypeMeta(
          icon: ForumIcons.level,
          color: colorScheme.primary,
        );
      default:
        return _NotifyTypeMeta(
          icon: ForumIcons.notifications,
          color: colorScheme.onSurfaceVariant,
        );
    }
  }

  Future<void> naviToPage(BuildContext context) async {
    if (item.contentType == "postLiked" ||
        item.contentType == "postMentioned") {
      final s = item.subject as PostSubject;
      final r = await controller.naviToDisPageByItem(
        discussion: s.post.discussion,
        itemId: item.id,
      );
      if (r == null) {
        return;
      }
      if (!context.mounted) return;
      FuiNavigation.openDetail(
        context,
        builder: (_) => PostPage(item: r, embedded: true),
      );
      return;
    }

    if (item.contentType == "newPostByUser" ||
        item.contentType == "newDiscussionByUser") {
      final s = item.subject as DiscussionSubject?;
      if (s == null) {
        return;
      }
      final r = await controller.naviToDisPageByItem(
        discussion: s.discussion.id,
        itemId: item.id,
      );
      if (r == null) {
        return;
      }
      if (!context.mounted) return;
      FuiNavigation.openDetail(
        context,
        builder: (_) => PostPage(item: r, embedded: true),
      );
      return;
    }

    if (item.contentType == "newFollower") {
      final s = item.subject as UserSubject?;
      final userId = s?.user.id ?? item.fromUser?.id;
      if (userId == null || userId < 0) {
        return;
      }
      FuiNavigation.openDetail(
        context,
        builder: (_) => UserPage(userId: userId, embedded: true),
      );
    }
  }
}

class _NotifyTypeIcon extends StatelessWidget {
  const _NotifyTypeIcon({required this.meta, required this.dimmed});

  final _NotifyTypeMeta meta;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? meta.color.withValues(alpha: 0.55) : meta.color;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: dimmed ? 0.08 : 0.12),
        borderRadius: BorderRadius.circular(FUITokens.radiusSm),
      ),
      child: Icon(meta.icon, size: 16, color: color),
    );
  }
}

class _NotifyTypeMeta {
  const _NotifyTypeMeta({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}
