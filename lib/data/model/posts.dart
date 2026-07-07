import 'package:star_forum/data/model/discussions.dart';

import 'users.dart';

class PostInfo {
  final int id;
  String createdAt;
  String contentHtml;
  String editedAt;
  final int userId;
  final int editedUser;
  final int discussion;
  int likes;
  final int number;
  final String contentType;
  bool isLiked;
  UserInfo? user;

  PostInfo(
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
  });
}

class Posts {
  final Map<int, PostInfo> posts;
  final Map<int, DiscussionInfo> discussions;
  final Map<int, UserInfo> users;
  Posts(this.posts, this.users, this.discussions);
}
