/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/pages/post_detail/view.dart';
import 'package:star_forum/widgets/forum/forum_discussion_tile.dart';
import 'package:star_forum/widgets/forum/forum_meta_row.dart';
import 'package:star_forum/utils/string_util.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.item});

  final DiscussionSummary item;

  @override
  Widget build(BuildContext context) {
    // excerpt is already plain text from the repo layer
    final excerpt = item.excerpt.trim();
    return ForumDiscussionTile(
      title: item.title,
      excerpt: excerpt.isEmpty ? null : excerpt,
      author: item.authorName,
      avatarUrl: item.authorAvatar,
      tags: item.tags.take(3).map((tag) => tag.name).toList(),
      meta: [
        ForumMetaItem(
          icon: FUIIcons.schedule,
          label: StringUtil.dateTimeToAgoDate(item.lastPostedAt),
        ),
        ForumMetaItem(
          icon: FUIIcons.visibility,
          label: StringUtil.numFormat(item.viewCount),
        ),
      ],
      replyCount: item.commentCount > 0 ? item.commentCount - 1 : 0,
      unread: item.subscription == 1,
      pinned: item.isSticky,
      onTap: () => FuiNavigation.openDetail(
        context,
        builder: (_) => PostPage(item: item, embedded: true),
      ),
    );
  }
}
