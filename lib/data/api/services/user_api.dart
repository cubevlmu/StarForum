import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_endpoint.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/api/mappers/badge_mapper.dart';
import 'package:star_forum/data/api/mappers/mapper_support.dart';
import 'package:star_forum/data/api/mappers/user_mapper.dart';
import 'package:star_forum/data/model/badge.dart';
import 'package:star_forum/data/model/group_info.dart';
import 'package:star_forum/data/model/users.dart';

import 'api_parsing.dart';

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

class UserApi {
  UserApi(this.client);

  final FlarumApiClient client;

  Future<UserInfo?> getByNameOrId(
    String idOrSlug, {
    CancelToken? cancelToken,
  }) async {
    final response = await client.get<Object?>(
      '/api/users/$idOrSlug',
      query: FlarumQuery().include(['groups']).fields('users', [
        ...DiscussionQueries.userFields,
        'joinedAt',
        'joinTime',
        'discussionCount',
        'commentCount',
        'lastSeenAt',
        'bio',
        'email',
        'groups',
      ]).build(),
      cancelToken: cancelToken,
    );
    return parseUser(response.data);
  }

  Future<FlarumPage<UserInfo>?> directory({
    int limit = 100,
    int offset = 0,
    UserSort sort = UserSort.unknown,
    int? groupId,
    CancelToken? cancelToken,
  }) async {
    final sortValue = switch (sort) {
      UserSort.username => 'username',
      UserSort.usernameD => '-username',
      UserSort.joinedAt => 'joinedAt',
      UserSort.joinedAtD => '-joinedAt',
      UserSort.discussionCount => 'discussionCount',
      UserSort.discussionCountD => '-discussionCount',
      UserSort.exp => 'exp',
      UserSort.expD => '-exp',
      UserSort.unknown => '-joinedAt',
    };
    final query = FlarumQuery()
        .page(offset: offset, limit: limit)
        .sort(sortValue)
        .include(['groups'])
        .fields('users', [
          ...DiscussionQueries.userFields,
          'joinedAt',
          'joinTime',
          'discussionCount',
          'commentCount',
          'lastSeenAt',
          'groups',
        ]);
    if (groupId != null && groupId > 0) {
      query.filter('group', groupId.toString());
    }
    final response = await client.get<Object?>(
      '/api/users',
      query: query.build(),
      cancelToken: cancelToken,
    );
    final document = documentOf(response.data);
    final users = const UserMapper().documentList(document);
    final next = document.links['next']?.toString();
    return FlarumPage(
      items: users,
      nextUrl: next == null || next.isEmpty ? null : next,
      total: int.tryParse(document.meta['total']?.toString() ?? ''),
    );
  }

  Future<List<GroupInfo>> groups({CancelToken? cancelToken}) async {
    final response = await client.get<Object?>(
      '/api/groups',
      cancelToken: cancelToken,
    );
    final document = documentOf(response.data);
    const mapper = UserMapper();
    return [
      for (final resource in documentResources(document))
        if (resource.type == 'groups') mapper.groupItem(resource),
    ];
  }

  Future<List<UserBadge>> badges(int userId, {CancelToken? cancelToken}) async {
    final response = await client.get<Object?>(
      '/api/users/$userId',
      query: FlarumQuery().include([
        'userBadges',
        'userBadges.badge',
        'userBadges.badge.category',
      ]).build(),
      cancelToken: cancelToken,
    );
    return const BadgeMapper().userBadgeList(documentOf(response.data));
  }

  Future<bool> update(
    int userId, {
    required Map<String, dynamic> attributes,
  }) async {
    final response = await client.post<Object?>(
      '/api/users/$userId',
      data: {
        'data': {
          'type': 'users',
          'id': userId.toString(),
          'attributes': attributes,
        },
      },
      options: Options(headers: {'x-http-method-override': 'PATCH'}),
    );
    return response.statusCode == 200;
  }

  Future<bool> uploadAvatar({
    required int userId,
    required Uint8List fileData,
    required String fileName,
  }) async {
    final response = await client.post<Object?>(
      '/api/users/$userId/avatar',
      data: FormData.fromMap({
        'avatar': MultipartFile.fromBytes(fileData, filename: fileName),
      }),
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.statusCode == 200;
  }
}
