/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/foundation.dart';
import 'package:star_forum/data/model/tags.dart';

@immutable
class DiscussionSummary {
  final String id;
  final String title;
  final String excerpt;

  final String authorAvatar;
  final String authorName;
  final int viewCount;
  final DateTime lastPostedAt;
  final DateTime createdAt;

  final int likeCount;
  final int commentCount;
  final int participantCount;
  final int userId;
  final int subscription;
  final List<TagInfo> tags;

  DiscussionSummary({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.lastPostedAt,
    required this.createdAt,
    this.authorAvatar = "",
    this.authorName = "",
    this.viewCount = 0,
    this.likeCount = -1,
    this.commentCount = -1,
    this.participantCount = 0,
    required this.userId,
    required this.subscription,
    List<TagInfo> tags = const <TagInfo>[],
  }) : tags = List.unmodifiable(tags);

  @override
  bool operator ==(Object other) {
    return other is DiscussionSummary &&
        other.id == id &&
        other.title == title &&
        other.excerpt == excerpt &&
        other.authorAvatar == authorAvatar &&
        other.authorName == authorName &&
        other.viewCount == viewCount &&
        other.lastPostedAt == lastPostedAt &&
        other.createdAt == createdAt &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.participantCount == participantCount &&
        other.userId == userId &&
        other.subscription == subscription &&
        listEquals(other.tags, tags);
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
    createdAt,
    likeCount,
    commentCount,
    participantCount,
    userId,
    subscription,
    Object.hashAll(tags),
  );
}
