import 'package:flutter/material.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/utils/html_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import 'package:star_forum/widgets/avatar.dart';

class DiscussionListItemCard extends StatelessWidget {
  const DiscussionListItemCard({super.key, required this.discussion});

  final DiscussionInfo discussion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final excerpt = htmlToPlainText(discussion.firstPost?.contentHtml ?? "");
    final tags = discussion.tags;
    final author = discussion.user ?? UserInfo.deletedUser;
    final replies = discussion.commentCount > 0 ? discussion.commentCount - 1 : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AvatarWidget(
                avatarUrl: author.avatarUrl,
                radius: 18,
                width: 36,
                height: 36,
                placeholder: StringUtil.getAvatarFirstChar(author.displayName),
              ),
              const SizedBox(height: 8),
              if (discussion.subscription == 1)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discussion.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final tag in tags.take(2))
                      _TopicTagPill(tag: tag),
                    Text(
                      '${author.displayName} 发布于 ${StringUtil.dateTimeToAgoDate(discussion.createdAt)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _TopicMetaText(
                      icon: Icons.people_alt_outlined,
                      label: '参与人数',
                      value: '${discussion.participantCount}',
                    ),
                    _TopicMetaText(
                      icon: Icons.schedule_outlined,
                      label: '发布于',
                      value: _formatDate(discussion.createdAt),
                    ),
                    _TopicMetaText(
                      icon: Icons.remove_red_eye_outlined,
                      label: null,
                      value: '${discussion.views}',
                    ),
                  ],
                ),
                if (excerpt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$replies',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

class _TopicTagPill extends StatelessWidget {
  const _TopicTagPill({required this.tag});

  final TagInfo tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tag.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TopicMetaText extends StatelessWidget {
  const _TopicMetaText({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: style?.color),
        const SizedBox(width: 4),
        if (label != null)
          Text('$label: ', style: style?.copyWith(fontWeight: FontWeight.w600)),
        Text(value, style: style),
      ],
    );
  }
}
