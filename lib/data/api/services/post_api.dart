import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_endpoint.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/model/posts.dart';

import 'api_parsing.dart';

enum PostSort { time, number }

class PostApi {
  PostApi(this.client);

  final FlarumApiClient client;

  Future<PostInfo?> getFirstPost(String discussionId) async {
    final data = await getPosts(
      discussionId: discussionId,
      limit: 1,
      sort: PostSort.number,
    );
    final values = data?.posts.values;
    return values == null || values.isEmpty ? null : values.first;
  }

  Future<Posts?> getPosts({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostSort sort = PostSort.number,
  }) async {
    final query = FlarumQuery()
        .filter('discussion', discussionId)
        .sort(switch (sort) {
          PostSort.time => '-createdAt',
          PostSort.number => 'number',
        })
        .page(offset: offset, limit: limit)
        .include(['user'])
        .fields('posts', PostQueries.fields)
        .fields('users', DiscussionQueries.userFields);
    final response = await client.get<Object?>(
      '/api/posts',
      query: query.build(),
    );
    return parsePosts(response.data);
  }

  Future<FlarumPage<PostInfo>?> listByDiscussion({
    required String discussionId,
    int offset = 0,
    int limit = 20,
    PostSort sort = PostSort.number,
    String? nextUrl,
    CancelToken? cancelToken,
  }) async {
    if (nextUrl != null && nextUrl.isNotEmpty) {
      return _list(nextUrl, null, cancelToken: cancelToken);
    }
    final query = FlarumQuery()
        .filter('discussion', discussionId)
        .sort(switch (sort) {
          PostSort.time => '-createdAt',
          PostSort.number => 'number',
        })
        .page(offset: offset, limit: limit)
        .include(['user'])
        .fields('posts', PostQueries.fields)
        .fields('users', DiscussionQueries.userFields);
    return _list('/api/posts', query, cancelToken: cancelToken);
  }

  Future<FlarumPage<PostInfo>?> listInitialByDiscussion({
    required String discussionId,
    int replyLimit = 10,
    CancelToken? cancelToken,
  }) {
    final query = FlarumQuery()
        .filter('discussion', discussionId)
        .sort('number')
        .page(offset: 0, limit: replyLimit + 1)
        .include(['user'])
        .fields('posts', PostQueries.fields)
        .fields('users', DiscussionQueries.userFields);
    return _list('/api/posts', query, cancelToken: cancelToken);
  }

  Future<Posts?> getByIds(List<int> ids) async {
    if (ids.isEmpty) return Posts({}, {}, {});
    final query = FlarumQuery()
        .filter('id', ids.join(','))
        .include(['user', 'discussion'])
        .fields('posts', PostQueries.fields)
        .fields('users', DiscussionQueries.userFields);
    final response = await client.get<Object?>(
      '/api/posts',
      query: query.build(),
    );
    return parsePosts(response.data);
  }

  Future<Posts?> getPostsById(List<int> ids) => getByIds(ids);

  Future<FlarumPage<PostInfo>?> listByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
  }) {
    final query = FlarumQuery()
        .filter('author', username)
        .filter('type', 'comment')
        .sort('-createdAt')
        .page(offset: offset, limit: limit)
        .include(['user', 'discussion'])
        .fields('posts', PostQueries.fields)
        .fields('users', DiscussionQueries.userFields);
    return _list('/api/posts', query);
  }

  Future<Posts?> getPostsByAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final query = FlarumQuery()
        .filter('author', username)
        .filter('type', 'comment')
        .sort('-createdAt')
        .page(offset: offset, limit: limit)
        .include(['user', 'discussion'])
        .fields('posts', PostQueries.fields)
        .fields('users', DiscussionQueries.userFields);
    final response = await client.get<Object?>(
      '/api/posts',
      query: query.build(),
      cancelToken: cancelToken,
    );
    return parsePosts(response.data);
  }

  Future<PostInfo?> create(String discussionId, String content) async {
    final response = await client.post<Object?>(
      '/api/posts',
      data: {
        'data': {
          'type': 'posts',
          'attributes': {'content': content},
          'relationships': {
            'discussion': {
              'data': {'type': 'discussions', 'id': discussionId},
            },
          },
        },
      },
    );
    return parsePost(response.data);
  }

  Future<PostInfo?> createPost(String discussionId, String content) =>
      create(discussionId, content);

  Future<PostInfo?> like(String id, bool isLiked) async {
    final response = await client.patch<Object?>(
      '/api/posts/$id',
      data: {
        'data': {
          'type': 'posts',
          'id': id,
          'attributes': {'isLiked': isLiked},
        },
      },
    );
    return parsePost(response.data);
  }

  Future<PostInfo?> likePost(String id, bool isLiked) => like(id, isLiked);

  Future<FlarumPage<PostInfo>?> _list(
    String path,
    FlarumQuery? query, {
    CancelToken? cancelToken,
  }) async {
    final response = await client.get<Object?>(
      path,
      query: query?.build(),
      cancelToken: cancelToken,
    );
    final document = documentOf(response.data);
    final parsed = parsePosts(document.raw);
    final next = document.links['next']?.toString();
    final prev = document.links['prev']?.toString();
    return FlarumPage(
      items: parsed.posts.values.toList(growable: false),
      nextUrl: next == null || next.isEmpty ? null : next,
      prevUrl: prev == null || prev.isEmpty ? null : prev,
      total: int.tryParse(document.meta['total']?.toString() ?? ''),
    );
  }
}
