import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:forum/data/api/api_guard.dart';
import 'package:forum/data/api/api_log.dart';
import 'package:forum/data/model/notifications.dart';
import 'package:forum/utils/http_utils.dart';
import 'package:forum/utils/log_util.dart';
import 'package:forum/utils/storage_utils.dart';
import '../model/discussions.dart';
import '../model/forum_info.dart';
import '../model/login_result.dart';
import '../model/posts.dart';
import '../model/tags.dart';
import '../model/users.dart';

enum PostSort { time, number }

class Api {
  static final HttpUtils _utils = HttpUtils();
  static ForumInfo? _buffered;
  static String _baseUrl = "";

  static String get getBaseUrl => _baseUrl;

  static Future<bool> setup() async {
    final r = StorageUtils.networkData.get(SettingsStorageKeys.apiBaseUrl) as String?;
    if (r == null) return false;
    if (r.isEmpty) return false;
    final (rr, _) = await getForumInfo(r);
    if (rr == null) return false;

    _baseUrl = r;
    return true;
  }

  static void setUrl(String url) {
    _baseUrl = url;
    StorageUtils.networkData.put(SettingsStorageKeys.apiBaseUrl, url);
  }

  static Future<(ForumInfo?, int)> getForumInfo(String url) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (_buffered != null && _buffered?.url == url) {
      ApiLog.ok("getForumInfo", "GET", "Local buffered. Url $url");
      return (_buffered, 0);
    }

    final sw = Stopwatch()..start();
    try {
      final result = ForumInfo.fromMap((await Dio().get("$url/api")).data);
      sw.stop();

      final time = sw.elapsedMilliseconds;
      int lagLevel = 0;
      if (time <= 500) {
        lagLevel = 0;
      } else if (time <= 1000) {
        lagLevel = 1;
      } else if (time <= 2000) {
        lagLevel = 2;
      } else if (time <= 5000) {
        lagLevel = 3;
      } else if (time < 10000) {
        lagLevel = 4;
      } else {
        lagLevel = 5;
      }
      ApiLog.ok("getForumInfo", "[GET] cost=${sw.elapsedMilliseconds}ms");

      _buffered = result;
      return (result, lagLevel);
    } catch (e, s) {
      sw.stop();

      ApiLog.exception(
        "getForumInfo",
        "[GET] cost=${sw.elapsedMilliseconds}ms",
        e,
        s,
      );
      _buffered = null;
      return (null, -1);
    }
  }

  static Future<Tags?> getTags() async {
    return ApiGuard.run(
      name: "getTags",
      method: "GET",
      call: () async {
        return TagInfo.getListFormMap(
          (await _utils.get("$_baseUrl/api/tags")).data,
        );
      },
      fallback: null,
    );
  }

  static Future<DiscussionInfo?> getDiscussionById(String id) async {
    return ApiGuard.run(
      name: "getDiscussionById",
      method: "GET",
      call: () async {
        return DiscussionInfo.fromMap(
          (await _utils.get(
            "$_baseUrl/api/discussions/$id?include=user,firstPost",
          )).data,
        );
      },
      fallback: null,
    );
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

    return ApiGuard.run(
      name: "getDiscussionList",
      method: "GET",
      call: () async {
        final uri = Uri.parse(
          "$_baseUrl/api/discussions",
        ).replace(queryParameters: params);
        final resp = await _utils.get(uri.toString());
        final data = Discussions.fromMap(resp.data);

        return PagedDiscussions(
          data: data,
          nextUrl: resp.data['links']?['next'],
        );
      },
      fallback: null,
    );
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
        "$_baseUrl/api/discussions"
        "?include=user,lastPostedUser,mostRelevantPost,mostRelevantPost.user,firstPost,tags"
        "&filter[q]=${Uri.encodeComponent(q)}"
        "&page[offset]=$offset"
        "&page[limit]=$limit";

    return ApiGuard.run(
      name: "searchDiscuss",
      method: "GET",
      call: () async {
        return Discussions.fromMap((await _utils.get(url)).data);
      },
      fallback: null,
    );
  }

  static Future<Discussions?> getDiscussByTag({
    required String tag,
    int offset = 0,
    int limit = 20,
  }) async {
    final url =
        "$_baseUrl/api/discussions"
        "?include=user,lastPostedUser,mostRelevantPost,mostRelevantPost.user,firstPost,tags"
        "&filter[tag]=$tag"
        "&page[offset]=$offset"
        "&page[limit]=$limit";

    return ApiGuard.run(
      name: "getDiscussByTag",
      method: "GET",
      call: () async {
        return Discussions.fromMap((await _utils.get(url)).data);
      },
      fallback: null,
    );
  }

  static Future<PostInfo?> getFirstPost(String discussionId) async {
    final url =
        "$_baseUrl/api/posts"
        "?filter[discussion]=$discussionId"
        "&sort=number"
        "&page[limit]=1";

    return ApiGuard.run(
      name: "getFirstPost",
      method: "GET",
      call: () async {
        var data = Posts.fromMap((await _utils.get(url)).data);
        final posts = data.posts;
        if (posts.isEmpty) return null;

        return posts.entries.first.value;
      },
      fallback: null,
    );
  }

  static Future<(DiscussionInfo?, bool)> createDiscussion(
    List<int> tags,
    String title,
    String post,
  ) async {
    List<Map<String, String>> ts = [];
    for (var t in tags) {
      ts.add({"type": "tags", "id": t.toString()});
    }

    var m = {
      "data": {
        "type": "discussions",
        "attributes": {"title": title.toString(), "content": post.toString()},
        "relationships": {
          "tags": {"data": ts},
        },
      },
    };

    return ApiGuard.runWithToken(
      name: "createDiscussion",
      method: "POST",
      call: () async {
        var r = await _utils.post(
          "$_baseUrl/api/discussions",
          data: m,
          options: Options(contentType: 'application/vnd.api+json'),
        );
        if (r?.statusCode == 201) {
          return DiscussionInfo.fromMap(r?.data);
        } else {
          return null;
        }
      },
      fallback: null,
    );
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
        "$_baseUrl/api/posts"
        "?filter[discussion]=$discussionId"
        "&sort=$sortKey"
        "&page[offset]=$offset"
        "&page[limit]=$limit&include=user";

    return ApiGuard.run(
      name: "getPosts",
      method: "GET",
      call: () async {
        return Posts.fromMap((await _utils.get(url)).data);
      },
      fallback: null,
    );
  }

  static Future<Posts?> getPostsById(List<int> l) async {
    var url = "$_baseUrl/api/posts?filter[id]=${l.join(",")}";

    return ApiGuard.run(
      name: "getPostsById",
      method: "GET",
      call: () async {
        return Posts.fromMap((await _utils.get(url)).data);
      },
      fallback: null,
    );
  }

  static Future<Posts?> getPost(String id) async {
    var url = "$_baseUrl/api/posts?filter[id]=$id";

    return ApiGuard.run(
      name: "getPostsById",
      method: "GET",
      call: () async {
        return Posts.fromMap((await _utils.get(url)).data);
      },
      fallback: null,
    );
  }

  static Future<(PostInfo?, bool)> createPost(
    String discussionId,
    String post,
  ) async {
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

    return ApiGuard.runWithToken(
      name: "createPost",
      method: "POST",
      call: () async {
        return PostInfo.fromMap(
          (await _utils.post(
            "$_baseUrl/api/posts",
            data: m,
          ))?.data,
        );
      },
      fallback: null,
    );
  }

  static Future<(PostInfo?, bool)> replyToPost({
    required String discussionId,
    required int replyPostId,
    required String replyUsername,
    required String content,
  }) async {
    final fullContent = "@\"$replyUsername\"#p$replyPostId $content";
    return createPost(discussionId, fullContent);
  }

  static Future<(PostInfo?, bool)> likePost(String id, bool isLiked) async {
    var m = {
      "data": {
        "type": "posts",
        "id": id,
        "attributes": {"isLiked": isLiked},
      },
    };

    return ApiGuard.runWithToken(
      name: "likePost",
      method: "POST",
      call: () async {
        return PostInfo.fromMap(
          (await _utils.patch(
            "$_baseUrl/api/posts/$id",
            data: m,
          )).data,
        );
      },
      fallback: null,
    );
  }

  static Future<bool> setLastReadPostNumber(String postId, int number) async {
    return ApiGuard.run(
      name: "setLastReadPostNumber",
      method: "PATCH",
      call: () async {
        var r = await _utils.patch(
          "$_baseUrl/api/discussions/$postId",
          data: {
            "data": {
              "type": "discussions",
              "id": postId,
              "attributes": {"lastReadPostNumber": number},
            },
          },
        );
        if (r.statusCode == 200) {
          return true;
        }
        return false;
      },
      fallback: false,
    );
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
    return getUserByUrl("$_baseUrl/api/users/$nameOrId");
  }

  static Future<bool> isTokenValid() async {
    try {
      await _utils.get("$_baseUrl/api/users?page[limit]=1");
      ApiLog.ok("isTokenValid", "Token varified.");
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      LogUtil.debug("[API] isTokenValid : ${e.response.toString()}");
      if (status == 401 || status == 403 || status == 404) {
        return false;
      }
      if (status == 500) {
        ApiLog.fail("isTokenValid", "check token varified.", "Token expired.");
        return false;
      }

      rethrow;
    } catch (e, s) {
      LogUtil.errorE("[API] Network error with :", e, s);
      return false;
    }
  }

  static Future<(NotificationInfoList?, bool)> getNotification({
    String? url,
  }) async {
    final reqUrl =
        url ?? "$_baseUrl/api/notifications?page[limit]=20";

    return ApiGuard.runWithToken(
      name: "getNotification",
      method: "GET",
      call: () async {
        return NotificationInfoList.fromMap((await _utils.get(reqUrl)).data);
      },
      fallback: null,
    );
  }

  static Future<NotificationInfoList?> getNotificationByUrl(String url) async {
    return ApiGuard.run(
      name: "getNotificationByUrl",
      method: "GET",
      call: () async =>
          NotificationInfoList.fromMap((await _utils.get(url)).data),
      fallback: null,
    );
  }

  static Future<NotificationsInfo?> setNotificationIsRead(String id) async {
    var m = {
      "data": {
        "type": "notifications",
        "id": id,
        "attributes": {"isRead": true},
      },
    };
    return ApiGuard.run(
      name: "setNotificationIsRead",
      method: "PATCH",
      call: () async => NotificationsInfo.fromMap(
        (await _utils.patch(
          "$_baseUrl/api/notifications/$id",
          data: m,
        )).data,
      ),
      fallback: null,
    );
  }

  static Future<bool> readAllNotification() async {
    return ApiGuard.run(
      name: "readAllNotification",
      method: "GET",
      call: () async {
        var r = await _utils.post(
          "$_baseUrl/api/notifications/read",
        );
        if (r?.statusCode == 204) {
          return true;
        }
        return false;
      },
      fallback: false,
    );
  }

  static Future<bool> clearAllNotification() async {
    return ApiGuard.run(
      name: "clearAllNotification",
      method: "GET",
      call: () async {
        final r = await _utils.delete(
          "$_baseUrl/api/notifications",
        );

        if (r.statusCode == 204) {
          return true;
        }

        return false;
      },
      fallback: false,
    );
  }

  static Future<Posts?> getPostsByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
  }) async {
    return ApiGuard.run(
      name: "getPostsByAuthor",
      method: "GET",
      call: () async {
        final params = <String, String>{
          'filter[author]': username,
          'page[offset]': offset.toString(),
          'page[limit]': limit.toString(),
          'sort': '-createdAt',
          'include': 'user,discussion',
          'filter[type]': 'comment',
        };

        final uri = Uri.parse(
          "$_baseUrl/api/posts",
        ).replace(queryParameters: params);

        final resp = await _utils.get(uri.toString());
        final data = Posts.fromMap(resp.data);

        return data;
      },
      fallback: null,
      extra: "(user=$username offset=$offset)",
    );
  }

  static Future<UserInfo?> getUserByUrl(String url) async {
    return ApiGuard.run(
      name: "getUserByUrl",
      method: "GET",
      call: () async => UserInfo.fromMap((await _utils.get(url)).data),
      fallback: null,
    );
  }

  static Future<LoginResult?> login(String username, String password) async {
    return ApiGuard.run(
      name: "login",
      method: "POST",
      call: () async {
        Response<dynamic>? result;
        LogUtil.debug("$_baseUrl/api/token");
        result = (await _utils.post(
          "$_baseUrl/api/token",
          data: {"identification": username, "password": password},
        ));
        var d = result?.data;
        LoginResult? data;
        if (d is Map) {
          data = LoginResult.formMap(d);
        } else {
          data = LoginResult.formMap(json.decode(d));
        }

        return data;
      },
      fallback: null,
    );
  }
}
