import 'package:star_forum/data/model/discussions.dart';
import 'package:flutter/foundation.dart';

import 'users.dart';

const _notProvided = Object();

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
