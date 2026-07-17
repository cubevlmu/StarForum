import 'package:star_forum/data/model/discussions.dart';
import 'package:flutter/foundation.dart';

import 'users.dart';

const _notProvided = Object();

enum PostEventType {
  discussionStickyChanged,
  discussionStickiestChanged,
  discussionLockChanged,
  commentContentUnavailable,
  unsupported,
}

@immutable
class PostEvent {
  const PostEvent.discussionStickyChanged({required bool sticky})
    : type = PostEventType.discussionStickyChanged,
      sourceType = 'discussionStickied',
      active = sticky;

  const PostEvent.unsupported({required this.sourceType})
    : type = PostEventType.unsupported,
      active = false;

  const PostEvent.discussionStickiestChanged({required bool sticky})
    : type = PostEventType.discussionStickiestChanged,
      sourceType = 'discussionStickiest',
      active = sticky;

  const PostEvent.discussionLockChanged({
    required bool locked,
    this.sourceType = 'discussionLocked',
  }) : type = PostEventType.discussionLockChanged,
       active = locked;

  const PostEvent.commentContentUnavailable()
    : type = PostEventType.commentContentUnavailable,
      sourceType = 'comment',
      active = false;

  final PostEventType type;
  final bool active;
  final String sourceType;

  bool get sticky => active;
  bool get locked => active;
}

@immutable
class PostInfo {
  final int id;
  final String createdAt;
  final String contentHtml;
  final String editedAt;
  final int userId;
  final int editedUser;
  final int discussion;
  final int likes;
  final int number;
  final String contentType;
  final bool isLiked;
  final UserInfo? user;
  final PostEvent? event;

  const PostInfo(
    this.id,
    this.createdAt,
    this.contentHtml,
    this.editedAt,
    this.userId,
    this.editedUser,
    this.discussion,
    this.likes, {
    this.number = 0,
    this.contentType = 'comment',
    this.isLiked = false,
    this.user,
    this.event,
  });

  PostInfo copyWith({
    int? id,
    String? createdAt,
    String? contentHtml,
    String? editedAt,
    int? userId,
    int? editedUser,
    int? discussion,
    int? likes,
    int? number,
    String? contentType,
    bool? isLiked,
    Object? user = _notProvided,
    Object? event = _notProvided,
  }) {
    return PostInfo(
      id ?? this.id,
      createdAt ?? this.createdAt,
      contentHtml ?? this.contentHtml,
      editedAt ?? this.editedAt,
      userId ?? this.userId,
      editedUser ?? this.editedUser,
      discussion ?? this.discussion,
      likes ?? this.likes,
      number: number ?? this.number,
      contentType: contentType ?? this.contentType,
      isLiked: isLiked ?? this.isLiked,
      user: identical(user, _notProvided) ? this.user : user as UserInfo?,
      event: identical(event, _notProvided) ? this.event : event as PostEvent?,
    );
  }
}

@immutable
class Posts {
  final Map<int, PostInfo> posts;
  final Map<int, DiscussionDetail> discussions;
  final Map<int, UserInfo> users;
  Posts(
    Map<int, PostInfo> posts,
    Map<int, UserInfo> users,
    Map<int, DiscussionDetail> discussions,
  ) : posts = Map.unmodifiable(posts),
      users = Map.unmodifiable(users),
      discussions = Map.unmodifiable(discussions);
}
