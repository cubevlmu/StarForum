import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:forum/data/api/api_constants.dart';
import 'package:forum/data/api/api_guard.dart';
import 'package:forum/data/model/notifications.dart';
import 'package:forum/utils/http_utils.dart';
import 'package:forum/utils/log_util.dart';
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

  static Future<ForumInfo?> getForumInfo(String url) async {
    return ApiGuard.run(
      name: "getForumInfo",
      method: "GET",
      call: () async {
        return ForumInfo.formJson((await Dio().get(url)).toString());
      },
      fallback: null,
    );
  }

  static Future<Tags?> getTags() async {
    return ApiGuard.run(
      name: "getTags",
      method: "GET",
      call: () async {
        return TagInfo.getListFormJson(
          (await _utils.get(ApiConstants.tags)).toString(),
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
        return DiscussionInfo.formJson(
          (await _utils.get(
            "${ApiConstants.apiBase}/api/discussions/$id?include=user,firstPost",
          )).toString(),
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
          "${ApiConstants.apiBase}/api/discussions",
        ).replace(queryParameters: params);
        final resp = await _utils.get(uri.toString());
        final data = Discussions.formJson(resp.toString());

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
        "${ApiConstants.apiBase}/api/discussions"
        "?include=user,lastPostedUser,mostRelevantPost,mostRelevantPost.user,firstPost,tags"
        "&filter[q]=${Uri.encodeComponent(q)}"
        "&page[offset]=$offset"
        "&page[limit]=$limit";

    return ApiGuard.run(
      name: "searchDiscuss",
      method: "GET",
      call: () async {
        return Discussions.formJson((await _utils.get(url)).toString());
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
        "${ApiConstants.apiBase}/api/discussions"
        "?include=user,lastPostedUser,mostRelevantPost,mostRelevantPost.user,firstPost,tags"
        "&filter[tag]=$tag"
        "&page[offset]=$offset"
        "&page[limit]=$limit";

    return ApiGuard.run(
      name: "getDiscussByTag",
      method: "GET",
      call: () async {
        return Discussions.formJson((await _utils.get(url)).toString());
      },
      fallback: null,
    );
  }
  
  static Future<PostInfo?> getFirstPost(String discussionId) async {
    final url =
        "${ApiConstants.apiBase}/api/posts"
        "?filter[discussion]=$discussionId"
        "&sort=number"
        "&page[limit]=1";

    return ApiGuard.run(
      name: "getFirstPost",
      method: "GET",
      call: () async {
        var data = Posts.formJson((await _utils.get(url)).toString());
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
          "${ApiConstants.apiBase}/api/discussions",
          data: m,
          options: Options(contentType: 'application/vnd.api+json'),
        );
        if (r?.statusCode == 201) {
          return DiscussionInfo.formJson(r?.toString() ?? "");
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
        "${ApiConstants.apiBase}/api/posts"
        "?filter[discussion]=$discussionId"
        "&sort=$sortKey"
        "&page[offset]=$offset"
        "&page[limit]=$limit&include=user";

    return ApiGuard.run(
      name: "getPosts",
      method: "GET",
      call: () async {
        return Posts.formJson((await _utils.get(url)).toString());
      },
      fallback: null,
    );
  }

  static Future<Posts?> getPostsById(List<int> l) async {
    var url = "${ApiConstants.apiBase}/api/posts?filter[id]=${l.join(",")}";

    return ApiGuard.run(
      name: "getPostsById",
      method: "GET",
      call: () async {
        return Posts.formJson((await _utils.get(url)).toString());
      },
      fallback: null,
    );
  }

  static Future<Posts?> getPost(String id) async {
    var url = "${ApiConstants.apiBase}/api/posts?filter[id]=$id";

    return ApiGuard.run(
      name: "getPostsById",
      method: "GET",
      call: () async {
        return Posts.formJson((await _utils.get(url)).toString());
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
        return PostInfo.formJson(
          (await _utils.post(
                "${ApiConstants.apiBase}/api/posts",
                data: m,
              ))?.toString() ??
              "{}",
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
        return PostInfo.formJson(
          (await _utils.patch(
            "${ApiConstants.apiBase}/api/posts/$id",
            data: m,
          )).toString(),
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
    return getUserByUrl("${ApiConstants.apiBase}/api/users/$nameOrId");
  }

  static Future<bool> isTokenValid() async {
    try {
      await _utils.get("${ApiConstants.apiBase}/api/users?page[limit]=1");
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 401 || status == 403 || status == 404) {
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
        url ?? "${ApiConstants.apiBase}/api/notifications?page[limit]=20";

    return ApiGuard.runWithToken(
      name: "getNotification",
      method: "GET",
      call: () async {
        return NotificationInfoList.formJson(
          (await _utils.get(reqUrl)).toString(),
        );
      },
      fallback: null,
    );
  }

  static Future<NotificationInfoList?> getNotificationByUrl(String url) async {
    return ApiGuard.run(
      name: "getNotificationByUrl",
      method: "GET",
      call: () async =>
          NotificationInfoList.formJson((await _utils.get(url)).toString()),
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
      call: () async => NotificationsInfo.formJson(
        (await _utils.patch(
          "${ApiConstants.apiBase}/api/notifications/$id",
          data: m,
        )).toString(),
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
          "${ApiConstants.apiBase}/api/notifications/read",
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
          "${ApiConstants.apiBase}/api/notifications",
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
          "${ApiConstants.apiBase}/api/posts",
        ).replace(queryParameters: params);

        final resp = await _utils.get(uri.toString());
        final data = Posts.formJson(resp.toString());

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
      call: () async => UserInfo.formJson((await _utils.get(url)).toString()),
      fallback: null,
    );
  }

  static Future<LoginResult?> login(String username, String password) async {
    return ApiGuard.run(
      name: "login",
      method: "POST",
      call: () async {
        Response<dynamic>? result;
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

        return data;
      },
      fallback: null,
    );
  }
}
