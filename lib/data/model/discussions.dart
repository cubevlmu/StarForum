import 'package:star_forum/data/api/flarum_links.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/discussion_item.dart';

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
    this.subscription,
  );

  DiscussionItem toItem() {
    final authorId = user?.id ?? 0;
    return DiscussionItem(
      id: id,
      title: title,
      excerpt: firstPost?.contentHtml ?? "",
      lastPostedAt: lastPostedAt,
      userId: authorId,
      authorName: UserInfo.displayLabel(user, fallbackId: authorId),
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
    );
  }

  static bool isInitDiscussion(DiscussionInfo discussionInfo) {
    return discussionInfo.firstPost != null || discussionInfo.posts.isEmpty;
  }
}

class Discussions {
  final List<DiscussionInfo> list;
  final Links links;

  Discussions({required this.list, required this.links});
}
