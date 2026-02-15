import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/utils/log_util.dart';

import 'base.dart';
import 'posts.dart';
import 'tags.dart';
import 'users.dart';

class DiscussionInfo {
  final String id;
  final String title;
  final int commentCount;
  final int views;
  final DateTime createdAt;
  final DateTime lastPostedAt;
  final int lastPostNumber;
  int firstPostId;
  UserInfo? user;
  UserInfo? lastPostedUser;
  PostInfo? firstPost;
  final List<int> postsIdList;
  final Map<int, PostInfo> posts;
  final Map<int, UserInfo> users;
  final List<TagInfo> tags;

  DiscussionInfo(
    this.id,
    this.title,
    this.commentCount,
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

  DiscussionItem toItem() {
    return DiscussionItem(
      id: id,
      title: title,
      excerpt: firstPost?.contentHtml ?? "",
      lastPostedAt: lastPostedAt,
      userId: user?.id ?? 0,
      authorName: user?.displayName ?? "",
      authorAvatar: user?.avatarUrl ?? "",
      commentCount: commentCount,
      viewCount: views,
    );
  }

  factory DiscussionInfo.formMaoAndId(Map m, int id) {
    return DiscussionInfo(
      id.toString(),
      m["title"],
      m["commentCount"] ?? 0,
      m["views"] ?? 0,
      DateTime.tryParse(m["createdAt"] ?? "") ?? DateTime.utc(1980),
      DateTime.tryParse(m["lastPostedAt"] ?? "") ?? DateTime.utc(1980),
      m["lastPostNumber"] ?? 0,
      0,
      null,
      null,
      null,
      [],
      {},
      {},
      [],
    );
  }

  static bool isInitDiscussion(DiscussionInfo discussionInfo) {
    return discussionInfo.firstPost != null || discussionInfo.posts.isEmpty;
  }

  factory DiscussionInfo.fromMap(Map map) {
    return DiscussionInfo.fromBase(BaseBean.fromMap(map));
  }

  factory DiscussionInfo.fromBase(BaseBean base) {
    Map<int, PostInfo> allPosts = {};
    var d = DiscussionInfo.formMaoAndId(base.data.attributes, base.data.id);

    for (var data in base.included.data) {
      switch (data.type) {
        case "posts":
          var p = PostInfo.fromBaseData(data);
          allPosts.addAll({p.id: p});
          break;
        case "tags":
          var t = TagInfo.fromBaseData(data);
          d.tags.add(t);
          break;
        case "users":
          var u = UserInfo.fromBaseData(data);
          d.users.addAll({u.id: u});
          break;
      }
    }
    if (base.data.relationships.containsKey("posts")) {
      for (var data in (base.data.relationships["posts"]["data"] as List)) {
        d.postsIdList.add(int.parse(data["id"]));
      }
    }
    if (base.data.relationships.containsKey("firstPost")) {
      d.postsIdList.add(
        int.parse(base.data.relationships["firstPost"]["data"]["id"] ?? "-1"),
      );
    }

    for (var id in d.postsIdList) {
      var p = allPosts[id];
      if (p != null) {
        d.posts.addAll({id: p});
      }
    }

    d.firstPostId = d.postsIdList.isEmpty ? -1 : d.postsIdList[0];
    return d;
  }
}

class Discussions {
  final List<DiscussionInfo> list;
  final Links links;

  Discussions({required this.list, required this.links});

  factory Discussions.fromMap(Map map) {
    return Discussions.fromBase(BaseListBean.fromMap(map));
  }

  factory Discussions.fromBase(BaseListBean base) {
    final List<DiscussionInfo> list = [];
    final Map<int, UserInfo> users = {};
    final Map<int, PostInfo> posts = {};
    final Map<int, TagInfo> tags = {};

    if (base.included.data.isEmpty || base.data.list.isEmpty) {
      return Discussions(list: list, links: base.links);
    }
    for (var data in base.included.data) {
      try {
        switch (data.type) {
          case "users":
            var u = UserInfo.fromBaseData(data);
            users.addAll({u.id: u});
            break;
          case "posts":
            var p = PostInfo.fromBaseData(data);
            posts.addAll({p.id: p});
            break;
          case "tags":
            var t = TagInfo.fromBaseData(data);
            tags.addAll({t.id: t});
            break;
        }
      } catch (e) {
        LogUtil.error(
          "[Parser] Failed to parse discussion item at base.include.data $e",
        );
      }
    }
    for (var data in base.data.list) {
      var d = DiscussionInfo.formMaoAndId(data.attributes, data.id);
      if (data.relationships["user"] == null) {
        d.user = UserInfo.deletedUser;
      } else {
        d.user = users[int.parse(data.relationships["user"]["data"]["id"])];
      }
      if (data.relationships["lastPostedUser"] == null) {
        d.lastPostedUser = UserInfo.deletedUser;
      } else {
        d.lastPostedUser =
            users[int.parse(
              data.relationships["lastPostedUser"]["data"]["id"],
            )];
      }

      if (data.relationships["firstPost"] != null) {
        d.firstPost =
            posts[int.parse(data.relationships["firstPost"]["data"]["id"])];
      } else {
        d.firstPost = null;
      }

      d.tags.clear();
      for (var m in (data.relationships["tags"]["data"] as List)) {
        try {
          final id = int.parse(m["id"] ?? "0");
          if (!tags.containsKey(id)) continue;
          d.tags.add(tags[id]!);
        } catch (e) {
          LogUtil.error(
            "[Parser] Failed to parse discussion item at d.tags.add $e",
          );
        }
      }
      list.add(d);
    }
    return Discussions(list: list, links: base.links);
  }
}

class PagedDiscussions {
  final Discussions data;
  final String? nextUrl;

  PagedDiscussions({required this.data, required this.nextUrl});
}
