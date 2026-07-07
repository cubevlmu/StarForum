/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/foundation.dart';

@immutable
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
  final int userId;
  final int subscription;

  const DiscussionItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.lastPostedAt,
    this.authorAvatar = "",
    this.authorName = "",
    this.viewCount = 0,
    this.likeCount = -1,
    this.commentCount = -1,
    required this.userId,
    required this.subscription,
  });

  @override
  bool operator ==(Object other) {
    return other is DiscussionItem &&
        other.id == id &&
        other.title == title &&
        other.excerpt == excerpt &&
        other.authorAvatar == authorAvatar &&
        other.authorName == authorName &&
        other.viewCount == viewCount &&
        other.lastPostedAt == lastPostedAt &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.userId == userId &&
        other.subscription == subscription;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    excerpt,
    authorAvatar,
    authorName,
    viewCount,
    lastPostedAt,
    likeCount,
    commentCount,
    userId,
    subscription,
  );
}
