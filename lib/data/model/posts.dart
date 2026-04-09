import 'package:star_forum/data/model/discussions.dart';

import 'base.dart';
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
  UserInfo? user;

  PostInfo(
    this.id,
    this.createdAt,
    this.contentHtml,
    this.editedAt,
    this.userId,
    this.editedUser,
    this.discussion,
    this.likes,
  );

  factory PostInfo.fromMap(Map data) {
    return PostInfo.fromBaseData(BaseBean.fromMap(data).data);
  }

  factory PostInfo.fromBaseData(BaseData data) {
    final m = data.attrs;

    return PostInfo(
      data.id,
      m.string("createdAt"),
      m.string("contentHtml"),
      m.string("editedAt"),
      data.relatedId("user"),
      data.relatedId("editedUser"),
      data.relatedId("discussion"),
      m.integer("likesCount", -1),
    );
  }
}

class Posts {
  final Map<int, PostInfo> posts;
  final Map<int, DiscussionInfo> discussions;
  final Map<int, UserInfo> users;
  Posts(this.posts, this.users, this.discussions);

  factory Posts.fromMap(Map data) {
    return Posts.fromBaseList(BaseListBean.fromMap(data));
  }

  factory Posts.fromBaseList(BaseListBean baseBean) {
    final posts = <int, PostInfo>{};
    final users = <int, UserInfo>{};
    final diss = <int, DiscussionInfo>{};
    for (var e in baseBean.data.list) {
      if (e.type == "posts") {
        final p = PostInfo.fromBaseData(e);
        posts[p.id] = p;
      }
    }
    for (var e in baseBean.included.data) {
      switch (e.type) {
        case "users":
          final u = UserInfo.fromBaseData(e);
          users[u.id] = u;
          break;
        case "posts":
          final p = PostInfo.fromBaseData(e);
          posts[p.id] = p;
          break;
        case "discussions":
          final d = DiscussionInfo.formMaoAndId(e.attributes, e.id);
          diss[e.id] = d;
          break;
      }
    }
    return Posts(posts, users, diss);
  }
}
