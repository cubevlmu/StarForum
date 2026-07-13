import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_endpoint.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/model/discussions.dart';

import 'api_parsing.dart';

enum FollowingSort { hottest, latestReply, newest, oldest, mostViews }

class DiscussionApi {
  DiscussionApi(this.client);

  final FlarumApiClient client;

  Future<FlarumPage<DiscussionDetail>?> list(
    String sort, {
    String? tagSlug,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return _list(
      DiscussionQueries.feed(
        sort: sort,
        offset: offset,
        limit: limit,
        tagSlug: tagSlug,
      ),
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<FlarumPage<DiscussionDetail>?> following({
    FollowingSort sort = FollowingSort.hottest,
    int offset = 0,
    int limit = 20,
  }) {
    final sortValue = switch (sort) {
      FollowingSort.hottest => '',
      FollowingSort.latestReply => '-commentCount',
      FollowingSort.newest => '-createdAt',
      FollowingSort.oldest => 'createdAt',
      FollowingSort.mostViews => '-viewCount',
    };
    final query = DiscussionQueries.feed(
      sort: sortValue,
      offset: offset,
      limit: limit,
    ).filter('subscription', 'following');
    return _list(query, limit: limit);
  }

  Future<FlarumPage<DiscussionDetail>?> search({
    required String key,
    String? tagSlug,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return _list(
      DiscussionQueries.search(
        key: key,
        offset: offset,
        limit: limit,
        tagSlug: tagSlug,
      ),
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<FlarumPage<DiscussionDetail>?> byTag({
    required String tag,
    int offset = 0,
    int limit = 20,
  }) {
    return _list(
      DiscussionQueries.feed(
        sort: '',
        offset: offset,
        limit: limit,
        tagSlug: tag,
      ),
      limit: limit,
    );
  }

  Future<FlarumPage<DiscussionDetail>?> byAuthor({
    required String username,
    int offset = 0,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    final query = DiscussionQueries.feed(
      sort: '-createdAt',
      offset: offset,
      limit: limit,
    ).filter('author', username);
    return _list(query, limit: limit, cancelToken: cancelToken);
  }

  Future<DiscussionDetail?> getById(
    String id, {
    CancelToken? cancelToken,
  }) async {
    final response = await client.get<Object?>(
      '/api/discussions/$id',
      query: DiscussionQueries.detailHeader().build(),
      cancelToken: cancelToken,
    );
    return parseDiscussion(response.data);
  }

  Future<DiscussionDetail?> create(
    List<int> tags,
    String title,
    String content,
  ) async {
    final response = await client.post<Object?>(
      '/api/discussions',
      data: {
        'data': {
          'type': 'discussions',
          'attributes': {'title': title, 'content': content},
          'relationships': {
            'tags': {
              'data': [
                for (final tag in tags) {'type': 'tags', 'id': tag.toString()},
              ],
            },
          },
        },
      },
    );
    _invalidate();
    return parseDiscussion(response.data);
  }

  Future<bool> setFollow(String discussionId, bool follow) async {
    final response = await client.patch<Object?>(
      '/api/discussions/$discussionId',
      data: {
        'data': {
          'type': 'discussions',
          'id': discussionId,
          'attributes': {'subscription': follow ? 'follow' : null},
        },
      },
    );
    _invalidate();
    return response.statusCode == 200;
  }

  Future<bool> setLastReadPostNumber(String discussionId, int number) async {
    final response = await client.patch<Object?>(
      '/api/discussions/$discussionId',
      data: {
        'data': {
          'type': 'discussions',
          'id': discussionId,
          'attributes': {'lastReadPostNumber': number},
        },
      },
    );
    _invalidate();
    return response.statusCode == 200;
  }

  Future<FlarumPage<DiscussionDetail>?> _list(
    FlarumQuery query, {
    required int limit,
    CancelToken? cancelToken,
  }) async {
    final response = await client.get<Object?>(
      '/api/discussions',
      query: query.build(),
      cancelToken: cancelToken,
    );
    final document = documentOf(response.data);
    final parsed = parseDiscussionsDocument(document);
    final next = document.links['next']?.toString();
    final prev = document.links['prev']?.toString();
    return FlarumPage(
      items: parsed,
      nextUrl: next == null || next.isEmpty ? null : next,
      prevUrl: prev == null || prev.isEmpty ? null : prev,
      total: int.tryParse(document.meta['total']?.toString() ?? ''),
    );
  }

  void _invalidate() {
    // Shared invalidation remains centralized in the guard while services are
    // migrated incrementally.
  }
}
