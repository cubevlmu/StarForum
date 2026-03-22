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
  final int participantCount;
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
  final int subscription;

  DiscussionInfo(
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
    this.postsIdList,
    this.posts,
    this.users,
    this.tags,
    this.subscription
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
      subscription: subscription,
    );
  }

  factory DiscussionInfo.formMaoAndId(Map m, int id) {
    final info = JsonReader(asJsonMap(m));
    final rawViewCount = info["viewCount"] ?? info["views"];
    return DiscussionInfo(
      id.toString(),
      info.string("title"),
      info.integer("commentCount"),
      info.integer("participantCount"),
      JsonValue.asInt(rawViewCount),
      info.dateTime("createdAt"),
      info.dateTime("lastPostedAt"),
      info.integer("lastPostNumber"),
      0,
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
    );
  }

  static bool isInitDiscussion(DiscussionInfo discussionInfo) {
    return discussionInfo.firstPost != null || discussionInfo.posts.isEmpty;
  }

  factory DiscussionInfo.fromMap(Map map) {
    return DiscussionInfo.fromBase(BaseBean.fromMap(map));
  }

  factory DiscussionInfo.fromBase(BaseBean base) {
    final allPosts = <int, PostInfo>{};
    final d = DiscussionInfo.formMaoAndId(base.data.attributes, base.data.id);

    for (var data in base.included.data) {
      switch (data.type) {
        case "posts":
          final p = PostInfo.fromBaseData(data);
          allPosts[p.id] = p;
          break;
        case "tags":
          final t = TagInfo.fromBaseData(data);
          d.tags.add(t);
          break;
        case "users":
          final u = UserInfo.fromBaseData(data);
          d.users[u.id] = u;
          break;
      }
    }

    d.postsIdList.addAll(base.data.relatedIds("posts"));

    final firstPostId = base.data.relatedId("firstPost", -1);
    if (firstPostId >= 0 && !d.postsIdList.contains(firstPostId)) {
      d.postsIdList.add(firstPostId);
    }

    for (var id in d.postsIdList) {
      final p = allPosts[id];
      if (p != null) {
        d.posts[id] = p;
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
            final u = UserInfo.fromBaseData(data);
            users[u.id] = u;
            break;
          case "posts":
            final p = PostInfo.fromBaseData(data);
            posts[p.id] = p;
            break;
          case "tags":
            final t = TagInfo.fromBaseData(data);
            tags[t.id] = t;
            break;
        }
      } catch (e) {
        LogUtil.error(
          "[Parser] Failed to parse discussion item at base.include.data $e",
        );
      }
    }
    for (var data in base.data.list) {
      final d = DiscussionInfo.formMaoAndId(data.attributes, data.id);
      d.user = users[data.relatedId("user", -1)] ?? UserInfo.deletedUser;
      d.lastPostedUser =
          users[data.relatedId("lastPostedUser", -1)] ?? UserInfo.deletedUser;
      d.firstPost = posts[data.relatedId("firstPost", -1)];

      d.tags.clear();
      for (final id in data.relatedIds("tags")) {
        try {
          final tag = tags[id];
          if (tag == null) continue;
          d.tags.add(tag);
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
