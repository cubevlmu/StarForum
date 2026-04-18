import 'package:star_forum/data/model/discussion_item.dart';
import 'package:star_forum/utils/log_util.dart';

import 'base.dart';
import 'posts.dart';
import 'tags.dart';
import 'users.dart';

int _relatedIdFromMap(Map<String, Object?> relationships, String key) {
  final relation = asJsonMap(relationships[key]);
  final data = asJsonMap(relation['data']);
  return JsonValue.asInt(data['id'], -1);
}

List<int> _relatedIdsFromMap(Map<String, Object?> relationships, String key) {
  final relation = asJsonMap(relationships[key]);
  final data = asJsonList(relation['data']);
  final result = <int>[];
  for (final item in data) {
    final id = JsonValue.asInt(asJsonMap(item)['id'], -1);
    if (id >= 0) {
      result.add(id);
    }
  }
  return result;
}

UserInfo _fastUserFromMap(Map<String, Object?> map) {
  final attributes = asJsonMap(map['attributes']);
  return UserInfo(
    JsonValue.asInt(map['id']),
    JsonValue.asString(attributes['username']),
    JsonValue.asString(attributes['displayName']),
    JsonValue.asString(attributes['avatarUrl']),
    DateTime.utc(1980),
    JsonValue.asInt(attributes['discussionCount']),
    JsonValue.asInt(attributes['commentCount']),
    DateTime.utc(1980),
    JsonValue.asString(attributes['email']),
    null,
    JsonValue.asString(attributes['bio']),
  );
}

PostInfo _fastPostFromMap(Map<String, Object?> map) {
  final attributes = asJsonMap(map['attributes']);
  final relationships = asJsonMap(map['relationships']);
  return PostInfo(
    JsonValue.asInt(map['id']),
    JsonValue.asString(attributes['createdAt']),
    JsonValue.asString(attributes['contentHtml']),
    JsonValue.asString(attributes['editedAt']),
    _relatedIdFromMap(relationships, 'user'),
    _relatedIdFromMap(relationships, 'editedUser'),
    _relatedIdFromMap(relationships, 'discussion'),
    JsonValue.asInt(attributes['likesCount'], -1),
  );
}

TagInfo _fastTagFromMap(Map<String, Object?> map) {
  final attributes = asJsonMap(map['attributes']);
  final relationships = asJsonMap(map['relationships']);
  final isChild = JsonValue.asBool(attributes['isChild']);
  final parentId = isChild ? _relatedIdFromMap(relationships, 'parent') : -1;
  return TagInfo(
    JsonValue.asString(attributes['name']),
    JsonValue.asInt(map['id']),
    JsonValue.asString(attributes['description']),
    JsonValue.asString(attributes['slug']),
    JsonValue.asInt(attributes['discussionCount']),
    attributes.containsKey('position')
        ? JsonValue.asInt(attributes['position'], -1)
        : null,
    JsonValue.asString(attributes['lastPostedAt']),
    null,
    -1,
    isChild,
    parentId >= 0 ? parentId : null,
    JsonValue.asBool(attributes['canStartDiscussion'], true),
  );
}

DiscussionInfo _fastDiscussionFromMap(
  Map<String, Object?> map,
  Map<int, UserInfo> users,
  Map<int, PostInfo> posts,
  Map<int, TagInfo> tags,
) {
  final attributes = asJsonMap(map['attributes']);
  final relationships = asJsonMap(map['relationships']);
  final rawViewCount = attributes['viewCount'] ?? attributes['views'];
  final tagIds = _relatedIdsFromMap(relationships, 'tags');
  final firstPostId = _relatedIdFromMap(relationships, 'firstPost');

  final discussion = DiscussionInfo(
    JsonValue.asString(map['id']),
    JsonValue.asString(attributes['title']),
    JsonValue.asInt(attributes['commentCount']),
    JsonValue.asInt(attributes['participantCount']),
    JsonValue.asInt(rawViewCount),
    JsonValue.asDateTime(attributes['createdAt']),
    JsonValue.asDateTime(attributes['lastPostedAt']),
    JsonValue.asInt(attributes['lastPostNumber']),
    firstPostId,
    users[_relatedIdFromMap(relationships, 'user')] ?? UserInfo.deletedUser,
    users[_relatedIdFromMap(relationships, 'lastPostedUser')] ??
        UserInfo.deletedUser,
    firstPostId >= 0 ? posts[firstPostId] : null,
    firstPostId >= 0 ? [firstPostId] : <int>[],
    firstPostId >= 0 && posts[firstPostId] != null
        ? {firstPostId: posts[firstPostId]!}
        : <int, PostInfo>{},
    <int, UserInfo>{},
    [
      for (final id in tagIds)
        if (tags[id] != null) tags[id]!,
    ],
    attributes['subscription'] == null
        ? 0
        : JsonValue.asString(attributes['subscription']) == 'ignore'
        ? 2
        : 1,
  );

  final firstPostUserId = discussion.firstPost?.userId;
  if (firstPostUserId != null && firstPostUserId >= 0) {
    final firstPostUser = users[firstPostUserId];
    if (firstPostUser != null && discussion.firstPost != null) {
      discussion.firstPost!.user = firstPostUser;
      discussion.users[firstPostUserId] = firstPostUser;
    }
  }
  return discussion;
}

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

  factory Discussions.fromMapFast(Map map) {
    final json = asJsonMap(map);
    final included = asJsonList(json['included']);
    final rawData = asJsonList(json['data']);
    final users = <int, UserInfo>{};
    final posts = <int, PostInfo>{};
    final tags = <int, TagInfo>{};
    final list = <DiscussionInfo>[];

    for (final item in included) {
      final entry = asJsonMap(item);
      switch (JsonValue.asString(entry['type'])) {
        case 'users':
          final user = _fastUserFromMap(entry);
          users[user.id] = user;
          break;
        case 'posts':
          final post = _fastPostFromMap(entry);
          posts[post.id] = post;
          break;
        case 'tags':
          final tag = _fastTagFromMap(entry);
          tags[tag.id] = tag;
          break;
      }
    }

    for (final item in rawData) {
      list.add(_fastDiscussionFromMap(asJsonMap(item), users, posts, tags));
    }

    return Discussions(
      list: list,
      links: Links.formBase(PrivateBaseBean(asJsonMap(json['links']), null, const [])),
    );
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

  factory PagedDiscussions.fromMapFast(Map map) {
    final json = asJsonMap(map);
    final links = asJsonMap(json['links']);
    final rawNext = links['next'];
    return PagedDiscussions(
      data: Discussions.fromMapFast(json),
      nextUrl: rawNext is String && rawNext.isNotEmpty ? rawNext : null,
    );
  }
}
