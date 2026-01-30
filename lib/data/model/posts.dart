import 'base.dart';
import 'users.dart';

class PostInfo {
  final int id;
  String createdAt;
  final String contentHtml;
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

  factory PostInfo.formJson(String data) {
    return PostInfo.formBaseData(BaseBean.formJson(data).data);
  }

  factory PostInfo.formBaseData(BaseData data) {
    var m = data.attributes;

    int discussion = 0;
    int user = 0;
    int editedUser = 0;
    List<int> mentionedBy = [];

    if (data.relationships != null) {
      if (data.relationships?["discussion"] != null) {
        discussion = int.parse(data.relationships?["discussion"]["data"]["id"]);
      }
      if (data.relationships?["user"] != null) {
        user = int.parse(data.relationships?["user"]["data"]["id"]);
      }
      if (data.relationships?["editedUser"] != null) {
        editedUser = int.parse(data.relationships?["editedUser"]["data"]["id"]);
      }
      if (data.relationships?["mentionedBy"] != null) {
        for (var m in (data.relationships?["mentionedBy"]["data"] as List)) {
          m = m as Map;
          mentionedBy.add(int.parse(m["id"]));
        }
      }
    }

    var p = PostInfo(
      data.id,
      m["createdAt"] ?? "",
      m["contentHtml"] ?? "",
      m["editedAt"] ?? "",
      user,
      editedUser,
      discussion,
      m["likesCount"] ?? -1,
    );
    return p;
  }
}

class Posts {
  final Map<int, PostInfo> posts;
  final Map<int, UserInfo> users;
  Posts(this.posts, this.users);

  factory Posts.formJson(String data) {
    return Posts.formBaseList(BaseListBean.formJson(data));
  }

  factory Posts.formBaseList(BaseListBean baseBean) {
    Map<int, PostInfo> posts = {};
    Map<int, UserInfo> users = {};
    for (var e in baseBean.data.list) {
      if (e.type == "posts") {
        var p = PostInfo.formBaseData(e);
        posts.addAll({p.id: p});
      }
    }
      baseBean.included.data?.forEach((e) {
      switch (e.type) {
        case "users":
          var u = UserInfo.formBaseData(e);
          users.addAll({u.id: u});
          break;
        case "posts":
          var p = PostInfo.formBaseData(e);
          posts.addAll({p.id: p});
          break;
      }
    });
    return Posts(posts, users);
  }
}
