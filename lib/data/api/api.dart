import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:forum/data/api/api_constants.dart';
import 'package:forum/data/model/notifications.dart';
import 'package:forum/utils/http_utils.dart';
import '../model/discussions.dart';
import '../model/fourm_info.dart';
import '../model/login_result.dart';
import '../model/posts.dart';
import '../model/tags.dart';
import '../model/users.dart';

enum PostSort {
  time, // 按时间
  number, // 按楼层（正常阅读）
}

class Api {
  static final HttpUtils _utils = HttpUtils();
  static Map<int, TagInfo>? _allTags;
  static Tags? _tags;

  static Future<ForumInfo?> checkUrl(String url) async {
    try {
      var info = ForumInfo.formJson((await Dio().get(url)).data);
      log("[Api] checkUrl Status:ok");
      return info;
    } catch (e) {
      log("[Api] checkUrl Error:$e");
      return null;
    }
  }

  static Future<Tags?> getTags() async {
    if (_tags != null) {
      return _tags;
    }
    _allTags = {};
    try {
      var t = TagInfo.getListFormJson(
        (await _utils.get(ApiConstants.tags)).data,
      );
      _tags = t;
      t.tags.forEach((_, tag) {
        final children = tag.children;
        if (children != null) {
          children.forEach((id, t) {
            _allTags?.addAll({t.id: t});
          });
        }
        _allTags?.addAll({tag.id: tag});
      });
      t.miniTags.forEach((id, tag) {
        _allTags?.addAll({tag.id: tag});
      });
      log("[Api] getTags Status:ok");
      return t;
    } catch (e) {
      log("[Api] getTags Error:$e");
      return null;
    }
  }

  static TagInfo? getTagById(int id) {
    return _allTags?[id];
  }

  static TagInfo? getTagBySlug(String slug) {
    for (var t in _allTags!.values.toList()) {
      if (t.slug == slug) {
        return t;
      }
    }
    return null;
  }

  static Future<DiscussionInfo?> getDiscussionById(String id) async {
    return getDiscussionByUrl("/discussions/$id");
  }

  static Future<DiscussionInfo?> getDiscussionByUrl(String url) async {
    try {
      var d = DiscussionInfo.formJson((await _utils.get(url)).data);
      log("[Api] getDiscussionById Status:ok");
      return d;
    } catch (e) {
      log("[Api] getDiscussionById Error:$e");
      return null;
    }
  }

  static Future<DiscussionInfo?> getDiscussionWithNearNumber(
    String id,
    int number,
  ) {
    String url =
        "${ApiConstants.apiBase}/api/discussions/$id?page[near]=$number";
    return getDiscussionByUrl(url);
  }

  static Future<PagedDiscussions?> getDiscussionList(
    String sortKey, {
    String? tagSlug,
    int offset = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'sort': sortKey,
      'page[offset]': offset.toString(),
      'page[limit]': limit.toString(),
      'include': 'user,tags,firstPost',
    };

    if (tagSlug != null) {
      params['filter[q]'] = 'tag:${Uri.encodeComponent(tagSlug)}';
    }

    final uri = Uri.parse(
      "${ApiConstants.apiBase}/api/discussions",
    ).replace(queryParameters: params);

    try {
      final resp = await _utils.get(uri.toString());
      final data = Discussions.formJson(resp.toString());

      log("[Api] On getDiscussionPage response");
      return PagedDiscussions(data: data, nextUrl: resp.data['links']?['next']);
    } catch (e) {
      log('[Api] getDiscussionPage error: $e');
      return null;
    }
  }

  static Future<Discussions?> searchDiscuss({
    required String key,
    String? tagSlug,
    int offset = 0,
    int limit = 20,
  }) async {
    final q = tagSlug == null || tagSlug.isEmpty
        ? key
        : "$key tag:${Uri.encodeComponent(tagSlug)}";

    final url =
        "${ApiConstants.apiBase}/api/discussions"
        "?include=user,lastPostedUser,mostRelevantPost,mostRelevantPost.user,firstPost,tags"
        "&filter[q]=${Uri.encodeComponent(q)}"
        "&page[offset]=$offset"
        "&page[limit]=$limit";

    return getDiscussionListByUrl(url);
  }

  static Future<PostInfo?> getFirstPost(String discussionId) async {
    final url =
        "${ApiConstants.apiBase}/api/posts"
        "?filter[discussion]=$discussionId"
        "&sort=number"
        "&page[limit]=1";

    try {
      var data = Posts.formJson((await _utils.get(url)).data);
      final posts = data.posts;
      if (posts.isEmpty) return null;

      // 第一个一定是 firstPost
      return posts.entries.first.value;
    } catch (e) {
      log("[Api] getFirstPost Error: $e");
      return null;
    }
  }

  static Future<Discussions?> getDiscussionListByUrl(String url) async {
    try {
      var data = Discussions.formJson((await _utils.get(url)).toString());
      log("[Api] getDiscussionListByUrl Status:ok");
      return data;
    } catch (e) {
      log("[Api] getDiscussionListByUrl Error:$e");
      return null;
    }
  }

  static Future<DiscussionInfo?> createDiscussion(
    List<TagInfo> tags,
    String title,
    String post,
  ) async {
    List<Map<String, String>> ts = [];
    for (var t in tags) {
      ts.add({"type": "tags", "id": t.id.toString()});
    }

    var m = {
      "data": {
        "type": "discussions",
        "attributes": {"title": title, "content": post},
        "relationships": {
          "tags": {"data": ts},
        },
      },
    };

    try {
      var r = await _utils.post(
        "${ApiConstants.apiBase}/api/discussions",
        data: m,
      );
      if (r?.statusCode == 201) {
        log("[Api] createDiscussion Status:ok");
        return DiscussionInfo.formJson(r?.data);
      } else {
        log("[Api] createDiscussion Status:${r?.statusCode}");
        return null;
      }
    } catch (e) {
      log("[Api] createDiscussion Error:$e");
      return null;
    }
  }

  static Future<Posts?> getPosts({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostSort sort = PostSort.number,
  }) async {
    final sortKey = switch (sort) {
      PostSort.time => 'createdAt',
      PostSort.number => 'number',
    };

    final url =
        "${ApiConstants.apiBase}/api/posts"
        "?filter[discussion]=$discussionId"
        "&sort=$sortKey"
        "&page[offset]=$offset"
        "&page[limit]=$limit&include=user";

    try {
      final data = Posts.formJson((await _utils.get(url)).toString());

      log(
        "[Api] getPosts Status:ok "
        "(discussion=$discussionId offset=$offset size=${data.posts.length})",
      );

      // Posts.posts 是 Map<String, PostInfo>
      return data;
    } catch (e) {
      log("[Api] getPosts Error:$e");
      return null;
    }
  }

  static Future<Posts?> getPostsById(List<int> l) async {
    var url = "${ApiConstants.apiBase}/api/posts?filter[id]=";
    for (var id in l) {
      url += "$id,";
    }
    url = url.substring(0, url.length - 1);
    try {
      var data = Posts.formJson((await _utils.get(url)).toString());
      log("[Api] getPostsById Status:ok");
      return data;
    } catch (e) {
      log("[Api] getPostsById Error:$e");
      return null;
    }
  }

  static Future<PostInfo?> createPost(String discussionId, String post) async {
    var m = {
      "data": {
        "type": "posts",
        "attributes": {"content": post},
        "relationships": {
          "discussion": {
            "data": {"type": "discussions", "id": discussionId},
          },
        },
      },
    };
    try {
      var data = PostInfo.formJson(
        (await _utils.post(
              "${ApiConstants.apiBase}/api/posts",
              data: m,
            ))?.toString() ??
            "{}",
      );
      log("[Api] createPost Status:ok");
      return data;
    } catch (e) {
      log("[Api] createPost Error:$e");
      return null;
    }
  }

  static Future<PostInfo?> replyToPost({
    required String discussionId,
    required int replyPostId,
    required String replyUsername,
    required String content,
  }) async {
    final fullContent = "@\"$replyUsername\"#p$replyPostId $content";
    return createPost(discussionId, fullContent);
  }

  static Future<PostInfo?> likePost(String id, bool isLiked) async {
    var m = {
      "data": {
        "type": "posts",
        "id": id,
        "attributes": {"isLiked": isLiked},
      },
    };
    try {
      var data = PostInfo.formJson(
        (await _utils.patch(
          "${ApiConstants.apiBase}/api/posts/$id",
          data: m,
        )).toString(),
      );
      log("[Api] likePost Status:ok");
      return data;
    } catch (e) {
      log("[Api] likePost Error:$e");
      return null;
    }
  }

  static Future<bool> setLastReadPostNumber(String postId, int number) async {
    try {
      var r = await _utils.patch(
        "${ApiConstants.apiBase}/api/discussions/$postId",
        data: {
          "data": {
            "type": "discussions",
            "id": postId,
            "attributes": {"lastReadPostNumber": number},
          },
        },
      );
      if (r.statusCode == 200) {
        log("[Api] setLastReadPostNumber Status:ok");
        return true;
      }
      log("[Api] setLastReadPostNumber Status:${r.statusCode}");
      return false;
    } catch (e) {
      log("[Api] setLastReadPostNumber Error:$e");
      return false;
    }
  }

  static Future<UserInfo?> getLoggedInUserInfo(LoginResult data) async {
    if (data.userId == -1) {
      return null;
    }
    HttpUtils.setToken("Token ${data.token};userId=${data.userId}");
    var u = await getUserInfoByNameOrId(data.userId.toString());
    return u;
  }

  static Future<UserInfo?> getUserInfoByNameOrId(String nameOrId) async {
    return getUserByUrl("${ApiConstants.apiBase}/api/users/$nameOrId");
  }

  static Future<bool> isTokenValid() async {
    try {
      await _utils.get("${ApiConstants.apiBase}/api/users/me");
      // 某些版本可能直接 200
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 405) {
        // 🎯 Flarum 特有：token 有效
        return true;
      }

      if (status == 401 || status == 403 || status == 404) {
        return false;
      }

      rethrow;
    }
  }

  static Future<(NotificationInfoList?, bool)> getNotification({
    String? url,
  }) async {
    final reqUrl =
        url ?? "${ApiConstants.apiBase}/api/notifications?page[limit]=20";

    try {
      final resp = await _utils.get(reqUrl);
      final data = NotificationInfoList.formJson(resp.toString());
      log("[Api] getNotification Status:ok url=$reqUrl");
      return (data, true);
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 401) {
        log("[Api] Notification fetch api with error : token expired.");
        return (null, false);
      } else {
        log("[Api] Notification fetch api with error : network error.");
        return (null, true);
      }
    } catch(e) {
        log("[Api] Notification fetch api with error : ", error: e);
      return (null, true);
    }
  }

  static Future<NotificationInfoList?> getNotificationByUrl(String url) async {
    try {
      var data = NotificationInfoList.formJson(
        (await _utils.get(url)).toString(),
      );
      log("[Api] getNotificationByUrl Status:ok");
      return data;
    } catch (e) {
      log("[Api] getNotificationByUrl Error:$e");
      return null;
    }
  }

  static Future<NotificationsInfo?> setNotificationIsRead(String id) async {
    var m = {
      "data": {
        "type": "notifications",
        "id": id,
        "attributes": {"isRead": true},
      },
    };
    try {
      var data = NotificationsInfo.formJson(
        (await _utils.patch(
          "${ApiConstants.apiBase}/api/notifications/$id",
          data: m,
        )).toString(),
      );
      log("[Api] setNotificationIsRead Error:ok");
      return data;
    } catch (e) {
      log("[Api] setNotificationIsRead Error:$e");
      return null;
    }
  }

  static Future<bool> readAllNotification() async {
    try {
      var r = await _utils.post(
        "${ApiConstants.apiBase}/api/notifications/read",
      );
      if (r?.statusCode == 204) {
        log("[Api] readAllNotification Status:ok");
        return true;
      }
      log("[Api] readAllNotification Status:${r?.statusCode}");
      return false;
    } catch (e) {
      log("[Api] readAllNotification Error:$e");
      return false;
    }
  }

  static Future<bool> clearAllNotification() async {
    try {
      final r = await _utils.delete(
        "${ApiConstants.apiBase}/api/notifications",
      );

      if (r.statusCode == 204) {
        log("[Api] clearAllNotification Status:ok");
        return true;
      }

      log("[Api] clearAllNotification Status:${r.statusCode}");
      return false;
    } catch (e) {
      log("[Api] clearAllNotification Error:$e");
      return false;
    }
  }

  static Future<UserInfo?> getUserByUrl(String url) async {
    try {
      var data = UserInfo.formJson((await _utils.get(url)).toString());
      log("[Api] getUserByUrl Status:ok");
      return data;
    } catch (e) {
      log("[Api] getUserByUrl Error:$e");
      return null;
    }
  }

  static Future<LoginResult?> login(String username, String password) async {
    Response<dynamic>? result;
    try {
      result = (await _utils.post(
        "${ApiConstants.apiBase}/api/token",
        data: {"identification": username, "password": password},
      ));
      var d = result?.data;
      LoginResult? data;
      if (d is Map) {
        data = LoginResult.formMap(d);
      } else {
        data = LoginResult.formMap(json.decode(d));
      }

      log("[Api] login Status:ok");
      return data;
    } catch (e) {
      log("[Api] login Error:$e");
      return null;
    }
  }
}
