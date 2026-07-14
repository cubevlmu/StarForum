import 'package:flutter/foundation.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/utils/html_utils.dart';

import 'posts.dart';
import 'tags.dart';
import 'users.dart';

const _notProvided = Object();

@immutable
class DiscussionDetail {
  final String id;
  final String title;
  final int commentCount;
  final int participantCount;
  final int views;
  final DateTime createdAt;
  final DateTime lastPostedAt;
  final int lastPostNumber;
  final int firstPostId;
  final UserInfo? user;
  final UserInfo? lastPostedUser;
  final PostInfo? firstPost;
  final List<int> postsIdList;
  final Map<int, PostInfo> posts;
  final Map<int, UserInfo> users;
  final List<TagInfo> tags;
  final int subscription;
  final bool isSticky;
  final bool authorRelationshipLoaded;

  DiscussionDetail(
    this.id,
    this.title,
    this.commentCount,
    this.participantCount,
    this.views,
    this.createdAt,
    this.lastPostedAt,
    this.lastPostNumber,
    this.firstPostId,
    this.user,
    this.lastPostedUser,
    this.firstPost,
    List<int> postsIdList,
    Map<int, PostInfo> posts,
    Map<int, UserInfo> users,
    List<TagInfo> tags,
    this.subscription, {
    this.isSticky = false,
    this.authorRelationshipLoaded = true,
  }) : postsIdList = List.unmodifiable(postsIdList),
       posts = Map.unmodifiable(posts),
       users = Map.unmodifiable(users),
       tags = List.unmodifiable(tags);

  DiscussionDetail copyWith({
    String? id,
    String? title,
    int? commentCount,
    int? participantCount,
    int? views,
    DateTime? createdAt,
    DateTime? lastPostedAt,
    int? lastPostNumber,
    int? firstPostId,
    Object? user = _notProvided,
    Object? lastPostedUser = _notProvided,
    Object? firstPost = _notProvided,
    List<int>? postsIdList,
    Map<int, PostInfo>? posts,
    Map<int, UserInfo>? users,
    List<TagInfo>? tags,
    int? subscription,
    bool? isSticky,
    bool? authorRelationshipLoaded,
  }) {
    return DiscussionDetail(
      id ?? this.id,
      title ?? this.title,
      commentCount ?? this.commentCount,
      participantCount ?? this.participantCount,
      views ?? this.views,
      createdAt ?? this.createdAt,
      lastPostedAt ?? this.lastPostedAt,
      lastPostNumber ?? this.lastPostNumber,
      firstPostId ?? this.firstPostId,
      identical(user, _notProvided) ? this.user : user as UserInfo?,
      identical(lastPostedUser, _notProvided)
          ? this.lastPostedUser
          : lastPostedUser as UserInfo?,
      identical(firstPost, _notProvided)
          ? this.firstPost
          : firstPost as PostInfo?,
      postsIdList ?? this.postsIdList,
      posts ?? this.posts,
      users ?? this.users,
      tags ?? this.tags,
      subscription ?? this.subscription,
      isSticky: isSticky ?? this.isSticky,
      authorRelationshipLoaded:
          authorRelationshipLoaded ?? this.authorRelationshipLoaded,
    );
  }

  DiscussionSummary toSummary() {
    final authorId = user?.id ?? 0;
    var excerpt = htmlToPlainText(firstPost?.contentHtml ?? '');
    if (excerpt.length > 80) excerpt = excerpt.substring(0, 80);
    return DiscussionSummary(
      id: id,
      title: title,
      excerpt: excerpt,
      lastPostedAt: lastPostedAt,
      createdAt: createdAt,
      userId: authorId,
      authorName: UserInfo.displayLabel(user, fallbackId: authorId),
      authorAvatar: user?.avatarUrl ?? "",
      commentCount: commentCount,
      viewCount: views,
      participantCount: participantCount,
      tags: tags,
      subscription: subscription,
      isSticky: isSticky,
    );
  }

  factory DiscussionDetail.fromMapAndId(Map m, int id) {
    final info = JsonReader(asJsonMap(m));
    final rawViewCount = info["viewCount"] ?? info["views"];
    return DiscussionDetail(
      id.toString(),
      info.string("title"),
      info.integer("commentCount"),
      info.integer("participantCount"),
      JsonValue.asInt(rawViewCount),
      info.dateTime("createdAt"),
      info.dateTime("lastPostedAt"),
      info.integer("lastPostNumber"),
      -1,
      null,
      null,
      null,
      [],
      {},
      {},
      [],
      info.json["subscription"] == null
          ? 0
          : info.string("subscription") == "ignore"
          ? 2
          : 1,
      isSticky: info.boolean('isSticky'),
      authorRelationshipLoaded: false,
    );
  }
}
