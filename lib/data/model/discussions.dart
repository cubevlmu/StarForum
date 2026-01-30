import 'base.dart';
import 'posts.dart';
import 'tags.dart';
import 'users.dart';

class DiscussionInfo {
  String id;
  String title;
  String slug;
  int commentCount;
  int participantCount;
  int views;
  String createdAt;
  String lastPostedAt;
  int lastPostNumber;
  int firstPostId;
  UserInfo? user;
  UserInfo? lastPostedUser;
  PostInfo? firstPost;
  List<int> postsIdList;
  Map<int, PostInfo>? posts;
  Map<int, UserInfo>? users;
  List<TagInfo>? tags;

  DiscussionInfo(
    this.id,
    this.title,
    this.slug,
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
    this.postsIdList,
    this.posts,
    this.users,
    this.tags,
  );

  factory DiscussionInfo.formMaoAndId(Map m, int id) {
    return DiscussionInfo(
      id.toString(),
      m["title"],
      m["slug"],
      m["commentCount"],
      m["participantCount"],
      m["views"],
      m["createdAt"],
      m["lastPostedAt"],
      m["lastPostNumber"],
      0,
      null,
      null,
      null,
      [],
      null,
      null,
      null,
    );
  }

  static bool isInitDiscussion(DiscussionInfo discussionInfo) {
    return discussionInfo.firstPost != null ||
        discussionInfo.posts == null;
  }

  factory DiscussionInfo.formJson(String j) {
    return DiscussionInfo.formBase(BaseBean.formJson(j));
  }

  factory DiscussionInfo.formBase(BaseBean base) {
    Map<int, PostInfo> allPosts = {};
    Map<int, PostInfo> posts = {};
    List<int> postsId = [];
    List<TagInfo> tags = [];
    Map<int, UserInfo> users = {};
    var d = DiscussionInfo.formMaoAndId(base.data.attributes, base.data.id);

    base.included.data?.forEach((data) {
      switch (data.type) {
        case "posts":
          var p = PostInfo.formBaseData(data);
          allPosts.addAll({p.id: p});
          break;
        case "tags":
          var t = TagInfo.formBaseData(data);
          tags.add(t);
          break;
        case "users":
          var u = UserInfo.formBaseData(data);
          users.addAll({u.id: u});
          break;
      }
    });
    for (var data in (base.data.relationships?["posts"]["data"] as List)) {
      postsId.add(int.parse(data["id"]));
    }

    for (var id in postsId) {
      var p = allPosts[id];
      if (p != null) {
        posts.addAll({id: p});
      }
    }

    d.posts = posts;
    d.postsIdList = postsId;
    d.users = users;
    d.tags = tags;
    d.firstPostId = postsId[0];
    return d;
  }
}

class Discussions {
  List<DiscussionInfo> list;
  Links links;

  Discussions(this.list, this.links);

  factory Discussions.formJson(String data) {
    return Discussions.formBase(BaseListBean.formJson(data));
  }

  factory Discussions.formBase(BaseListBean base) {
    List<DiscussionInfo> list = [];
    Map<int, UserInfo> users = {};
    Map<int, PostInfo> posts = {};
    Map<int, TagInfo> tags = {};
    if (base.included.data == null || base.data.list.isEmpty) {
      return Discussions(list, base.links);
    }
    base.included.data?.forEach((data) {
      switch (data.type) {
        case "users":
          var u = UserInfo.formBaseData(data);
          users.addAll({u.id: u});
          break;
        case "posts":
          var p = PostInfo.formBaseData(data);
          posts.addAll({p.id: p});
          break;
        case "tags":
          var t = TagInfo.formBaseData(data);
          tags.addAll({t.id: t});
          break;
      }
    });
    for (var data in base.data.list) {
      var d = DiscussionInfo.formMaoAndId(data.attributes, data.id);
      if (data.relationships?["user"] == null) {
        d.user = UserInfo.deletedUser;
      } else {
        d.user = users[int.parse(data.relationships?["user"]["data"]["id"])];
      }
      if (data.relationships?["lastPostedUser"] == null) {
        d.lastPostedUser = UserInfo.deletedUser;
      } else {
        d.lastPostedUser =
            users[int.parse(
              data.relationships?["lastPostedUser"]["data"]["id"],
            )];
      }

      /// in https://discuss.flarum.org/?sort=oldest , some old discussions not have firstPost .
      if (data.relationships?["firstPost"] != null) {
        d.firstPost =
            posts[int.parse(data.relationships?["firstPost"]["data"]["id"])];
      } else {
        d.firstPost = null;
      }

      List<TagInfo> t = [];
      for (var m in (data.relationships?["tags"]["data"] as List)) {
        Map map = m;
        t.add(tags[int.parse(map["id"])]!);
      }
      d.tags = t;
      list.add(d);
    }
    return Discussions(list, base.links);
  }
}

class PagedDiscussions {
  final Discussions data;
  final String? nextUrl;

  PagedDiscussions({
    required this.data,
    required this.nextUrl,
  });
}
