/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/main/adaptive_navigation.dart';
import 'package:star_forum/pages/notification/controller.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';

(String, String) buildMsg(BuildContext context, NotificationsInfo info) {
  if (info.cachedTitle != null && info.cachedDesc != null) {
    return (info.cachedTitle!, info.cachedDesc!);
  }

  final result = switch (info.contentType) {
    "quest_done" => () {
      final real = info.subject as QuestSubject;
      return (real.quest.name, real.quest.description);
    }(),
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
    final textTheme = Theme.of(context).textTheme;
    final typeMeta = _buildTypeMeta(context, item.contentType);
    final canOpenDiscussion =
        item.contentType == "postLiked" || item.contentType == "postMentioned";
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Material(
          color: item.isRead
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: item.isRead
                  ? colorScheme.outlineVariant
                  : colorScheme.primary.withValues(alpha: 0.24),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canOpenDiscussion ? () => naviToPage(context) : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                typeMeta.icon,
                                size: 16,
                                color: item.isRead
                                    ? typeMeta.color.withValues(alpha: 0.55)
                                    : typeMeta.color,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              if (!item.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: bodyColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                "·",
                                style: textTheme.labelMedium?.copyWith(
                                  color: metaColor,
                                ),
                              ),
                              const SizedBox(width: 6),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 2, top: 2),
                    child: Column(
                      children: [
                        IconButton(
                          tooltip: item.isRead
                              ? null
                              : AppLocalizations.of(
                                  context,
                                )!.notificationMarkReadSuccess,
                          icon: Icon(
                            item.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_outline_rounded,
                          ),
                          color: item.isRead
                              ? colorScheme.outline
                              : colorScheme.onSurfaceVariant,
                          onPressed: item.isRead
                              ? null
                              : () async {
                                  await controller.checkAsRead(item.id);
                                },
                        ),
                        if (canOpenDiscussion)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
    openUserAdaptive(context, item.fromUser?.id ?? -1);
  }

  _NotifyTypeMeta _buildTypeMeta(BuildContext context, String contentType) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (contentType) {
      case "postMentioned":
        return _NotifyTypeMeta(
          icon: Icons.alternate_email_rounded,
          color: colorScheme.secondary,
        );
      case "postLiked":
        return _NotifyTypeMeta(
          icon: Icons.favorite_border_rounded,
          color: Colors.redAccent,
        );
      case "warning":
        return _NotifyTypeMeta(
          icon: Icons.warning_amber_rounded,
          color: colorScheme.error,
        );
      case "badgeReceived":
        return _NotifyTypeMeta(
          icon: Icons.workspace_premium_outlined,
          color: colorScheme.tertiary,
        );
      case "levelUpdated":
        return _NotifyTypeMeta(
          icon: Icons.trending_up_rounded,
          color: colorScheme.primary,
        );
      default:
        return _NotifyTypeMeta(
          icon: Icons.notifications_none_rounded,
          color: colorScheme.onSurfaceVariant,
        );
    }
  }

  void naviToPage(BuildContext context) async {
    if (item.contentType == "postLiked" ||
        item.contentType == "postMentioned") {
      final s = item.subject as PostSubject;
      final r = await controller.naviToDisPage(s.post.discussion);
      if (r == null) {
        return;
      }
      if (!context.mounted) return;
      openDiscussionAdaptive(context, r);
    }
  }
}

class _NotifyTypeMeta {
  const _NotifyTypeMeta({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}
