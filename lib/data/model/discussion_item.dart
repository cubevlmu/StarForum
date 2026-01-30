/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

class DiscussionItem {
  final String id;
  final String title;
  final String excerpt;

  final String authorAvatar;
  final String authorName;
  final int viewCount;
  final DateTime lastPostedAt;

  final int likeCount;
  final int commentCount;

  DiscussionItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.lastPostedAt,
    this.authorAvatar = "",
    this.authorName = "",
    this.viewCount = 0,
    this.likeCount = -1,
    this.commentCount = -1
  });
}
