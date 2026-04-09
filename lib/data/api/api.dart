import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:star_forum/data/api/api_constants.dart';
import 'package:star_forum/data/api/api_guard.dart';
import 'package:star_forum/data/api/api_log.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/model/user_item.dart';
import 'package:star_forum/utils/http_utils.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/storage_utils.dart';
import 'package:star_forum/utils/string_util.dart';
import '../model/badge.dart';
import '../model/discussions.dart';
import '../model/forum_info.dart';
import '../model/group_info.dart';
import '../model/login_result.dart';
import '../model/posts.dart';
import '../model/tags.dart';
import '../model/users.dart';
import '../model/base.dart';

enum PostSort { time, number }

enum _ApiParseKind {
  forumInfo,
  tags,
  discussionInfo,
  pagedDiscussions,
  discussions,
  posts,
  postInfo,
  notificationInfoList,
  notificationsInfo,
  userInfo,
  loginResult,
}

enum UserSort {
  unknown,
  username,
  usernameD,
  joinedAtD,
  joinedAt,
  discussionCountD,
  discussionCount,
  expD,
  exp,
}

enum FollowingSort { hottest, latestReply, newest, oldest, mostViews }

@immutable
class _ApiParseRequest {
  const _ApiParseRequest({required this.kind, required this.data});

  final _ApiParseKind kind;
  final Object? data;
}

Map<String, Object?> _apiAsJsonMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  if (value is String) {
    final decoded = json.decode(value);
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
  }
  return <String, Object?>{};
}

Object? _parseApiPayload(_ApiParseRequest request) {
  switch (request.kind) {
    case _ApiParseKind.forumInfo:
      return ForumInfo.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.tags:
      return TagInfo.getListFormMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.discussionInfo:
      return DiscussionInfo.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.pagedDiscussions:
      final json = _apiAsJsonMap(request.data);
      return PagedDiscussions(
        data: Discussions.fromMap(json),
        nextUrl: _apiAsJsonMap(json['links'])['next'] as String?,
      );
    case _ApiParseKind.discussions:
      return Discussions.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.posts:
      return Posts.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.postInfo:
      return PostInfo.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.notificationInfoList:
      return NotificationInfoList.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.notificationsInfo:
      return NotificationsInfo.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.userInfo:
      return UserInfo.fromMap(_apiAsJsonMap(request.data));
    case _ApiParseKind.loginResult:
      return LoginResult.formMap(_apiAsJsonMap(request.data));
  }
}

/// Flarum REST API access layer.
///
/// This class centralizes forum base URL management, request entry points,
/// authentication handling, and response deserialization for upper-layer
/// controllers and repositories.
class Api {
  static final HttpUtils _utils = HttpUtils();
  static ForumInfo? _buffered;
  static String _baseUrl = "";

  static String get getBaseUrl => _baseUrl;
  static bool get hasFixedBaseUrl => _getFixedBaseUrl() != null;

  static String? _normalizeBaseUrl(String? url) {
    if (url == null) return null;
    return StringUtil.normalizeSiteUrl(url);
  }

  static String? _getFixedBaseUrl() {
    return _normalizeBaseUrl(ApiConstants.fixedApi);
  }

  static Future<T> _parseInBackground<T>(
    Object? data,
    _ApiParseKind kind,
  ) async {
    final parsed = await compute(
      _parseApiPayload,
      _ApiParseRequest(kind: kind, data: data),
    );
    return parsed as T;
  }

  static Future<T?> _parseNullableInBackground<T>(
    Object? data,
    _ApiParseKind kind,
  ) async {
    if (data == null) {
      return null;
    }
    return _parseInBackground<T>(data, kind);
  }

  static Groups? _resolveUserGroups(BaseData data, BaseIncluded included) {
    final ids = data.relatedIds('groups');
    if (ids.isEmpty) {
      return null;
    }

    final groups = <GroupInfo>[];
    for (final id in ids) {
      final item = included.find('groups', id);
      if (item != null) {
        groups.add(GroupInfo.fromBaseData(item));
      }
    }
    return groups.isEmpty ? null : Groups(list: groups);
  }

  /// Initializes the API base URL.
  ///
  /// This prefers a fixed URL from configuration when available. Otherwise it
  /// loads the persisted URL from local storage and validates it by calling
  /// `/api` once.
  ///
  /// Returns `true` when the site is reachable and `_baseUrl` is set.
  static Future<bool> setup() async {
    final fixedUrl = _getFixedBaseUrl();
    if (fixedUrl != null) {
      final (rr, _) = await getForumInfo(fixedUrl);
      if (rr == null) return false;

      _baseUrl = fixedUrl;
      await StorageUtils.networkData.put(
        SettingsStorageKeys.apiBaseUrl,
        fixedUrl,
      );
      return true;
    }

    final r = _normalizeBaseUrl(
      StorageUtils.networkData.get(SettingsStorageKeys.apiBaseUrl) as String?,
    );
    if (r == null) return false;
    if (r.isEmpty) return false;
    final (rr, _) = await getForumInfo(r);
    if (rr == null) return false;

    _baseUrl = r;
    return true;
  }

  /// Sets the current forum base URL.
  ///
  /// If the project uses a fixed site URL, the input value is ignored and the
  /// fixed URL is always used. Otherwise the URL is normalized and persisted
  /// for reuse on the next launch.
  static void setUrl(String url) {
    final fixedUrl = _getFixedBaseUrl();
    if (fixedUrl != null) {
      _baseUrl = fixedUrl;
      StorageUtils.networkData.put(SettingsStorageKeys.apiBaseUrl, fixedUrl);
      return;
    }

    final normalizedUrl = _normalizeBaseUrl(url);
    if (normalizedUrl == null || normalizedUrl.isEmpty) return;

    _baseUrl = normalizedUrl;
    StorageUtils.networkData.put(SettingsStorageKeys.apiBaseUrl, normalizedUrl);
  }

  static Future<Discussions?> getDiscussionsByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{
        'filter[author]': username,
        'sort': '-createdAt',
        'page[offset]': offset.toString(),
        'page[limit]': limit.toString(),
        'include': 'user,lastPostedUser,tags', //firstPost
        'fields[discussions]': 'title,createdAt,commentCount,lastPostedAt',
        'fields[users]': 'username,avatarUrl',
        'fields[tags]': 'name,slug,color',
        //'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
      };

      final response = await _utils.get(
        '/discussions',
        queryParameters: params,
      );

      return _parseInBackground<Discussions>(
        response,
        _ApiParseKind.discussions,
      );
    } catch (e, s) {
      ApiLog.exception("getDiscussionsByAuthor", "[GET]", e, s);
      return null;
    }
  }

  static Future<Discussions?> getAuthorThemes({
    required String username,
    int offset = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'filter[author]': username,
      'sort': '-createdAt',
      'page[offset]': offset.toString(),
      'page[limit]': limit.toString(),

      'include': 'user,lastPostedUser,tags',
      // 'fields[discussions]':
      //     'title,commentCount,participantCount,createdAt,lastPostedAt,views,subscription',
      // 'fields[users]': 'username,displayName,avatarUrl',
      // 'fields[tags]': 'name,slug,color,icon',
      // 'fields[posts]': 'contentHtml,createdAt',
    };

    return ApiGuard.run(
      name: "getDiscussionsByAuthor",
      method: "GET",
      call: () async {
        final uri = Uri.parse(
          "$_baseUrl/api/discussions",
        ).replace(queryParameters: params);

        final resp = await _utils.get(uri.toString());

        return _parseInBackground<Discussions>(
          resp.data,
          _ApiParseKind.discussions,
        );
      },
      fallback: null,
    );
  }

  static Future<bool> uploadAvatar({
    required int userId,
    required Uint8List fileData,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(fileData, filename: fileName),
      });

      final resp = await _utils.post(
        '$_baseUrl/api/users/$userId/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return resp.statusCode == 200;
    } catch (e, s) {
      ApiLog.exception("uploadAvatar", "[POST]", e, s);
      return false;
    }
  }

  static Future<bool> updateUser({
    required int userId,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      final data = {
        "data": {
          "type": "users",
          "id": userId.toString(),
          "attributes": attributes ?? {},
        },
      };

      final resp = await _utils.patch(
        '$_baseUrl/api/users/$userId',
        data: data,
        options: Options(contentType: 'application/json'),
      );

      return resp.statusCode == 200;
    } catch (e, s) {
      ApiLog.exception("updateUser", "[PATCH]", e, s);
      return false;
    }
  }

  static Future<bool> updateBio(int userId, String bio) {
    return updateUser(userId: userId, attributes: {"bio": bio});
  }

  static Future<bool> updateUsername(int userId, String username) {
    return updateUser(userId: userId, attributes: {"username": username});
  }

  static Future<bool> updateNickname(int userId, String name) {
    return updateUser(userId: userId, attributes: {"nickname": name});
  }

  static Future<bool> updateEmail(int userId, String email) {
    return updateUser(userId: userId, attributes: {"email": email});
  }

  static Future<bool> updatePassword(int userId, String password) {
    return updateUser(userId: userId, attributes: {"password": password});
  }

  static String? _userSortValue(UserSort sort) {
    switch (sort) {
      case UserSort.username:
        return 'username';
      case UserSort.usernameD:
        return '-username';
      case UserSort.joinedAt:
        return 'joinedAt';
      case UserSort.joinedAtD:
        return '-joinedAt';
      case UserSort.discussionCount:
        return 'discussionCount';
      case UserSort.discussionCountD:
        return '-discussionCount';
      case UserSort.exp:
        return 'exp';
      case UserSort.expD:
        return '-exp';
      case UserSort.unknown:
        return null;
    }
  }

  static String _followingSortValue(FollowingSort sort) {
    switch (sort) {
      case FollowingSort.hottest:
        return '';
      case FollowingSort.latestReply:
        return '-commentCount';
      case FollowingSort.newest:
        return '-createdAt';
      case FollowingSort.oldest:
        return 'createdAt';
      case FollowingSort.mostViews:
        return '-view_count';
    }
  }

  static Future<List<UserInfo>?> getUserDirectory({
    int limit = 100,
    int offset = 0,
    UserSort sort = UserSort.unknown,
  }) async {
    return ApiGuard.run(
      name: "getUserDirectory",
      method: "GET",
      call: () async {
        final sortValue = _userSortValue(sort);
        final resp = await _utils.get(
          "$_baseUrl/api/users",
          queryParameters: <String, String>{
            'page[limit]': limit.toString(),
            'page[offset]': offset.toString(),
            'include': 'groups',
            'sort': sortValue ?? '-joinedAt',
          },
        );

        final base = BaseListBean.fromMap(resp.data);
        final result = <UserInfo>[];
        for (final item in base.data.list) {
          final attrs = Map<String, Object?>.from(item.attributes);
          final groups = _resolveUserGroups(item, base.included);
          if (groups != null) {
            attrs['groups'] = groups;
          }
          result.add(
            UserInfo.fromBaseData(
              BaseData(item.type, item.id, attrs, item.relationships),
            ),
          );
        }
        return result;
      },
      fallback: null,
    );
  }

  /// Fetches forum metadata from `/api`.
  ///
  /// This is the main Flarum forum info endpoint and is typically used during
  /// startup to validate connectivity and load global site metadata such as the
  /// title, logo, and welcome content.
  ///
  /// Returns:
  /// - `ForumInfo?`: the parsed forum info, or `null` on failure
  /// - `int`: a simple latency level from `0-5`; `-1` means the request failed
  ///
  /// This method also uses an in-memory cache and returns `_buffered` for the
  /// same URL when available.
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
      final response = await _utils.get("$url/api");
      final result = await _parseInBackground<ForumInfo>(
        response.data,
        _ApiParseKind.forumInfo,
      );
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

  /// Fetches the tag list from `/api/tags`.
  ///
  /// The returned tag data is organized into the `Tags` structure, including
  /// parent-child relationships, so UI code can render it directly.
  static Future<Tags?> getTags() async {
    return ApiGuard.run(
      name: "getTags",
      method: "GET",
      call: () async {
        return _parseInBackground<Tags>(
          (await _utils.get("$_baseUrl/api/tags")).data,
          _ApiParseKind.tags,
        );
      },
      fallback: null,
    );
  }

  static Future<bool> setDiscussionFollow(
    String discussionId,
    bool follow,
  ) async {
    return ApiGuard.run(
      name: "setDiscussionFollow",
      method: "PATCH",
      call: () async {
        final body = {
          "data": {
            "type": "discussions",
            "id": discussionId,
            "attributes": {"subscription": follow ? "follow" : null},
          },
        };

        final r = await _utils.patch(
          "$_baseUrl/api/discussions/$discussionId",
          data: body,
        );

        return r.statusCode == 200;
      },
      fallback: false,
    );
  }

  /// Fetches a single discussion by ID from `/api/discussions/{id}`.
  ///
  /// The request currently includes `user` and `firstPost`, which is suitable
  /// for discussion detail pages.
  static Future<DiscussionInfo?> getDiscussionById(String id) async {
    return ApiGuard.run(
      name: "getDiscussionById",
      method: "GET",
      call: () async {
        return _parseInBackground<DiscussionInfo>(
          (await _utils.get(
            "$_baseUrl/api/discussions/$id?include=user,firstPost",
          )).data,
          _ApiParseKind.discussionInfo,
        );
      },
      fallback: null,
    );
  }

  /// Fetches a discussion list from `/api/discussions`.
  ///
  /// Parameters:
  /// - [sortKey]: a Flarum sort field such as `-createdAt` or `-commentCount`
  /// - [tagSlug]: optional tag filter, converted into `filter[q]=tag:...`
  /// - [offset]/[limit]: pagination arguments
  ///
  /// Returns `PagedDiscussions`, including both parsed discussion data and the
  /// server-provided next-page link when present.
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

      'include': 'user,lastPostedUser,tags,firstPost',
      'fields[users]': 'username,displayName,avatarUrl',
      'fields[tags]':
          'name,description,slug,discussionCount,position,lastPostedAt,isChild,canStartDiscussion',
      'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
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
        return _parseInBackground<PagedDiscussions>(
          resp.data,
          _ApiParseKind.pagedDiscussions,
        );
      },
      fallback: null,
    );
  }

  static Future<PagedDiscussions?> getFollowingDiscussionList({
    FollowingSort sort = FollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) async {
    final sortKey = _followingSortValue(sort);
    final params = <String, String>{
      'filter[subscription]': 'following',
      'page[offset]': offset.toString(),
      'page[limit]': limit.toString(),
      'include': 'user,lastPostedUser,tags,firstPost',
      'fields[users]': 'username,displayName,avatarUrl',
      'fields[tags]': 'name,slug,color',
      'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
    };

    if (sortKey.isNotEmpty) {
      params['sort'] = sortKey;
    }

    return ApiGuard.run(
      name: "getFollowingDiscussionList",
      method: "GET",
      call: () async {
        final uri = Uri.parse(
          "$_baseUrl/api/discussions",
        ).replace(queryParameters: params);

        final resp = await _utils.get(uri.toString());

        return _parseInBackground<PagedDiscussions>(
          resp.data,
          _ApiParseKind.pagedDiscussions,
        );
      },
      fallback: null,
    );
  }

  /// Searches discussions via `/api/discussions`.
  ///
  /// Flarum uses `filter[q]` for search. This wrapper also supports appending a
  /// tag constraint into the same query string, which is useful for full-text
  /// search pages with optional tag scoping.
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
        return _parseInBackground<Discussions>(
          (await _utils.get(url)).data,
          _ApiParseKind.discussions,
        );
      },
      fallback: null,
    );
  }

  /// Fetches discussions filtered by tag.
  ///
  /// This uses `/api/discussions?filter[tag]=...` and is a more direct tag
  /// filter than full-text search, which makes it suitable for tag feeds and
  /// paginated tag pages.
  static Future<Discussions?> getDiscussByTag({
    required String tag,
    int offset = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'include': 'user,lastPostedUser,firstPost,tags',
      'filter[tag]': tag,
      'page[offset]': offset.toString(),
      'page[limit]': limit.toString(),

      'fields[users]': 'username,displayName,avatarUrl',
      'fields[tags]':
          'name,description,slug,discussionCount,position,lastPostedAt,isChild,canStartDiscussion',
      'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
    };

    return ApiGuard.run(
      name: "getDiscussByTag",
      method: "GET",
      call: () async {
        final uri = Uri.parse(
          "$_baseUrl/api/discussions",
        ).replace(queryParameters: params);

        final resp = await _utils.get(uri.toString());

        return _parseInBackground<Discussions>(
          resp.data,
          _ApiParseKind.discussions,
        );
      },
      fallback: null,
    );
  }

  /// Fetches the first post in a discussion.
  ///
  /// This queries `/api/posts`, sorts by `number`, and limits the result to one
  /// item. It returns `null` when the discussion has no posts.
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
        final data = await _parseInBackground<Posts>(
          (await _utils.get(url)).data,
          _ApiParseKind.posts,
        );
        final posts = data.posts;
        if (posts.isEmpty) return null;

        return posts.entries.first.value;
      },
      fallback: null,
    );
  }

  /// Creates a discussion via `/api/discussions`.
  ///
  /// Parameters:
  /// - [tags]: the tag ID list to attach
  /// - [title]: discussion title
  /// - [post]: first-post content
  ///
  /// Returns `(DiscussionInfo?, bool)`. The boolean is propagated by
  /// `ApiGuard.runWithToken` and is typically used to signal whether the login
  /// state is still valid.
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
          return _parseNullableInBackground<DiscussionInfo>(
            r?.data,
            _ApiParseKind.discussionInfo,
          );
        } else {
          return null;
        }
      },
      fallback: null,
    );
  }

  /// Fetches posts for a discussion from `/api/posts`.
  ///
  /// Parameters:
  /// - [discussionId]: owning discussion ID
  /// - [offset]/[limit]: pagination arguments
  /// - [sort]: post order, either by creation time or post number
  ///
  /// The request currently includes `user` so callers can access author data
  /// without an extra round trip.
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
        return _parseInBackground<Posts>(
          (await _utils.get(url)).data,
          _ApiParseKind.posts,
        );
      },
      fallback: null,
    );
  }

  /// Fetches multiple posts by ID.
  ///
  /// This uses `/api/posts?filter[id]=1,2,3` and is useful for notifications,
  /// jump recovery, or any flow that needs several posts in one request.
  static Future<Posts?> getPostsById(List<int> l) async {
    var url = "$_baseUrl/api/posts?filter[id]=${l.join(",")}";

    return ApiGuard.run(
      name: "getPostsById",
      method: "GET",
      call: () async {
        return _parseInBackground<Posts>(
          (await _utils.get(url)).data,
          _ApiParseKind.posts,
        );
      },
      fallback: null,
    );
  }

  /// Fetches a single post.
  ///
  /// Internally this still uses `filter[id]`, so the return type remains
  /// `Posts?` and the caller is expected to extract the target post.
  static Future<Posts?> getPost(String id) async {
    var url = "$_baseUrl/api/posts?filter[id]=$id";

    return ApiGuard.run(
      name: "getPostsById",
      method: "GET",
      call: () async {
        return _parseInBackground<Posts>(
          (await _utils.get(url)).data,
          _ApiParseKind.posts,
        );
      },
      fallback: null,
    );
  }

  /// Creates a post in the given discussion via `/api/posts`.
  ///
  /// This is the standard reply endpoint and sends the body as
  /// `attributes.content`.
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
        return _parseNullableInBackground<PostInfo>(
          (await _utils.post("$_baseUrl/api/posts", data: m))?.data,
          _ApiParseKind.postInfo,
        );
      },
      fallback: null,
    );
  }

  /// Creates a reply formatted as a response to a specific post.
  ///
  /// This does not call a dedicated Flarum reply endpoint. Instead it prefixes
  /// the content with the project's inline reply format and then reuses
  /// [createPost].
  static Future<(PostInfo?, bool)> replyToPost({
    required String discussionId,
    required int replyPostId,
    required String replyUsername,
    required String content,
  }) async {
    final fullContent = "@\"$replyUsername\"#p$replyPostId $content";
    return createPost(discussionId, fullContent);
  }

  /// Sets the liked state of a post via `/api/posts/{id}`.
  ///
  /// [isLiked] is the target state, not a toggle instruction, so the caller is
  /// responsible for tracking the current state.
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
        return _parseInBackground<PostInfo>(
          (await _utils.patch("$_baseUrl/api/posts/$id", data: m)).data,
          _ApiParseKind.postInfo,
        );
      },
      fallback: null,
    );
  }

  /// Updates the last read post number for a discussion.
  ///
  /// This is commonly used to sync reading progress and returns `true` on
  /// success.
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

  /// Fetches the currently logged-in user's profile from a login result.
  ///
  /// This first sets the auth token header and then reuses the user detail
  /// endpoint to load the full user record.
  static Future<UserInfo?> getLoggedInUserInfo(LoginResult data) async {
    if (data.userId == -1) {
      return null;
    }
    HttpUtils.setToken("Token ${data.token};userId=${data.userId}");
    var u = await getUserInfoByNameOrId(data.userId.toString());
    return u;
  }

  /// Fetches a user by username or user ID.
  ///
  /// Flarum supports both forms in `/api/users/{idOrUsername}`, and this method
  /// exposes them through one wrapper.
  static Future<UserInfo?> getUserInfoByNameOrId(String nameOrId) async {
    return getUserByUrl("$_baseUrl/api/users/$nameOrId");
  }

  /// Checks whether the current auth token is still valid.
  ///
  /// This calls a user list endpoint that requires authentication. Common
  /// failure status codes such as `401`, `403`, `404`, and `500` are treated as
  /// invalid-token cases; other exceptions are rethrown.
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

  /// Fetches notifications from `/api/notifications`.
  ///
  /// If [url] is provided, that URL is requested directly. Otherwise this
  /// loads the first page with a page size of 20. It is intended to support
  /// both the initial notification page and pagination flows.
  static Future<(NotificationInfoList?, bool)> getNotification({
    String? url,
  }) async {
    final reqUrl = url ?? "$_baseUrl/api/notifications?page[limit]=20";

    return ApiGuard.runWithToken(
      name: "getNotification",
      method: "GET",
      call: () async {
        return _parseInBackground<NotificationInfoList>(
          (await _utils.get(reqUrl)).data,
          _ApiParseKind.notificationInfoList,
        );
      },
      fallback: null,
    );
  }

  static Future<BadgeCategories?> getBadgeCategories() async {
    final params = <String, String>{
      'include': 'badges',
      // Keep the relationship field, otherwise sparse fieldsets strip
      // `relationships.badges` and the UI can't bind categories to badges.
      'fields[badgeCategories]': 'name,description,badges',
      'fields[badges]': 'name,icon,description,earnedAmount',
    };

    return ApiGuard.run(
      name: "getBadgeCategories",
      method: "GET",
      call: () async {
        final uri = Uri.parse(
          "$_baseUrl/api/badge_categories",
        ).replace(queryParameters: params);

        final resp = await _utils.get(uri.toString());

        return BadgeCategories.fromMap(resp.data);
      },
      fallback: null,
    );
  }

  /// Fetches notifications from a full URL.
  ///
  /// This is typically used to follow server-provided pagination links such as
  /// `links.next` or `links.prev`.
  static Future<NotificationInfoList?> getNotificationByUrl(String url) async {
    return ApiGuard.run(
      name: "getNotificationByUrl",
      method: "GET",
      call: () async => _parseInBackground<NotificationInfoList>(
        (await _utils.get(url)).data,
        _ApiParseKind.notificationInfoList,
      ),
      fallback: null,
    );
  }

  /// Marks a single notification as read.
  ///
  /// This sends a PATCH request to `/api/notifications/{id}` and returns the
  /// updated notification entity on success.
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
      call: () async => _parseInBackground<NotificationsInfo>(
        (await _utils.patch("$_baseUrl/api/notifications/$id", data: m)).data,
        _ApiParseKind.notificationsInfo,
      ),
      fallback: null,
    );
  }

  /// Marks all notifications as read for the current user.
  ///
  /// Flarum returns `204 No Content` on success.
  static Future<bool> readAllNotification() async {
    return ApiGuard.run(
      name: "readAllNotification",
      method: "GET",
      call: () async {
        var r = await _utils.post("$_baseUrl/api/notifications/read");
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
      method: "POST",
      call: () async {
        final r = await _utils.post(
          "/notifications",
          data: null,
          options: Options(headers: {'X-HTTP-Method-Override': 'DELETE'}),
        );

        return r.statusCode == 204;
      },
      fallback: false,
    );
  }

  /// Fetches posts authored by a specific user.
  ///
  /// Results are ordered by creation time descending and constrained to
  /// `filter[type]=comment`, which fits profile pages and recent-replies views.
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
        return _parseInBackground<Posts>(resp.data, _ApiParseKind.posts);
      },
      fallback: null,
      extra: "(user=$username offset=$offset)",
    );
  }

  static Future<List<UserItem>> getUserDictionary({
    UserSort sort = .unknown,
    int? offset,
  }) async {
    return ApiGuard.run(
      name: "getUserDictionary",
      method: "GET",
      call: () async {
        final query = {
          if (_userSortValue(sort) != null) "sort": _userSortValue(sort)!,
          if (offset != null) "page[offset]": offset.toString(),
          "include": "",
        };

        final r = await _utils.get("/users", queryParameters: query);

        final list = (r.data["data"] as List);

        return list.map((e) => UserItem.fromJson(e)).toList();
      },
      fallback: [],
    );
  }

  /// Fetches a user by a full user URL.
  /// This is useful when the server has already returned an absolute link and
  /// the caller does not want to rebuild the path manually.
  static Future<UserInfo?> getUserByUrl(String url) async {
    return ApiGuard.run(
      name: "getUserByUrl",
      method: "GET",
      call: () async => _parseInBackground<UserInfo>(
        (await _utils.get(url)).data,
        _ApiParseKind.userInfo,
      ),
      fallback: null,
    );
  }

  /// Logs in via `/api/token`.
  ///
  /// Parameters:
  /// - [username]: username or email
  /// - [password]: plaintext password
  ///
  /// Returns the token and user ID, or `null` if login fails.
  /// This currently supports both `Map` and JSON-string response bodies.
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
        return _parseNullableInBackground<LoginResult>(
          result?.data,
          _ApiParseKind.loginResult,
        );
      },
      fallback: null,
    );
  }
}
