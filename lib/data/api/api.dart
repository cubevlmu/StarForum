import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:star_forum/data/api/api_constants.dart';
import 'package:star_forum/data/api/api_guard.dart';
import 'package:star_forum/data/api/api_log.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/model/uploads.dart';
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
  uploadFileList,
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
class ApiUploadFile {
  const ApiUploadFile({required this.fileName, this.path, this.bytes});

  final String fileName;
  final String? path;
  final Uint8List? bytes;

  Future<MultipartFile> toMultipartFile() {
    final contentType = MultipartFile.lookupMediaType(fileName);
    final filePath = path;
    if (filePath != null && filePath.isNotEmpty) {
      return MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: contentType,
      );
    }

    final data = bytes;
    if (data == null || data.isEmpty) {
      throw StateError('Upload file data is empty: $fileName');
    }
    return Future.value(
      MultipartFile.fromBytes(
        data,
        filename: fileName,
        contentType: contentType,
      ),
    );
  }
}

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
    case _ApiParseKind.uploadFileList:
      return UploadFileList.fromMap(_apiAsJsonMap(request.data));
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

  static String _cacheKey(String method, String url) => '$method $url';

  static void _invalidateDiscussionCaches() {
    ApiGuard.invalidateRequestCache(
      (key) => key.contains('/api/discussions') || key.contains('/api/posts'),
    );
  }

  static void _invalidateNotificationCaches() {
    ApiGuard.invalidateRequestCache(
      (key) => key.contains('/api/notifications'),
    );
  }

  static void _invalidateUserCaches() {
    ApiGuard.invalidateRequestCache((key) => key.contains('/api/users'));
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

      if (resp.statusCode == 200) {
        _invalidateUserCaches();
      }
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
  static Future<(ForumInfo?, int)> getForumInfo(
    String url, {
    bool force = false,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!force && _buffered != null && _buffered?.url == url) {
      ApiLog.ok("getForumInfo", "GET", "Local buffered. Url $url");
      return (_buffered, 0);
    }

    var totalMs = -1;
    final result = await ApiGuard.runPhased<ForumInfo?, String, Response>(
      name: "getForumInfo",
      method: "GET",
      prepare: () async => "$url/api",
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (response, _) =>
          _parseInBackground<ForumInfo>(response.data, _ApiParseKind.forumInfo),
      fallback: null,
      onFinished: (total, prepareMs, requestMs, parseMs, parsed) {
        totalMs = total;
      },
    );
    if (result == null) {
      _buffered = null;
      return (null, -1);
    }

    final time = totalMs;
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
    _buffered = result;
    return (result, lagLevel);
  }

  /// Fetches the tag list from `/api/tags`.
  ///
  /// The returned tag data is organized into the `Tags` structure, including
  /// parent-child relationships, so UI code can render it directly.
  static Future<Tags?> getTags() async {
    final url = "$_baseUrl/api/tags";
    return ApiGuard.runPhased(
      name: "getTags",
      method: "GET",
      prepare: () async => url,
      request: (url) => _utils.get(url),
      parse: (resp, _) =>
          _parseInBackground<Tags>(resp.data, _ApiParseKind.tags),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', url),
        ttl: const Duration(minutes: 5),
      ),
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

        if (r.statusCode == 200) {
          _invalidateDiscussionCaches();
        }
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
    final requestUrl = "$_baseUrl/api/discussions/$id?include=user,firstPost";
    return ApiGuard.runPhased(
      name: "getDiscussionById",
      method: "GET",
      prepare: () async => requestUrl,
      request: (url) => _utils.get(url),
      parse: (resp, _) => _parseInBackground<DiscussionInfo>(
        resp.data,
        _ApiParseKind.discussionInfo,
      ),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 30),
      ),
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
      'fields[discussions]':
          'title,createdAt,lastPostedAt,lastPostNumber,commentCount,views,subscription,user,lastPostedUser,firstPost,tags',
      'fields[users]': 'username,displayName,avatarUrl',
      'fields[tags]':
          'name,description,slug,discussionCount,position,lastPostedAt,isChild,canStartDiscussion',
      'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
    };

    if (tagSlug != null) {
      params['filter[q]'] = 'tag:${Uri.encodeComponent(tagSlug)}';
    }

    final requestUrl = Uri.parse(
      "$_baseUrl/api/discussions",
    ).replace(queryParameters: params).toString();
    return ApiGuard.runPhased(
      name: "getDiscussionList",
      method: "GET",
      prepare: () async => requestUrl,
      request: (url) => _utils.get(url),
      parse: (resp, _) async =>
          compute(PagedDiscussions.fromMapFast, _apiAsJsonMap(resp.data)),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: offset == 0
            ? const Duration(seconds: 20)
            : const Duration(seconds: 45),
      ),
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
      'fields[discussions]':
          'title,createdAt,lastPostedAt,lastPostNumber,commentCount,views,subscription,user,lastPostedUser,firstPost,tags',
      'fields[users]': 'username,displayName,avatarUrl',
      'fields[tags]': 'name,slug,color',
      'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
    };

    if (sortKey.isNotEmpty) {
      params['sort'] = sortKey;
    }

    final requestUrl = Uri.parse(
      "$_baseUrl/api/discussions",
    ).replace(queryParameters: params).toString();
    return ApiGuard.runPhased(
      name: "getFollowingDiscussionList",
      method: "GET",
      prepare: () async => requestUrl,
      request: (url) => _utils.get(url),
      parse: (resp, _) async =>
          compute(PagedDiscussions.fromMapFast, _apiAsJsonMap(resp.data)),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: offset == 0
            ? const Duration(seconds: 15)
            : const Duration(seconds: 30),
      ),
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

    return ApiGuard.runPhased(
      name: "searchDiscuss",
      method: "GET",
      prepare: () async => url,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) async =>
          compute(Discussions.fromMapFast, _apiAsJsonMap(resp.data)),
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

      'fields[discussions]':
          'title,createdAt,lastPostedAt,lastPostNumber,commentCount,views,subscription,user,lastPostedUser,firstPost,tags',
      'fields[users]': 'username,displayName,avatarUrl',
      'fields[tags]':
          'name,description,slug,discussionCount,position,lastPostedAt,isChild,canStartDiscussion',
      'fields[posts]': 'createdAt,contentHtml,editedAt,likesCount',
    };

    final requestUrl = Uri.parse(
      "$_baseUrl/api/discussions",
    ).replace(queryParameters: params).toString();
    return ApiGuard.runPhased(
      name: "getDiscussByTag",
      method: "GET",
      prepare: () async => requestUrl,
      request: (url) => _utils.get(url),
      parse: (resp, _) async =>
          compute(Discussions.fromMapFast, _apiAsJsonMap(resp.data)),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: offset == 0
            ? const Duration(seconds: 20)
            : const Duration(seconds: 45),
      ),
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

    return ApiGuard.runPhased(
      name: "getFirstPost",
      method: "GET",
      prepare: () async => url,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) async {
        final data = await _parseInBackground<Posts>(
          resp.data,
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

    return ApiGuard.runPhasedWithToken(
      name: "createDiscussion",
      method: "POST",
      prepare: () async => m,
      request: (body) => _utils.post(
        "$_baseUrl/api/discussions",
        data: body,
        options: Options(contentType: 'application/vnd.api+json'),
      ),
      parse: (resp, _) async {
        if (resp?.statusCode == 201) {
          final parsed = await _parseNullableInBackground<DiscussionInfo>(
            resp?.data,
            _ApiParseKind.discussionInfo,
          );
          _invalidateDiscussionCaches();
          return parsed;
        }
        return null;
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

    final requestUrl = url;
    return ApiGuard.runPhased(
      name: "getPosts",
      method: "GET",
      prepare: () async => requestUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) =>
          _parseInBackground<Posts>(resp.data, _ApiParseKind.posts),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 30),
      ),
    );
  }

  /// Fetches multiple posts by ID.
  ///
  /// This uses `/api/posts?filter[id]=1,2,3` and is useful for notifications,
  /// jump recovery, or any flow that needs several posts in one request.
  static Future<Posts?> getPostsById(List<int> l) async {
    var url = "$_baseUrl/api/posts?filter[id]=${l.join(",")}";

    final requestUrl = url;
    return ApiGuard.runPhased(
      name: "getPostsById",
      method: "GET",
      prepare: () async => requestUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) =>
          _parseInBackground<Posts>(resp.data, _ApiParseKind.posts),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 30),
      ),
    );
  }

  /// Fetches a single post.
  ///
  /// Internally this still uses `filter[id]`, so the return type remains
  /// `Posts?` and the caller is expected to extract the target post.
  static Future<Posts?> getPost(String id) async {
    var url = "$_baseUrl/api/posts?filter[id]=$id";

    final requestUrl = url;
    return ApiGuard.runPhased(
      name: "getPostsById",
      method: "GET",
      prepare: () async => requestUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) =>
          _parseInBackground<Posts>(resp.data, _ApiParseKind.posts),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 30),
      ),
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

    return ApiGuard.runPhasedWithToken(
      name: "createPost",
      method: "POST",
      prepare: () async => m,
      request: (body) => _utils.post("$_baseUrl/api/posts", data: body),
      parse: (resp, _) async {
        final parsed = await _parseNullableInBackground<PostInfo>(
          resp?.data,
          _ApiParseKind.postInfo,
        );
        _invalidateDiscussionCaches();
        return parsed;
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

    return ApiGuard.runPhasedWithToken(
      name: "likePost",
      method: "POST",
      prepare: () async => m,
      request: (body) => _utils.patch("$_baseUrl/api/posts/$id", data: body),
      parse: (resp, _) async {
        final parsed = await _parseInBackground<PostInfo>(
          resp.data,
          _ApiParseKind.postInfo,
        );
        _invalidateDiscussionCaches();
        return parsed;
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
          _invalidateDiscussionCaches();
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

    return ApiGuard.runPhasedWithToken(
      name: "getNotification",
      method: "GET",
      prepare: () async => reqUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) => _parseInBackground<NotificationInfoList>(
        resp.data,
        _ApiParseKind.notificationInfoList,
      ),
      fallback: null,
    );
  }

  /// Fetches files uploaded by a user from FoF Uploads.
  ///
  /// Pass [url] to follow server-provided pagination links such as
  /// `UploadFileList.links.next`. Otherwise this loads the first page for
  /// [userId] with offset pagination.
  static Future<(UploadFileList?, bool)> getUploads({
    required int userId,
    int offset = 0,
    int limit = 15,
    String? url,
  }) async {
    final requestUrl =
        url ??
        Uri.parse("$_baseUrl/api/fof/uploads")
            .replace(
              queryParameters: {
                'filter[user]': userId.toString(),
                'page[offset]': offset.toString(),
                'page[limit]': limit.toString(),
              },
            )
            .toString();

    return ApiGuard.runPhasedWithToken(
      name: "getUploads",
      method: "GET",
      prepare: () async => requestUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) => _parseInBackground<UploadFileList>(
        resp.data,
        _ApiParseKind.uploadFileList,
      ),
      fallback: null,
      extra: "(user=$userId offset=$offset)",
    );
  }

  static Future<(UploadFileList?, bool)> uploadFiles(
    List<ApiUploadFile> files,
  ) async {
    if (files.isEmpty) {
      return (UploadFileList(list: const [], links: Links.empty), true);
    }

    return ApiGuard.runPhasedWithToken(
      name: "uploadFiles",
      method: "POST",
      prepare: () async {
        final formData = FormData();
        for (final file in files) {
          formData.files.add(MapEntry('files[]', await file.toMultipartFile()));
        }
        return formData;
      },
      request: (formData) => _utils.post(
        "$_baseUrl/api/fof/upload",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      ),
      parse: (resp, _) => _parseInBackground<UploadFileList>(
        resp.data,
        _ApiParseKind.uploadFileList,
      ),
      fallback: null,
      extra: "(count=${files.length})",
    );
  }

  static Future<(bool, bool)> deleteUploadFile(String uuid) async {
    return ApiGuard.runPhasedWithToken(
      name: "deleteUploadFile",
      method: "POST",
      prepare: () async => uuid,
      request: (uuid) => _utils.post(
        "$_baseUrl/api/fof/upload/delete/$uuid",
        options: Options(headers: {'X-HTTP-Method-Override': 'DELETE'}),
      ),
      parse: (resp, _) async => resp.statusCode == 204,
      fallback: false,
      extra: "(uuid=$uuid)",
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
    final requestUrl = url;
    return ApiGuard.runPhased(
      name: "getNotificationByUrl",
      method: "GET",
      prepare: () async => requestUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) => _parseInBackground<NotificationInfoList>(
        resp.data,
        _ApiParseKind.notificationInfoList,
      ),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 10),
      ),
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
    return ApiGuard.runPhased(
      name: "setNotificationIsRead",
      method: "PATCH",
      prepare: () async => m,
      request: (body) =>
          _utils.patch("$_baseUrl/api/notifications/$id", data: body),
      parse: (resp, _) async {
        final parsed = await _parseInBackground<NotificationsInfo>(
          resp.data,
          _ApiParseKind.notificationsInfo,
        );
        _invalidateNotificationCaches();
        return parsed;
      },
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
          _invalidateNotificationCaches();
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

        if (r.statusCode == 204) {
          _invalidateNotificationCaches();
        }
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
    final requestUrl = Uri.parse("$_baseUrl/api/posts")
        .replace(
          queryParameters: {
            'filter[author]': username,
            'page[offset]': offset.toString(),
            'page[limit]': limit.toString(),
            'sort': '-createdAt',
            'include': 'user,discussion',
            'filter[type]': 'comment',
          },
        )
        .toString();
    return ApiGuard.runPhased(
      name: "getPostsByAuthor",
      method: "GET",
      prepare: () async => requestUrl,
      request: (url) => _utils.get(url),
      parse: (resp, _) =>
          _parseInBackground<Posts>(resp.data, _ApiParseKind.posts),
      fallback: null,
      extra: "(user=$username offset=$offset)",
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 20),
      ),
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
    final requestUrl = url;
    return ApiGuard.runPhased(
      name: "getUserByUrl",
      method: "GET",
      prepare: () async => requestUrl,
      request: (requestUrl) => _utils.get(requestUrl),
      parse: (resp, _) =>
          _parseInBackground<UserInfo>(resp.data, _ApiParseKind.userInfo),
      fallback: null,
      cachePolicy: ApiRequestCachePolicy(
        key: _cacheKey('GET', requestUrl),
        ttl: const Duration(seconds: 30),
      ),
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
    return ApiGuard.runPhased(
      name: "login",
      method: "POST",
      prepare: () async {
        LogUtil.debug("$_baseUrl/api/token");
        return {"identification": username, "password": password};
      },
      request: (body) => _utils.post("$_baseUrl/api/token", data: body),
      parse: (resp, _) => _parseNullableInBackground<LoginResult>(
        resp?.data,
        _ApiParseKind.loginResult,
      ),
      fallback: null,
    );
  }
}
